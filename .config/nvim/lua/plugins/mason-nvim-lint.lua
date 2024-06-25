local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mason-nvim-lint").setup({
        ensure_installed = {},
        automatic_installation = false,
    })
end)
