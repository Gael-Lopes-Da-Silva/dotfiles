require("null-ls").setup({
	sources = {},
})

require("mason-null-ls").setup({
	ensure_installed = {
		"stylua",
	},
	automatic_installation = false,
	handlers = {},
})

vim.api.nvim_create_user_command("Format", function()
	vim.lsp.buf.format({ timeout_ms = 2000 })
end, { range = true })
