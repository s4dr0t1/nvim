--[[
	Name: lazy.lua
	Description: Configuration file for lazy.nvim, used for plugin management since packer.nvim has been deprecated
	Contains: folke/lazy.nvim
--]]

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Define a protected call to lazy.nvim viz. don't run anything related to lazy.nvim if there's some error
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
	return
end

-- Setting up lazy
lazy.setup(
	{
		{ import = "s4dr0t1/plugins" },
		{ import = "s4dr0t1/plugins/lsp" },
	},
	{
		install = {
			-- What colorscheme to use when installing packages at the start
			colorscheme = { "carbonfox" },
		},
		-- Don't notify the user whenever any change has been done to the lazy.nvim configuration file
		change_detection = {
			notify = false,
		},
	}
)

-- Defining the keymap
map("n", "<leader>l", ":Lazy<CR>", { silent = true })
