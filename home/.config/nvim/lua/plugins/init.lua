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
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
        },
    })
    require("plugins.plugin-lspconfig")
end)

MiniDeps.later(function()
    MiniDeps.add({
        source = "jay-babu/mason-nvim-dap.nvim",
        depends = {
            "mfussenegger/nvim-dap",
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
        },
    })
    require("plugins.plugin-nvim-dap")
end)

MiniDeps.later(function()
    MiniDeps.add({
        source = "jay-babu/mason-null-ls.nvim",
        depends = {
            "nvimtools/none-ls.nvim",
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
        },
    })
    require("plugins.plugin-null-ls")
end)
