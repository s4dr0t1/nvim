--[[
	Name: Bracket pairing
	Description: Pair autocompletion for [], {}, () and the likes
	Link: windwp/nvim-autopairs
--]]

return {
	'windwp/nvim-autopairs',
	event = {
		"InsertEnter",
	},
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
		'hrsh7th/nvim-cmp',
	},

	-- Hooking into the LSP to augment autocompletion
	-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#nvim-autopairs
	config = function()
		local autopairs = require("nvim-autopairs").setup({})
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp")

		-- Make autopairs and completion work together
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end
}
