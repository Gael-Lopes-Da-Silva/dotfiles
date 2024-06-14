local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mini.completion").setup({
        window = {
            info = { border = "single" },
            signature = { border = "single" },
        },
    })
end)
