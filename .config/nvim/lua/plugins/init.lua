-- treesitter
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
    require("plugins.nvim-treesitter")
end)

-- mason
MiniDeps.later(function()
    MiniDeps.add({
        source = "williamboman/mason.nvim",
        hooks = {
            post_checkout = function()
                vim.cmd("MasonUpdate")
            end,
        },
    })
    require("plugins.mason")
end)

-- lspconfig
MiniDeps.later(function()
    MiniDeps.add({
        source = "williamboman/mason-lspconfig.nvim",
        depends = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    })
    require("plugins.mason-lspconfig")
end)

-- dap
MiniDeps.later(function()
    MiniDeps.add({
        source = "jay-babu/mason-nvim-dap.nvim",
        depends = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
    })
    require("plugins.mason-nvim-dap")
end)

-- linter
MiniDeps.later(function()
    MiniDeps.add({
        source = "rshkarin/mason-nvim-lint",
        depends = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-lint",
        },
    })
    require("plugins.mason-nvim-lint")
end)

-- conform
MiniDeps.later(function()
    MiniDeps.add({
        source = "zapling/mason-conform.nvim",
        depends = {
            "williamboman/mason.nvim",
            "stevearc/conform.nvim",
        },
    })
    require("plugins.mason-conform")
end)
