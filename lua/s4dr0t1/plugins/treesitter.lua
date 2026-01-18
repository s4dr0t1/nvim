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
	--[[
	-- The new rewrite doesn't support lazy-reloading
	event = {
		"BufReadPre",
		"BufNewFile"
	},
	--]]
	config = function()
		require 'nvim-treesitter'.install(

		-- Pre-emptively install the following automatically
			{
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
			}
		)
	end
}
