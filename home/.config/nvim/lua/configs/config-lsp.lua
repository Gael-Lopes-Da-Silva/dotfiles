MiniDeps.now(function()
    vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "",
                [vim.diagnostic.severity.HINT] = "",
            },
        },
        update_in_insert = false,
        virtual_text = {
            prefix = "",
            suffix = " ",
            spacing = 0,
            severity = nil,
            source = "if_many",
        },
        severity_sort = true,
        float = {
            border = "single",
            title = "",
            title_pos = "left",
        },
    })

    -- Configuration for each lsp:
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

    vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        root_markers = { 'compile_commands.json', 'compile_flags.txt' },
        filetypes = { "lua" },
        single_file_support = true,
        settings = {
            Lua = vim.fn.getcwd():match('/%.config/nvim/?') ~= nil and {
                runtime = { version = "LuaJIT" },
                diagnostics = {
                    workspaceDelay = -1,
                    disable = { 'missing-fields' },
                },
                workspace = {
                    checkThirdParty = false,
                    library = vim.api.nvim_get_runtime_file("", true),
                    lazy_load = true,
                    ignoreSubmodules = true,
                },
                telemetry = { enable = false },
            } or {
                runtime = { version = "LuaJIT" },
                telemetry = { enable = false },
            },
        },
    }
    vim.lsp.enable("lua_ls")

    vim.lsp.config.intelephense = {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php" },
        single_file_support = true,
        init_options = {
            globalStoragePath = os.getenv('HOME') .. "/.cache/intelephense",
        },
        settings = {
            intelephense = {
                initialization_options = {
                    globalStoragePath = os.getenv('HOME') .. "/.cache/intelephense",
                },
                telemetry = { enabled = false },
            },
        },
    }
    vim.lsp.enable("intelephense")

    vim.lsp.config.html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html", "templ", "twig" },
        single_file_support = true,
        root_markers = { 'package.json', '.git' },
        init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
                css = true,
                javascript = true,
            },
            provideFormatter = true,
        },
        settings = {},
    }
    vim.lsp.enable("html")

    vim.lsp.config.cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        single_file_support = true,
        init_options = {
            provideFormatter = true
        },
        settings = {
            css = {
                validate = true,
            },
            less = {
                validate = true,
            },
            scss = {
                validate = true,
            },
        },
    }
    vim.lsp.enable("cssls")

    vim.lsp.config.ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        single_file_support = true,
        root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
        init_options = {
            hostInfo = "neovim"
        },
    }
    vim.lsp.enable("ts_ls")

    vim.lsp.config.jsonls = {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        single_file_support = true,
        init_options = {
            provideFormatter = true
        },
    }
    vim.lsp.enable("jsonls")

    vim.lsp.config.serve_d = {
        cmd = { "serve-d" },
        filetypes = { "d" },
        single_file_support = true,
        root_markers = { 'dub.json', 'dub.sdl', '.git' },
    }
    vim.lsp.enable("serve_d")
end)
