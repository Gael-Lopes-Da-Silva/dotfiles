MiniDeps.later(function()
    MiniDeps.add({
        source = "nvim-treesitter/nvim-treesitter",
        hooks = {
            post_checkout = function()
                vim.cmd("TSUpdate")
            end,
        },
    })
    require("plugins.plugin-treesitter")
end)

MiniDeps.later(function()
    MiniDeps.add({
        source = "williamboman/mason.nvim",
        hooks = {
            post_checkout = function()
                vim.cmd("MasonUpdate")
            end,
        },
    })
    require("plugins.plugin-mason")
end)

MiniDeps.later(function()
    MiniDeps.add({
        source = "williamboman/mason-lspconfig.nvim",
        depends = {
            "neovim/nvim-lspconfig",
        },
    })
    require("plugins.plugin-lspconfig")
end)
