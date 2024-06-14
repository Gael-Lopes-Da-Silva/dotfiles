local now, later = MiniDeps.now, MiniDeps.later

now(function()
	require("mini.sessions").setup({})
end)
