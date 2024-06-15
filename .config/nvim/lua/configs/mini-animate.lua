local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mini.animate").setup({
        scroll = { enable = false },
    })
end)
