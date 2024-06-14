local now, later = MiniDeps.now, MiniDeps.later

now(function()
    require("mini.basics").setup({
        options = {
            extra_ui = true,
            win_borders = "single",
        },
        mappings = {
            windows = true,
        },
    })
end)
