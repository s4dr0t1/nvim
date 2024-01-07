--[[
	Name: File explorer
	Description: Configuration files for the nvim file explorer
	Contains: kyazdani42/nvim-tree.lua
--]]

return {
	'kyazdani42/nvim-tree.lua',
	version = "*",
	lazy = false,
	dependencies = {
		'nvim-tree/nvim-web-devicons'
	},

	--[[
		Custom settings
		I didn't use the opts = {} thingy here supported by lazy.nvim because due to some reason, the key mapping defined at the end wasn't working, but when I initialized it using config = function() it worked
	--]]
	config = function()
		require('nvim-tree').setup({
			-- Show LSP diagnostics in the signcolumn
			diagnostics = {
				enable = true,
				show_on_dirs = false,
				debounce_delay = 50,
				icons = {
					hint = "",
					info = "",
					warning = "",
					error = "",
				},
			},
			filters = {
				custom = {
					-- Hide the .git folder
					"^.git$"
				}
			}
		})

		-- Keymap for toggling nvim-tree
		map('n', '<C-b>', ':NvimTreeToggle<CR>', { silent = true })
	end
}
