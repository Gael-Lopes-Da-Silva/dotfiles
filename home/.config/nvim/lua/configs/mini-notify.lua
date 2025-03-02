MiniDeps.now(function()
    local mini_notify = require("mini.notify")
    mini_notify.setup({
        window = {
            config = {
                border = "single",
            },
            winblend = 0,
        },
    })
    vim.notify = mini_notify.make_notify()

    vim.api.nvim_set_hl(0, "MiniNotifyTitle", { fg = "#83a598", bg = "#3c3836" })
end)
