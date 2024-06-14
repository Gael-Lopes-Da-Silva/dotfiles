local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.bufremove").setup({})
end)
