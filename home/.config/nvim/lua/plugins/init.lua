MiniDeps.later(function()
    MiniDeps.add({
        source = "nvim-treesitter/nvim-treesitter",
        hooks = {
            post_checkout = function()
                vim.cmd("TSUpdate")
            end,
        },
    })
    MiniDeps.add({
        source = "nvim-treesitter/nvim-treesitter-textobjects",
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

MiniDeps.add({
    source = "nvim-lua/plenary.nvim",
})

MiniDeps.later(function()
    MiniDeps.add({
        source = "williamboman/mason-lspconfig.nvim",
        depends = {
            "neovim/nvim-lspconfig",
        },
    })
    require("plugins.plugin-lspconfig")
end)

MiniDeps.later(function()
    MiniDeps.add({
        source = "jay-babu/mason-nvim-dap.nvim",
        depends = {
            "mfussenegger/nvim-dap",
        },
    })
    require("plugins.plugin-nvim-dap")
end)

MiniDeps.later(function()
    MiniDeps.add({
        source = "jay-babu/mason-null-ls.nvim",
        depends = {
            "nvimtools/none-ls.nvim",
        },
    })
    require("plugins.plugin-null-ls")
end)
