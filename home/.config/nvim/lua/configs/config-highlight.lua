MiniDeps.now(function()
    local set_hl = vim.api.nvim_set_hl

    set_hl(0, "FloatTitle", { fg = "#83a598", bg = "#3c3836" })

    set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", bg = "#504945" })
    set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#d3869b", bg = "#504945" })
    set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#8ec07c", bg = "#504945" })
    set_hl(0, "DiagnosticVirtualTextHint", { fg = "#83a598", bg = "#504945" })
    set_hl(0, "DiagnosticVirtualTextOk", { fg = "#b8bb26", bg = "#504945" })

    set_hl(0, "DapBreakpoint", { fg = "#fb4934", bg = "#3c3836" })
    set_hl(0, "DapBreakpointCondition", { fg = "#d3869b", bg = "#3c3836" })
    set_hl(0, "DapBreakpointRejected", { fg = "#8ec07c", bg = "#3c3836" })
    set_hl(0, "DapLogPoint", { fg = "#83a598", bg = "#3c3836" })
    set_hl(0, "DapStopped", { fg = "#b8bb26", bg = "#3c3836" })

    set_hl(0, "Pmenu", { fg = "#fbf1c7", bg = "#504945" })
    set_hl(0, "PmenuKind", { fg = "#fbf1c7", bg = "#504945", bold = true })
    set_hl(0, "PmenuExtra", { fg = "#fbf1c7", bg = "#504945", bold = true })
    set_hl(0, "PmenuMatch", { fg = "#fbf1c7", bg = "#504945", bold = true })
    set_hl(0, "PmenuSbar", { fg = "#fbf1c7", bg = "#665c54" })
end)
