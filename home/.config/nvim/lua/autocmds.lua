MiniDeps.now(function()
	local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

	vim.api.nvim_create_autocmd("TermOpen", {
		desc = "Remove number or relative number from terminal",
		pattern = { "term://*" },
		group = group,
		command = "setlocal signcolumn=no nonumber norelativenumber | setfiletype terminal",
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		desc = "Format the buffer on save",
		group = group,
		callback = function()
			if vim.g.autoformat then
				vim.lsp.buf.format()
			end
		end,
	})
end)
