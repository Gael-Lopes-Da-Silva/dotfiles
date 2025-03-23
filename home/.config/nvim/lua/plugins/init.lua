MiniDeps.later(function() -- treesitter
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

MiniDeps.later(function() -- lspconfig
    MiniDeps.add({
        source = "neovim/nvim-lspconfig",
    })
    require("plugins.plugin-lspconfig")
end)
