local now, later = MiniDeps.now, MiniDeps.later

later(function()
	require("nvim-web-devicons").setup({})
end)
