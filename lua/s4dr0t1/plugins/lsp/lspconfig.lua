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
		local lspconfig = require("lspconfig")

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
			Automatically setup LSP shit installed using mason without having to manually add each server to the configuration
			https://github.com/williamboman/mason-lspconfig.nvim/blob/0989bdf4fdf7b5aa4c74131d7ffccc3f399ac788/doc/mason-lspconfig.txt#L164

			If you use this approach, make sure you don't also manually set up servers directly via `lspconfig` as this will cause servers to be set up more than once.
		--]]
		-- require("mason-lspconfig").setup_handlers({})
		mason_lspconfig.setup_handlers({
			-- The default handler, and it will be called for each installed server that hasn't been overridden below
			function(server_name)
				--require("lspconfig")[server_name].setup {}
				lspconfig[server_name].setup({
					capabilities = custom_capabilities,
					on_attach = Custom_attach
				})
			end,

			["lua_ls"] = function()
				require 'lspconfig'.lua_ls.setup {
					on_attach = Custom_attach,
					capability = custom_capabilities,
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
				}
			end,

			-- Overriding the default handler
			--[[
				We can also specify dedicated handler for specific servers
				The server names provided as keys are the lspconfig server names, not mason's package names
				["rust_analyzer"] = function ()
					require("rust-tools").setup {}
					-- Can also put the settings in a different file
					-- require('lsp/server_settings/file.lua')
				end
			--]]
		})
	end
}
