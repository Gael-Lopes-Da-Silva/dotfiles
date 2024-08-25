require("null-ls").setup({
    border = "single",
	sources = {},
})

require("mason-null-ls").setup({
	ensure_installed = {
		"stylua",
	},
	automatic_installation = false,
	handlers = {},
})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			["start"] = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	vim.lsp.buf.format({ range = range })
end, { range = true })
