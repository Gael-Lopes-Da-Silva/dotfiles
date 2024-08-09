--
-- Treesitter:
--
MiniDeps.later(function()
    MiniDeps.add({
        source = "nvim-treesitter/nvim-treesitter",
        checkout = "master",
        monitor = "main",
        hooks = {
            post_checkout = function()
                vim.cmd("TSUpdate")
            end,
        },
    })
    require("plugins.plugin-nvim-treesitter")
end)

--
-- Mason:
--
MiniDeps.now(function()
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

--
-- Lspconfig:
--
MiniDeps.later(function()
    MiniDeps.add({
        source = "williamboman/mason-lspconfig.nvim",
        depends = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    })
    require("plugins.plugin-mason-lspconfig")
end)

--
-- Dap:
--
MiniDeps.later(function()
    MiniDeps.add({
        source = "jay-babu/mason-nvim-dap.nvim",
        depends = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap",
        },
    })
    require("plugins.plugin-mason-nvim-dap")
end)

--
-- Linter:
--
MiniDeps.later(function()
    MiniDeps.add({
        source = "mfussenegger/nvim-lint",
        depends = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    })
    require("plugins.plugin-nvim-lint")
end)

--
-- Formatter:
--
MiniDeps.later(function()
    MiniDeps.add({
        source = "stevearc/conform.nvim",
        depends = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    })
    require("plugins.plugin-conform")
end)
