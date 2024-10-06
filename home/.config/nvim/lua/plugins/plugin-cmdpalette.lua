require("cmdpalette").setup({
    win = {
        height = 0.2,
        width = 0.5,
        border = "single",
        row_off = -2,
    },
    buf = {
        filetype = "cmdpalette",
        syntax = "vim",
    },
    show_title = false,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "cmdpalette",
    callback = function()
        vim.b.minicompletion_disable = true
        vim.keymap.set('i', '<Tab>', "<c-x><c-v>", { buffer = true })
        vim.keymap.set("n", "l", "<Esc><cmd> lua require('cmdpalette').execute_cmd() <cr>", { buffer = true })
    end,
})

vim.keymap.set("n", ":", "<Plug>(cmdpalette)")
