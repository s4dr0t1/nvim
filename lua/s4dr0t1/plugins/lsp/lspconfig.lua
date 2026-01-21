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
		-- https://github.com/hrsh7th/cmp-nvim-lsp
		local custom_capabilities = require('cmp_nvim_lsp').default_capabilities()

		-- Function to setup LSP keymaps when a server attaches to a buffer
		local function lsp_keymaps(client, bufnr)
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
			end

			-- Diagnostics (using vim.diagnostic.jump API from Neovim 0.11+)
			map("n", "gl", function() vim.diagnostic.open_float({ border = 'rounded' }) end,
				"Open diagnostic float")
			map("n", "gk", function() vim.diagnostic.jump({ count = -1, float = { border = "rounded" } }) end,
				"Previous diagnostic")
			map("n", "gj", function() vim.diagnostic.jump({ count = 1, float = { border = "rounded" } }) end,
				"Next diagnostic")

			-- LSP navigation
			map("n", "K", vim.lsp.buf.hover, "Hover documentation")
			map("n", "gd", vim.lsp.buf.definition, "Go to definition")
			map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
			map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
			map("n", "gR", vim.lsp.buf.references, "Go to references")

			-- LSP actions
			map("n", "gr", vim.lsp.buf.rename, "Rename symbol")
		end

		-- This function is used to setup Format on save functionality
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		local function enable_format_on_save(client, bufnr)
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
		CUSTOM_ATTACH = function(client, bufnr)
			-- Passing the keymaps so that they can be used
			lsp_keymaps(client, bufnr)

			-- Format on save
			enable_format_on_save(client, bufnr)

			--[[
				-- Disable formatting (for future reference)
				if client.name == "rnixis" then
					client.resolved_capabilities.document_formatting = false
				end
			--]]
		end

		-- Diagnostic display configuration (Neovim 0.10+ native API)
		vim.diagnostic.config({
			virtual_text = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = " ",
					[vim.diagnostic.severity.INFO] = " ",
				},
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
		})

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
					on_attach = CUSTOM_ATTACH,
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
					on_attach = CUSTOM_ATTACH
				})
				vim.lsp.enable(server_name)
			end
		end
	end
}
