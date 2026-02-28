MiniDeps.now(function()
    require("mini.files").setup({
        options = {
            permanent_delete = true,
            use_as_default_explorer = true,
        },
        windows = {
            max_number = 2,
        },
    })
end)
