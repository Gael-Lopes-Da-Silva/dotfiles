require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
    },
    sync_install = false,
    auto_install = true,
    modules = {},
    ignore_install = {},
    highlight = { enable = true },
})
