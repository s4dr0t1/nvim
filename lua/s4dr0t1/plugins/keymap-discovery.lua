--[[
	Name: Keymap discovery (folke/which-key.nvim)
	Description: which-key is used for keymap discoverability, we can't remember everything at once
	Contains: folke/which-key.nvim
--]]

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
