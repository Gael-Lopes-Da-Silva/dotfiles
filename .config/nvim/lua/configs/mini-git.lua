local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.git").setup({})
end)
