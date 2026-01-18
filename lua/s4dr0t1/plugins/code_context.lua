--[[
	Name: Code context
	Description: Configuration file for showing code context at the top, powered by Treesitter
	Link: nvim-treesitter/nvim-treesitter-context
--]]

return {
	'nvim-treesitter/nvim-treesitter-context',
	-- VeryLazy events means the plugin can be loaded later because it doesn't affect the UI
	event = 'VeryLazy',
	dependencies = {
		'nvim-treesitter/nvim-treesitter'
	},
	config = function()
		require('treesitter-context').setup({
			-- Number of lines to show as the context, a negative value means no limit
			max_lines = 5,
		})

		-- Jump to context upwards
		vim.keymap.set("n", "[c", function()
			require("treesitter-context").go_to_context(vim.v.count1)
		end, { silent = true })
	end,

}
