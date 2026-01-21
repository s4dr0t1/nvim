--[[
	Name: keymaps.lua
	Description: Keymaps independent of any plugin
	Uses vim.keymap.set (Neovim 0.7+) which defaults to noremap=true
--]]

local map = vim.keymap.set

-- Remap <ESC> to jk
map('i', 'jk', '<Esc>')

--[[
	Switching between buffers
	<C-h> move to the left buffer
	<C-l> move to the right buffer
	<C-j> move to the down buffer
	<C-k> move to the upper buffer

	Window management
	Horizontal split                       :hsp <C-w>s
	Vertical split                         :vsp <C-w>v
	Quit the buffer                        :bd  <C-W>q
	Switch b/w the last used pane          <C-W>w
--]]
map('n', '<C-H>', '<C-W>h')
map('n', '<C-J>', '<C-W>j')
map('n', '<C-K>', '<C-W>k')
map('n', '<C-L>', '<C-W>l')


--[[
	Enable buffer resizing
	<C>arrow_keys
--]]
map("n", "<C-Up>", ":resize +2<CR>", { silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

--[[
	Buffer Navigation
	<Shift> + h Move one buffer left
	<Shift> + l Move one buffer right

	-- Make this one work
	<Shift> + w Close the current buffer
--]]
map("n", "<S-l>", ":bnext<CR>", { silent = true })
map("n", "<S-h>", ":bprevious<CR>", { silent = true })
-- map("n", "<Leader>q", ":Bdelete<CR>")


--[[
	After performing one indentation, stay in indentation  mode
	Use <ESC> or <C-c> to get out of it
--]]
map("v", "<", "<gv", { silent = true })
map("v", ">", ">gv", { silent = true })


--[[
	Moving line(s) up or down, similar to how it's done in Visual Studio Code
	Select the lines and use K, J to move them

	-- map('n', 'n', ':m +1<CR>', {noremap = false, silent = true})
	-- map('n', 'm', ':m -2<CR>', {noremap = false, silent = true})
--]]
map("v", "<A-j>", ":m .+1<CR>==", { silent = true })
map("v", "<A-k>", ":m .-2<CR>==", { silent = true })
map("x", "J", ":move '>+1<CR>gv-gv", { silent = true })
map("x", "K", ":move '<-2<CR>gv-gv", { silent = true })
map("x", "<A-j>", ":move '>+1<CR>gv-gv", { silent = true })
map("x", "<A-k>", ":move '<-2<CR>gv-gv", { silent = true })
