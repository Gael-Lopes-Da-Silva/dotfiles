local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("mini.indentscope").setup({
		symbol = "|",
	})
end)
