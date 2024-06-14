local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mini.pick").setup({
        options = {
            use_cache = true,
        },
    })
end)
