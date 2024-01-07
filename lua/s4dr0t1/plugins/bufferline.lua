--[[
	Name: Bufferline
	Description: Configuration file for bufferline
	Contains: akinsho/bufferline.nvim
--]]

return {
	'akinsho/bufferline.nvim',
	version = "*",
	priority = 900,
	dependencies = {
		'neovim/nvim-lspconfig',
		'nvim-tree/nvim-web-devicons',
	},

	-- Similar to plugin.config() or plugin.setup()
	opts = {
		options = {
			-- Show buffer_id along with the buffer name, useful with dealing with :b commands
			numbers = "buffer_id",

			-- Show diagnostic information from the LSP
			diagnostics = "nvim_lsp",
			color_icons = true,
			buffer_close_icon = "",
			close_icon = "",
			show_buffer_close_icons = false,
			show_close_icon = false,
			separator_style = "slope",

			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					highlight = "Directory",
					text_align = "center"
				}
			}
		}
	}
}
