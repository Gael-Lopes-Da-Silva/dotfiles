require("noice").setup({
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
        },
    },
    presets = {
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
    },
    views = {
        cmdline_popup = {
            border = {
                style = "single",
            },
        },
        cmdline_popupmenu = {
            border = {
                style = "single",
            },
        },
        hover = {
            border = {
                style = "single",
            },
        },
        confirm = {
            border = {
                style = "single",
            },
        },
        popup = {
            border = {
                style = "single",
            },
        },
    },
})

vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#8ec07c" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#8ec07c" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = "#d3869b" })
vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { fg = "#d3869b" })
vim.api.nvim_set_hl(0, "NoiceCompletionItemKindDefault", { fg = "#fbf1c7", bold = true })
vim.api.nvim_set_hl(0, "NoicePopupmenuMatch", { fg = "#fbf1c7", bold = true })
