MiniDeps.now(function()
	local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

	vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
		desc = "Check if we need to reload the file when it changed",
		group = group,
		command = "checktime",
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		desc = "Don't show any numbers inside terminals",
		pattern = { "term://*" },
		group = group,
		command = "setlocal signcolumn=no nonumber norelativenumber | setfiletype terminal",
	})

	vim.api.nvim_create_autocmd("VimResized", {
		desc = "Resize splits if window got resized",
		group = group,
		callback = function()
			local current_tab = vim.fn.tabpagenr()
			vim.cmd("tabdo wincmd =")
			vim.cmd("tabnext " .. current_tab)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		desc = "Format the buffer when saved",
		group = group,
		callback = function()
			if vim.g.autoformat then
				vim.lsp.buf.format()
			end
		end,
	})
end)
