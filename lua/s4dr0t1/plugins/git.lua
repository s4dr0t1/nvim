--[[
	Name: Git
	Description: Configuration file for git integration with neovim
	Link: lewis6991/gitsigns.nvim
--]]

return {
	'lewis6991/gitsigns.nvim',
	event = { "BufReadPre", "BufNewFile" },
	opts = {}
}
