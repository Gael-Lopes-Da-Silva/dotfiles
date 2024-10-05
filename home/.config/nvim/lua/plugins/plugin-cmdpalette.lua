require("cmdpalette").setup({
    win = {
        height = 0.2,
        width = 0.5,
        border = "single",
        row_off = -2,
    },
    show_title = false,
})

vim.keymap.set("n", ":", "<Plug>(cmdpalette)")
