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
		-- New nvim-treesitter API (the configs module was removed)
		require("nvim-treesitter").setup({
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
		})

		-- Enable treesitter-based highlighting (now built into Neovim)
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end
		})
	end
}
