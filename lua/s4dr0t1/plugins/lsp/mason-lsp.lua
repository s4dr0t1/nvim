--[[
	Name: Mason, the LSP manager
	Description: Contains configuration for
		- Mason registry settings viz. where should mason get its information from regarding that tools are there and where to get them from
		- What LSP shit must mason-tool-installer install, should it auto upgrade shit and stuff
	Contains configuration for:
		- williamboman/mason.nvim
		- williamboman/mason-tool-installer.nvim
--]]

return {
	'williamboman/mason.nvim',
	dependencies = {
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	},

	keys = {
		-- map('n', '<leader>m', ':Mason<CR>', { silent = true })
		{ '<leader>m', ':Mason<CR>', mode = 'n' },
	},

	config = function()
		-- Local variables to be used later
		local mason = require('mason')
		local mason_installer = require('mason-tool-installer')

		-- Setting up mason.nvim
		mason.setup({
			--[[
				-- Mason has its own registry where it downloads the packages from, those can be overwritten
				registries = {
					-- "github:maosn-org/mason-registry"

				},
			--]]
			pip = {
				-- Upgrade pip to the latest version in the virtualenv before installing packages
				upgrade_pip = true,
			},

		})

		-- Setting up mason-tool-installer
		mason_installer.setup({
			--[[
				By default when specifying ensure_installed, mason-tool-installer is expecting Mason names.
				If mason-lspconfig is installed, mason-tool-installer can accept lspconfig package names as well
				https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
			--]]
			ensure_installed = {
				--[[
					-- you can pin a tool to a particular version
					{ 'golangci-lint', version = 'v1.47.0' },

					-- you can turn off/on auto_update per tool
					{ 'bash-language-server', auto_update = true },
				--]]

				-- LSP
				-- I'm using the lspconfig names here instead of the mason names
				'asm_lsp',
				'bashls',
				'jsonls',
				'lua_ls',
				'clangd',
				'pyright',
				'rust_analyzer',
				'tsserver',
				'marksman',
				'yamlls',
				'vale_ls',

				-- Formatters
				'shfmt',
				'black',
				'beautysh',

				-- Linters
				'shellcheck',
				'actionlint',
				'gitleaks',
				'vale'
			},

			-- Language servers
			auto_update = false,

			-- Automatically install / update on startup. If set to false nothing
			run_on_start = true,

			-- Set a delay (ms) before the installation starts
			start_delay = 3000
		})
	end
}
