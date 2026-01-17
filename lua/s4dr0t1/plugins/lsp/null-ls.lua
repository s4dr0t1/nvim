--[[
	Name: null_ls.lua
	Description: Contains configuration files for the null_ls plugin, which is used to hook into the LSP
	Contains: jose-elias-alvarez/null-ls.nvim
--]]

return {
	"nvimtools/none-ls.nvim",
	lazy = true,
	event = {
		"BufReadPre",
		"BufNewFile"
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"neovim/nvim-lspconfig",
		--"nvimtools/none-ls-extras.nvim",
	},

	config = function()
		local null_ls = require('null-ls')
		local null_ls_utils = require("null-ls.utils")


		--[[
			- Builtins have been shifted to a new repository
			- Check these links for more information
				- https://github.com/nvimtools/none-ls-extras.nvim
				- https://github.com/nvimtools/none-ls.nvim/issues/58
		--]]
		local formatting = null_ls.builtins.formatting
		local diagnostics = null_ls.builtins.diagnostics

		null_ls.setup({
			root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),

			-- Custom_attach is defined in lspconfig.lua
			on_attach = Custom_attach,

			-- Get debug information as well
			debug = false,

			-- Copy paste all the sources which are not a LSP from the mason.lua configuration
			sources = {
				-- Formatters
				-- formatting.black,
				formatting.shfmt,


				-- Linters
				-- Shellcheck can be used through bashls, no need for a none-ls plugin separate usage
				--diagnostics.shellcheck,

				diagnostics.actionlint,
				--diagnostics.gitleaks,
				--[[
				diagnostics.vale.with({
					extra_filetypes = {
						"txt",
						"text",
					},
					extra_args = { "--config", vim.fn.expand("~/.config/vale/.vale.ini") },
				}),
				--]]
			},
		})
	end
}
