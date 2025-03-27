require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
    },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true },
    textobjects = {
        select = { enable = true },
        swap = { enable = true },
        move = { enable = true },
        lsp_interop = { enable = true },
    },
    refactor = {
        highlight_definitions = { enable = true },
        highlight_current_scope = { enable = true },
        smart_rename = { enable = true },
        navigation = { enable = true },
    },
})
