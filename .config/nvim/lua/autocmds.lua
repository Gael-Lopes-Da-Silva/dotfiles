MiniDeps.now(function()
	vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
		desc = "Check if we need to reload the file when it changed",
		command = "checktime",
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		desc = "Don't show any numbers inside terminals",
		pattern = { "term://*" },
		command = "setlocal signcolumn=no nonumber norelativenumber | setfiletype terminal",
	})

	vim.api.nvim_create_autocmd({ "VimResized" }, {
		desc = "Resize splits if window got resized",
		callback = function()
			local current_tab = vim.fn.tabpagenr()
			vim.cmd("tabdo wincmd =")
			vim.cmd("tabnext " .. current_tab)
		end,
	})

	-- vim.api.nvim_create_autocmd("BufWritePre", {
	-- 	desc = "Format the buffer when saved",
	-- 	callback = function()
	-- 		vim.lsp.buf.format({ timeout_ms = 3000 })
	-- 	end,
	-- })
end)
