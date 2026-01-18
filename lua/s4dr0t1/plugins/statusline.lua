--[[
	Name: Statusline
	Description: Configuration files for the neovim statusline
	Contains: nvim-lualine/lualine.nvim
--]]

return {
	'nvim-lualine/lualine.nvim',
	dependencies = {
		'nvim-tree/nvim-web-devicons',
	},
	priority = 901,
	config = function()
		require('lualine').setup {
			extensions = {
				'nvim-tree',
				'man',
				'lazy',
				'mason',
			},
			options = {
				icons_enabled = true,
				theme = 'auto',
				component_separators = { left = '', right = '' },
				section_separators = { left = '', right = '' },
				always_divide_middle = true,

				-- Make sure there is a single lualine at the bottom of neovim instead of having each for every single window
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
		}
	end
}
