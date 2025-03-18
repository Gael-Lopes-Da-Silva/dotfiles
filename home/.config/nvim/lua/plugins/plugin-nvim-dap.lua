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
