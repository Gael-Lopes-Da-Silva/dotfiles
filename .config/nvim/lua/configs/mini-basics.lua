local now, later = MiniDeps.now, MiniDeps.later

now(function()
    require("mini.basics").setup({
        options = {
            extra_ui = false,
            win_borders = "single",
        },
        mappings = {
            windows = true,
        },
    })
end)
