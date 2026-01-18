--[[-
	Name: Telescope
	Description: Configuration files for the telescope plugin
	Link:
	- https://github.com/nvim-telescope/telescope.nvim
--]]

return {
	'nvim-telescope/telescope.nvim',
	dependencies = {
		'nvim-tree/nvim-web-devicons',
		'nvim-lua/plenary.nvim',
		'neovim/nvim-lspconfig',
		'nvim-treesitter/nvim-treesitter',
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			lazy = true,
			build = "make"
		},
	},

	-- Lazy loading based on keys
	keys = {
		--[[
		map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { silent = true })
		map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { silent = true })
		map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { silent = true })
		map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { silent = true })
	--]]
		-- { "<leader>ff", "<cmd>Telescope find_files<cr>",                       desc = "Find files using Telescope",      mode = "n" },
		{ "<leader>ff",  function() vim.find_files_from_project_git_root() end, desc = "Find files using Telescope with git awareness" },
		{ "<leader>fg",  "<cmd>Telescope live_grep<cr>",                        desc = "Live grep using Telescope",                                                                                                 mode = "n" },
		{ "<leader>fb",  "<cmd>Telescope buffers<cr>",                          desc = "Find buffers using Telescope",                                                                                              mode = "n" },
		{ "<leader>fh",  "<cmd>Telescope help_tags<cr>",                        desc = "Search for tags using Telescope",                                                                                           mode = "n" },

		{ "<leader>fd",  "<cmd>Telescope lsp_definitions<cr>",                  desc = "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope" },
		{ "<leader>ftd", "<cmd>Telescope lsp_type_definitions<cr>",             desc = "Goto the definition of the type of the word under the cursor, if there's only one, otherwise show all options in Telescope" },

		{ "<leader>fi",  "<cmd>Telescope lsp_incoming_calls<cr>",               desc = "Find incoming calls to the current symbol" },
		{ "<leader>fo",  "<cmd>Telescope lsp_outgoing_calls<cr>",               desc = "Find outgoing calls to the current symbol" },
		{ "<leader>fr",  "<cmd>Telescope lsp_references<cr>",                   desc = "Find rerferences to the current symbol" },
		{ "<leader>fs",  "<cmd>Telescope lsp_document_symbols<cr>",             desc = "Search across current file's symbols" },
		{ "<leader>fS",  "<cmd>Telescope lsp_workspace_symbols<cr>",            desc = "Search across symbols across the entire workspace" },

		{ "<leader>gc",  "<cmd>Telescope git_commits<cr>",                      desc = "Git commits" },
		{ "<leader>gb",  "<cmd>Telescope git_branches<cr>",                     desc = "Git branches" },
		{ "<leader>gs",  "<cmd>Telescope git_status<cr>",                       desc = "Git status" },
	},

	config = function()
		-- A helper function to be used later
		local actions = require("telescope.actions")
		local previewers = require("telescope.previewers")
		local Job = require("plenary.job")

		-- Find files from project git root with fallback
		-- This function is basically find_files() combined with git_files(). The appeal of this function over the default find_files() is that you can find files that are not tracked by git. Also, find_files() only finds files in the current directory but this function finds files regardless of your current directory as long as you're in the project directory.
		-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#find-files-from-project-git-root-with-fallback
		function vim.find_files_from_project_git_root()
			local function is_git_repo()
				vim.fn.system("git rev-parse --is-inside-work-tree")
				return vim.v.shell_error == 0
			end
			local function get_git_root()
				local dot_git_path = vim.fn.finddir(".git", ".;")
				return vim.fn.fnamemodify(dot_git_path, ":h")
			end
			local opts = {}
			if is_git_repo() then
				opts = {
					cwd = get_git_root(),
				}
			end
			require("telescope.builtin").find_files(opts)
		end

		-- Live grep from project git root with fallback
		function live_grep_from_project_git_root()
			local function is_git_repo()
				vim.fn.system("git rev-parse --is-inside-work-tree")
				return vim.v.shell_error == 0
			end

			local function get_git_root()
				local dot_git_path = vim.fn.finddir(".git", ".;")
				return vim.fn.fnamemodify(dot_git_path, ":h")
			end

			local opts = {}

			if is_git_repo() then
				opts = {
					cwd = get_git_root(),
				}
			end

			require("telescope.builtin").live_grep(opts)
		end

		-- Don't preview binaries
		local new_maker = function(filepath, bufnr, opts)
			filepath = vim.fn.expand(filepath)
			Job:new({
				command = "file",
				args = { "--mime-type", "-b", filepath },
				on_exit = function(j)
					local mime_type = vim.split(j:result()[1], "/")[1]
					if mime_type == "text" then
						previewers.buffer_previewer_maker(filepath, bufnr, opts)
					else
						-- maybe we want to write something to the buffer here
						vim.schedule(function()
							vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
						end)
					end
				end
			}):sync()
		end

		-- Telescope configuration
		require("telescope").setup({
			defaults = {
				-- Don't preview beyond a certain filesize
				preview = {
					filesize_limit = 1, -- MB
				},
				layout_strategy = "vertical",
				layout_config = {
					horizontal = {
						width = 0.7,
						prompt_position = "bottom"
					},
					vertical = {
						width = 0.7,
						prompt_position = "bottom"
					}
				},

				-- Smart-truncate path for longer path displays
				path_display = { "truncate" },
				-- Trim indentation at the beginning
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--trim"
				},
				buffer_previewer_maker = new_maker,
				mappings = {
					i = {
						-- Esc/ CTRL+C to quit Telescope, instead of putting it into normal mode
						["<esc>"] = actions.close,
						["<C-c>"] = actions.close,

						-- CTRL + L to clear the Telescope screen, instead of scrolling it
						["<C-l>"] = false,

						-- Navigating telescope
						["<C-n>"] = actions.cycle_history_next,
						["<C-p>"] = actions.cycle_history_prev,

						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
			},
			pickers = {
				buffers = {
					show_all_buffers = true,
					sort_lastused = true,
					sort_mru = true,
				},

				-- Remove ./ from fd results
				find_files = {
					theme = "dropdown",
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
				find_command = {
					"fd",
					"--type",
					"f",
					"--strip-cwd-prefix",
					"--hidden", -- Include hidden files
					"--exclude", ".git", -- But exclude .git
				}
			},
			extensions = {
				fzf = {
					-- non exact matching
					fuzzy = true,
					-- override the generic sorter
					override_generic_sorter = true,
					-- override the file sorter
					override_file_sorter = true,
					case_mode = "smart_case",
				}
			}
		})
		require('telescope').load_extension('fzf')
	end
}
