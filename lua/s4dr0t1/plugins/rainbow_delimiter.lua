--[[
	Name: Rainbox delimiters
	Description: Rainbox delimiters for neovim powered by Treesitter
	Link: HiPhish/rainbow-delimiters.nvim
--]]

return {
	'HiPhish/rainbow-delimiters.nvim',
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter"
	}
}
