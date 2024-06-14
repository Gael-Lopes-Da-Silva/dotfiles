local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mini.animate").setup({
        cursor = { enable = not vim.g.neovide },
        scroll = { enable = false },
    })
end)
