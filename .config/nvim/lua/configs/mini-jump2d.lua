local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mini.jump2d").setup({
        mappings = {
            start_jumping = "<Leader>fj",
        },
    })
end)
