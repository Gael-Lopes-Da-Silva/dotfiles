-- Documentation for each lsp
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

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
    virtual_text = true,
    severity_sort = true,
})

vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc" },
    single_file_support = true,
    formatters = {
        ignoreComments = false,
    },
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
})

vim.lsp.enable("intelephense")
vim.lsp.config("intelephense", {
    cmd = { "intelephense", "--stdio" },
    filetypes = { "php" },
    single_file_support = true,
    root_markers = { 'composer.json' },
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
})

vim.lsp.enable("html")
vim.lsp.config("html", {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ", "twig" },
    single_file_support = true,
    root_markers = { 'package.json' },
    init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = {
            css = true,
            javascript = true,
        },
        provideFormatter = true,
    },
    settings = {},
})

vim.lsp.enable("cssls")
vim.lsp.config("cssls", {
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
})

vim.lsp.enable("ts_ls")
vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    single_file_support = true,
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json' },
    init_options = {
        hostInfo = "neovim"
    },
})

vim.lsp.enable("jsonls")
vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    single_file_support = true,
    init_options = {
        provideFormatter = true
    },
})

vim.lsp.enable("pylsp")
vim.lsp.config("pylsp", {
    cmd = { "pylsp" },
    filetypes = { "python" },
    single_file_support = true,
})

vim.lsp.config('*', { capabilities = require("mini.completion").get_lsp_capabilities() })
