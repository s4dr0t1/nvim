--[[
	Name: neovim Surround
	Description: Configuration file for nvim-surround, allows changing from "" to '' and stuff
	Contains: kylechui/nvim-surround

--]]

return {
	"kylechui/nvim-surround",
	version = "*",
	event = {
		"BufReadPre",
		"BufNewFile"
	},

	-- Similar to plugin.setup({})
	opts = {}
}
