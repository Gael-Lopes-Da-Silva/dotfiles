local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.operators").setup({})
end)
