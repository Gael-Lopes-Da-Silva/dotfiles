local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.comment").setup({})
end)
