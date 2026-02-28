MiniDeps.now(function()
    local mini_notify = require("mini.notify")
    mini_notify.setup({
        window = {
            config = {
                title = "",
                border = "single",
            },
            winblend = 0,
        },
    })
    vim.notify = mini_notify.make_notify()
end)
