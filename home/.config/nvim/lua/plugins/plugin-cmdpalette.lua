require("cmdpalette").setup({
    win = {
        height = 0.2,
        width = 0.5,
        border = "single",
        row_off = -2,
    },
    buf = {
        filetype = "cmdpalette",
        syntax = "",
    },
    show_title = false,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "cmdpalette",
    callback = function()
        vim.b.minicompletion_disable = true

        vim.keymap.set('i', '<Tab>', function()
            if vim.fn.pumvisible() == 1 then
                local key = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
                vim.api.nvim_feedkeys(key, "i", false)
            else
                local key = vim.api.nvim_replace_termcodes("<C-x><C-v><C-p><C-n>", true, false, true)
                vim.api.nvim_feedkeys(key, "i", false)
            end
        end, { buffer = true })

        vim.keymap.set('i', '<S-Tab>', function()
            if vim.fn.pumvisible() == 1 then
                local key = vim.api.nvim_replace_termcodes("<C-p>", true, false, true)
                vim.api.nvim_feedkeys(key, "i", false)
            else
                local key = vim.api.nvim_replace_termcodes("<C-x><C-v><C-p><C-p>", true, false, true)
                vim.api.nvim_feedkeys(key, "i", false)
            end
        end, { buffer = true })

        vim.keymap.set("n", "<Return>", "<Esc><cmd> lua require('cmdpalette').execute_cmd() <cr>", { buffer = true })
    end,
})

vim.keymap.set("n", ":", "<Plug>(cmdpalette)")
