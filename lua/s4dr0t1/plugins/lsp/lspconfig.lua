--[[
	Name: LSP configuration
	Description: Contains configuration to deal with:
		- neovim's LSP shit
		- How packages installed through mason will interact with the LSP shit
	Link:
	- https://github.com/neovim/nvim-lspconfig
	- https://github.com/williamboman/mason-lspconfig.nvim
--]]

return {
	"neovim/nvim-lspconfig",
	event = {
		"BufReadPre",
		"BufNewFile"
	},

	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		'williamboman/mason.nvim',
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		"williamboman/mason-lspconfig.nvim",
	},

	config = function()
		--[[
			************************************************************************
							IMPORTANT
			************************************************************************

			It's important that you set up the plugins in the following order:

			1. `mason.nvim`
			2. `mason-lspconfig.nvim`
			3. Setup servers via `lspconfig`

			Pay extra attention to this if you lazy-load plugins, or somehow "chain" the loading of plugins via your plugin manager.
			require("mason").setup()
			require("mason-lspconfig").setup()

			After setting up mason-lspconfig you may set up servers via lspconfig
			require("lspconfig").lua_ls.setup {}
			require("lspconfig").rust_analyzer.setup {}

			`mason-lspconfig` requires `mason.nvim` & `lspconfig` to be installed.

			`lspconfig` needs to be available in |rtp| so that `mason-lspconfig` can
			successfully call `require("lspconfig")` (|lua-require|) during setup.
			Pay extra attention to this if you lazy-load plugins, or somehow "chain"
			the loading of plugins via your plugin manager.
		--]]
		-- Using new vim.lsp.config/enable API (Neovim 0.11+)
		-- https://github.com/neovim/nvim-lspconfig

		-- Starting up mason to make sure we get their order right
		local mason = require('mason')
		mason.setup()

		-- Starting mason-lspconfig
		local mason_lspconfig = require('mason-lspconfig')
		mason_lspconfig.setup({})

		-- Advertise nvim-lsp LSP capabilities to the LSP server so that we can get autocompletion from the LSP
		local custom_capabilities = require('cmp_nvim_lsp').default_capabilities()

		-- Function to setup LSP keymaps which is passed to the custom_attach function and is then run when a LSP server hooks onto the buffer
		--function lsp_keymaps(client, bufnr)
		function Lsp_keymaps(client, bufnr)
			local opts = { noremap = true, silent = true }
			local set_lsp_key = vim.api.nvim_buf_set_keymap

			-- Open float menu for the LSP to show diagnostics
			set_lsp_key(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>",
				opts)

			-- Hover feature
			set_lsp_key(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

			-- Goto the previous diagnostic message
			set_lsp_key(bufnr, "n", "gk", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>',
				opts)

			-- Goto the next diagnostic message
			set_lsp_key(bufnr, "n", "gj", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>',
				opts)

			-- Goto the implementation of this thing
			set_lsp_key(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

			-- Goto the declaration of this thing
			set_lsp_key(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)

			-- Goto the definition of this thing
			set_lsp_key(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

			-- Rename this object using LSP
			set_lsp_key(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

			-- Go to the reference of this object
			set_lsp_key(bufnr, "n", "gR", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
		end

		-- This function is used to setup Format on save functionality
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		function Enable_Format_On_Save(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
						--vim.lsp.buf.formatting_sync()
					end,
				})
			end
		end

		-- The custom attach function which tells what to do when a LSP server gets attached to a buffer
		Custom_attach = function(client, bufnr)
			-- Passing the keymaps so that they can be used
			Lsp_keymaps(client, bufnr)

			-- Format on save
			Enable_Format_On_Save(client, bufnr)

			--[[
				-- Disable formatting (for future reference)
				if client.name == "rnixis" then
					client.resolved_capabilities.document_formatting = false
				end
			--]]
		end

		-- How the LSP will behave visually
		local signs = {
			{ name = "DiagnosticSignError", text = " " },
			{ name = "DiagnosticSignWarn", text = " " },
			{ name = "DiagnosticSignHint", text = " " },
			{ name = "DiagnosticSignInfo", text = " " },
		}

		for _, sign in ipairs(signs) do
			vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
		end

		local config = {
			-- disable virtual text
			virtual_text = false,

			-- show signs
			signs = {
				active = signs,
			},
			update_in_insert = true,
			underline = true,
			severity_sort = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		}
		vim.diagnostic.config(config)

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
		})

		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			border = "rounded",
		})

		--[[
			Automatic server configuration
			Automatically setup LSP servers installed using mason without having to manually add each server to the configuration
			Note: setup_handlers was removed in mason-lspconfig v2.x, so we manually iterate over installed servers
		--]]
		local installed_servers = mason_lspconfig.get_installed_servers()

		--[[
			To add custom configuration for a specific server, add an elseif block below.
			The server names are lspconfig names, not Mason package names.
			Example for rust_analyzer:

			elseif server_name == "rust_analyzer" then
				vim.lsp.config('rust_analyzer', {
					on_attach = Custom_attach,
					capabilities = custom_capabilities,
					settings = {
						["rust-analyzer"] = {
							checkOnSave = { command = "clippy" },
						}
					}
				})
				vim.lsp.enable('rust_analyzer')
		--]]
		for _, server_name in ipairs(installed_servers) do
			if server_name == "lua_ls" then
				-- Configure lua_ls with custom settings
				vim.lsp.config('lua_ls', {
					on_attach = Custom_attach,
					capabilities = custom_capabilities,
					settings = {
						Lua = {
							runtime = {
								version = 'LuaJIT',
							},
							diagnostics = {
								globals = { 'vim' },
							},
							telemetry = {
								enable = false,
							},
							-- Make the LSP neovim RTP aware
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true)
							}
						}
					}
				})
				vim.lsp.enable('lua_ls')
			-- Add more elseif blocks here for other servers that need custom config
			else
				-- Default handler for all other servers
				vim.lsp.config(server_name, {
					capabilities = custom_capabilities,
					on_attach = Custom_attach
				})
				vim.lsp.enable(server_name)
			end
		end
	end
}
