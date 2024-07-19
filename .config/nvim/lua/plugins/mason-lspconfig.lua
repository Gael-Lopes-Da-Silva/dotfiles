MiniDeps.later(function()
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls",
        },
        automatic_installation = false,
        handlers = {
            function(server_name)
                require("lspconfig")[server_name].setup({})
            end,

            lua_ls = function()
                require("lspconfig").lua_ls.setup({
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME,
                                    vim.fn.stdpath("data") .. "/site/pack/deps/start",
                                    vim.fn.stdpath("data") .. "/site/pack/deps/opt",

                                    "${3rd}/luv/library",
                                },
                            },
                            telemetry = { enable = false },
                        },
                    },
                })
            end,
        },
    })

    -- set border
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

    -- set diagnostics icons
    local signs = {
        Error = " ",
        Warn  = " ",
        Info  = " ",
        Hint  = " ",
        Ok    = " ",
    }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    vim.diagnostic.config({
        signs = true,
        update_in_insert = true,
        virtual_text = true,
        severity_sort = true,
        float = {
            border = "single",
        },
    })

    -- change diagnostics virtual text
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", bg = "#504945" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#d3869b", bg = "#504945" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#8ec07c", bg = "#504945" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#83a598", bg = "#504945" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextOk", { fg = "#b8bb26", bg = "#504945" })
end)
