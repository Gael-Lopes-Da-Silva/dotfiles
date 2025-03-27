MiniDeps.later(function() -- treesitter
    MiniDeps.add({
        source = "nvim-treesitter/nvim-treesitter-textobjects",
        depends = {
            "nvim-treesitter/nvim-treesitter",
        },
        hooks = {
            post_checkout = function()
                vim.cmd("TSUpdate")
            end,
        },
    })
    require("plugins.plugin-treesitter")
end)

MiniDeps.later(function() -- treesitter
    MiniDeps.add({
        source = "nvim-treesitter/nvim-treesitter-refactor",
        depends = {
            "nvim-treesitter/nvim-treesitter",
        },
        hooks = {
            post_checkout = function()
                vim.cmd("TSUpdate")
            end,
        },
    })
    require("plugins.plugin-treesitter")
end)
