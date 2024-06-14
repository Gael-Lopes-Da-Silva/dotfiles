local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.bracketed").setup({})
end)
