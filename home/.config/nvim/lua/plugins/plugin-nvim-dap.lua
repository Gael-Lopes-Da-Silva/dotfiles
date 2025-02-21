require("mason-nvim-dap").setup({
    ensure_installed = {},
    automatic_installation = false,
    handlers = {},
})

for type, icon in pairs({
    Breakpoint = "",
    BreakpointCondition = "",
    BreakpointRejected = "",
    LogPoint = "",
    Stopped = "",
}) do
    local hl = "Dap" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#fb4934", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#d3869b", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#8ec07c", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#83a598", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#b8bb26", bg = "#3c3836" })
