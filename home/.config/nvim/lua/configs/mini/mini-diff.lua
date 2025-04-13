MiniDeps.later(function()
    require("mini.diff").setup({
        view = {
            style = (vim.go.number or vim.go.relativenumber) and "number" or "sign",
            signs = {
                add = "",
                change = "",
                delete = "",
            },
            priority = 10;
        },
    })
end)
