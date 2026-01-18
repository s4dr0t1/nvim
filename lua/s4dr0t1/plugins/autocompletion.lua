--[[
	Name: autocompletion.lua
	Description: Configuration file for the autocompletion functionality
	Contains configuration for:
		- hrsh7th/nvim-cmp
		- L3MON4D3/LuaSnip
--]]
return {
	-- The core autocompletion plugin
	'hrsh7th/nvim-cmp',
	event = {
		"InsertEnter",
		"CmdlineEnter"
	},

	dependencies = {
		-- Autocompletion from LSP
		'neovim/nvim-lspconfig',
		'hrsh7th/cmp-nvim-lsp',

		-- Autocompletion from buffer
		'hrsh7th/cmp-buffer',

		-- Autocompletion from path
		'hrsh7th/cmp-path',

		-- Autocompletion from .env
		'SergioRibera/cmp-dotenv',

		{
			-- Snippet management engine for neovim
			'L3MON4D3/LuaSnip',
			version = "v2.*",
			build = "make install_jsregexp",
			dependencies = {
				-- A set of ready made snippets in different programming languages
				'rafamadriz/friendly-snippets',

				-- Autocompletion from LuaSnip
				'saadparwaiz1/cmp_luasnip',

				-- If we've finished writing an if block, after its end this plugin would suggest the else/ if-else bloc
				'L3MON4D3/cmp-luasnip-choice'
			},
		},
	},
	config = function()
		-- Loading LuaSnip
		local luasnip = require('luasnip')
		-- Required to make sure friendly-snippets can give snippets to LuaSnip
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Helper function used for SuperTab like mapping in LuaSnip
		local has_words_before = function()
			unpack = unpack or table.unpack
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and
			    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		-- Specifying custom icons for the autocompletion menu
		local kind_icons = {
			Text = "",
			Method = "",
			Function = "󰡱",
			Constructor = "",
			Field = "",
			Variable = "󰫧",
			Class = "",
			Interface = "",
			Module = "",
			Property = "",
			Unit = "",
			Value = "",
			Enum = "",
			Keyword = "",
			Snippet = "",
			Color = "",
			File = "",
			Reference = "",
			Folder = "",
			EnumMember = "",
			Constant = "",
			Struct = "",
			Event = "",
			Operator = "󰐕",
			TypeParameter = "",
		}

		-- Configuring nvim-cmp
		local cmp = require('cmp')
		cmp.setup({
			-- Disable completion in comments and the Telescope
			enabled = function()
				local context = require 'cmp.config.context'
				if vim.api.nvim_get_mode().mode == 'c' then
					return true
					-- Disable autocompletion when using Telescope
				elseif vim.bo.buftype == 'prompt' then
					return false
				else
					return not context.in_treesitter_capture("comment")
					    and not context.in_syntax_group("Comment")
				end
			end,

			view = {
				-- nvim-cmp's own custom menu, because the native one is experimental
				entries = {
					name = 'custom',
					-- When the cursor is at bottom, autocompletion menu starts from above the cursor, this option fixes that
					selection_order = 'near_cursor',
				},
			},

			-- Specifying a snippet engine
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			-- How the autocompletion will look visually
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},

			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
				{ name = "dotenv" },
				{ name = 'luasnip_choice' },
			}),

			-- Keymaps for autocompletion
			--mapping = {
			mapping = cmp.mapping.preset.insert({
				-- Invoke autocomplete
				["<C-Space>"] = cmp.mapping.complete(),

				-- Close the autocompletion box
				['<C-e>'] = cmp.mapping.abort(),

				--[[
					Select the current one from the autocompletion list
					--['<CR>'] = cmp.mapping.confirm({ select = true }),

					Safely select entries with <CR>
					- If nothing is selected (including preselections) add a newline as usual.
					- If something has explicitly been selected by the user, select i
				--]]
				["<CR>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
						else
							fallback()
						end
					end,
					s = cmp.mapping.confirm({ select = true }),
					c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
				}),

				--[[
					Scrolling documentation
					- <C-u> Scroll documentation up
					- <C-d> Scroll documentation down
				--]]
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),

				--[[
					Move down the autocompletion list
					- CTRL + J
					- Tab

					Also confirm candidate on TAB immediately when there's only one completion entry
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
				--]]
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
						if #cmp.get_entries() == 1 then
							cmp.confirm({ select = true })
						end
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					elseif has_words_before() then
						cmp.complete()
						if #cmp.get_entries() == 1 then
							cmp.confirm({ select = true })
						end
					else
						fallback()
					end
				end, { "i", "s" }),

				--[[
					Move up the autocompletion list
					- SHIFT + TAB
					- CTRL + K
				--]]
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),

			-- <C-d> Scroll documentation down
			formatting = {
				format = function(entry, vim_item)
					--[[
						Specifying the custom icons here
						kind_icons[vim_item.kind] means the icon
						vim_item.kind means the type
					--]]
					vim_item.kind = string.format("%s", kind_icons[vim_item.kind])

					-- Specifying the text that would be displayed next to the icon
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						luasnip = "[Snippet]",
						buffer = "[Buffer]",
						path = "[Path]",
						dotenv = "[ENV]",
					})[entry.source.name]
					return vim_item
				end
			},
		})
	end
}
