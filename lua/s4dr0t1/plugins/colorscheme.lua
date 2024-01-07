--[[
	Name: Colorscheme
	Description: Configuration file for the colorscheme in usage
	Link: https://github.com/EdenEast/nightfox.nvim#carbonfox
--]]

return {
	'EdenEast/nightfox.nvim',
	priority = 1000,
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
	},

	-- Custom settings for  the plugin
	config = function()
		-- Configuration
		local colorscheme = "carbonfox"
		--local colorscheme = "dayfox"
		vim.cmd("colorscheme " .. colorscheme)
	end,
}
