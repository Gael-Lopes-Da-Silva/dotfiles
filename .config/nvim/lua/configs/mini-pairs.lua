local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.pairs").setup({
		modes = {
			insert = true,
			command = true,
			terminal = false
		},
	})
end)
