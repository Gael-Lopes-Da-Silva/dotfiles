MiniDeps.now(function()
	require("mini.diff").setup({
		view = {
			style = (vim.o.number or vim.o.relativenumber) and "number" or "sign",
			signs = {
				add = "+",
				change = "~",
				delete = "-",
			},
		},
	})
end)
