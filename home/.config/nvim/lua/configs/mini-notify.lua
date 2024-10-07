MiniDeps.now(function()
	local mini_notify = require("mini.notify")
	mini_notify.setup({
		window = {
			config = {
				border = "single",
			},
		},
	})
	vim.notify = mini_notify.make_notify()
end)
