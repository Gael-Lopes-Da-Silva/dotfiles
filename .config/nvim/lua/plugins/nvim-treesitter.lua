local now, later = MiniDeps.now, MiniDeps.later

now(function()
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"lua",
			"luadoc",
			"vim",
			"vimdoc",
		},
		sync_install = false,
		auto_install = true,
		modules = {},
		ignore_install = {},
		highlight = { enable = true },
	})

	---@class parser_config
	local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

	parser_config.nu = {
		install_info = {
			url = "https://github.com/nushell/tree-sitter-nu",
			files = { "src/parser.c" },
			branch = "main",
		},
		filetype = "nu",
	}

	parser_config.blade = {
		install_info = {
			url = "https://github.com/EmranMR/tree-sitter-blade",
			files = { "src/parser.c" },
			branch = "main",
		},
		filetype = "blade",
	}
	vim.filetype.add({
		pattern = {
			[".*%.blade%.php"] = "blade",
		},
	})
end)
