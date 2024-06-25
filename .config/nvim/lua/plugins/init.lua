local add = MiniDeps.add

-- treesitter
add({
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

-- mason
add({
    source = "williamboman/mason.nvim",
    hooks = {
        post_checkout = function()
            vim.cmd("MasonUpdate")
        end,
    },
})
require("plugins.mason")

-- lspconfig
add({
    source = "williamboman/mason-lspconfig.nvim",
    depends = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
    },
})
require("plugins.mason-lspconfig")

-- dap
add({
    source = "jay-babu/mason-nvim-dap.nvim",
    depends = {
        "williamboman/mason.nvim",
        "mfussenegger/nvim-dap",
    },
})
require("plugins.mason-nvim-dap")

-- linter
add({
    source = "rshkarin/mason-nvim-lint",
    depends = {
        "williamboman/mason.nvim",
        "mfussenegger/nvim-lint",
    },
})
require("plugins.mason-nvim-lint")

-- conform
add({
    source = "zapling/mason-conform.nvim",
    depends = {
        "williamboman/mason.nvim",
        "stevearc/conform.nvim",
    },
})
require("plugins.mason-conform")

-- nerd font icons
add({ source = "nvim-tree/nvim-web-devicons" })
require("plugins.nvim-web-devicons")
