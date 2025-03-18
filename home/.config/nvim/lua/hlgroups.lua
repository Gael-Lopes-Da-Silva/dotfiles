local function highlight(group, fg, bg, attr)
    local cmd = "hi " .. group .. " "
    if fg then cmd = cmd .. "guifg=" .. fg .. " " end
    if bg then cmd = cmd .. "guibg=" .. bg .. " " end
    if attr then cmd = cmd .. "gui=" .. attr .. " " end
    vim.cmd(cmd)
end

highlight("FloatTitle", "#83a598", "#3c3836")

highlight("DiagnosticVirtualTextError", "#fb4934", "#504945")
highlight("DiagnosticVirtualTextWarn", "#d3869b", "#504945")
highlight("DiagnosticVirtualTextInfo", "#8ec07c", "#504945")
highlight("DiagnosticVirtualTextHint", "#83a598", "#504945")
highlight("DiagnosticVirtualTextOk", "#b8bb26", "#504945")

highlight("DapBreakpoint", "#fb4934", "#3c3836")
highlight("DapBreakpointCondition", "#d3869b", "#3c3836")
highlight("DapBreakpointRejected", "#8ec07c", "#3c3836")
highlight("DapLogPoint", "#83a598", "#3c3836")
highlight("DapStopped", "#b8bb26", "#3c3836")

highlight("Pmenu", "#fbf1c7", "#504945")
highlight("PmenuKind", "#fbf1c7", "#504945", "bold")
highlight("PmenuExtra", "#fbf1c7", "#504945", "bold")
highlight("PmenuMatch", "#fbf1c7", "#504945", "bold")
highlight("PmenuSbar", "#fbf1c7", "#665c54")
