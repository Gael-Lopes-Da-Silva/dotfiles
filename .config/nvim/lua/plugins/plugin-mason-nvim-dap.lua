require("mason-nvim-dap").setup({
    ensure_installed = {},
    automatic_installation = false,
    handlers = {},
})

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiffDelete" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiffAdd" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "FoldColumn" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiffText" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DiffChange" })
