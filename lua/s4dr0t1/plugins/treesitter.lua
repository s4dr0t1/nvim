--[[
	Name: treesitter.lua
	Description: Configuration file for the nvim-treesitter plugin
	Link:
		- nvim-treesitter/nvim-treesitter
		- windwp/nvim-ts-autotag
--]]

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = {
		"BufReadPre",
		"BufNewFile"
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			-- A list of parser names, or "all"
			ensure_installed = {
				"c",
				"rust",
				"bash",
				"cpp",
				"csv",
				"json",
				"toml",
				"dockerfile",
				"fish",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"ssh_config",
				"lua",
				"gitignore",
				"git_config",
				"git_rebase"
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			auto_install = true,

			-- List of parsers to ignore installing (for "all")
			ignore_install = {},

			-- Enable indentation
			--indent = {
			--enable = true,
			--}
			-- Let treesitter augment syntax highlighting
			highlight = {
				enable = true,
				disable = {},
				additional_vim_regex_highlighting = true,
			},

			-- Make the nvim-autopair plugin Treesitter aware, is a module of Treesitter, not a standalone plugin
			-- windwp/nvim-ts-autotag
			autopairs = {
				enable = true
			}
		})
	end
}
