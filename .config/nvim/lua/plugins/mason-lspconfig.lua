local now, later = MiniDeps.now, MiniDeps.later

later(function()
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls",
        },
        automatic_installation = false,
        handlers = {
            function(server_name)
                if server_name == "lua_ls" then
                    require("lspconfig")[server_name].setup({
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT",
                                },
                                workspace = {
                                    checkThirdParty = false,
                                    library = vim.api.nvim_get_runtime_file("", true),
                                },
                                telemetry = { enable = false },
                            },
                        },
                    })
                    return
                end

                require("lspconfig")[server_name].setup({})
            end,
        },
    })

    -- set border
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

    -- set completion icons
    local icons = {
        Class         = " 󰠱 ",
        Color         = "  ",
        Constant      = " 󰏿 ",
        Constructor   = "  ",
        Enum          = "  ",
        EnumMember    = "  ",
        Event         = "  ",
        Field         = "  ",
        File          = "  ",
        Folder        = "  ",
        Function      = " 󰊕 ",
        Interface     = "  ",
        Keyword       = " 󰌋 ",
        Method        = "  ",
        Module        = " 󰏓 ",
        Operator      = "  ",
        Property      = "  ",
        Reference     = "  ",
        Snippet       = " 󰲋 ",
        Struct        = " 󰠱 ",
        Text          = "  ",
        TypeParameter = " 󰘦 ",
        Unit          = "  ",
        Unknown       = " ? ",
        Value         = "  ",
        Variable      = "  ",
    }
    local kinds = vim.lsp.protocol.CompletionItemKind
    for i, kind in ipairs(kinds) do
        kinds[i] = icons[kind] or kind
    end

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
        update_in_insert = false,
        virtual_text = true,
        severity_sort = true,
        float = {
            border = "single",
        },
    })

    -- change diagnostics highlight ground
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = false, undercurl = true })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { underline = false, undercurl = true })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { underline = false, undercurl = true })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = false, undercurl = true })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineOk", { underline = false, undercurl = true })
end)
