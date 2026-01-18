--[[
	Name: Colorscheme
	Description: Configuration file for the colorscheme in usage
	Link: https://github.com/EdenEast/nightfox.nvim#carbonfox
--]]

return {
	'EdenEast/nightfox.nvim',
	-- An explicit combination of priority and lazy=false means the color-scheme is loaded even faster
	priority = 1000,
	lazy = false,

	-- Custom settings for  the plugin
	config = function()
		-- Configuration
		local colorscheme = "carbonfox"
		--local colorscheme = "dayfox"
		vim.cmd("colorscheme " .. colorscheme)
	end,
}
