require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"luadoc",
		"vim",
		"vimdoc",
	},
	sync_install = false,
	auto_install = true,
	highlight = { enable = true },
    incremental_selection = { enable = true },
    textobjects = { enable = true },
    indent = { enable = true },
})
