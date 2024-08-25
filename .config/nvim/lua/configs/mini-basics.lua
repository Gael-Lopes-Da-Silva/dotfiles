MiniDeps.now(function()
	require("mini.basics").setup({
		options = {
			basic = true,
			extra_ui = true,
			win_borders = "single",
		},
		mappings = {
			basic = true,
			windows = true,
			move_with_alt = true,
		},
		autocommands = {
			basic = true,
		},
	})
end)
