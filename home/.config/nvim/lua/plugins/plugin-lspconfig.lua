local servers = {
    lua_ls = {
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
    },
    intelephense = {
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
    },
    html = {
        filetypes = {
            "html",
            "php",
            "templ",
            "twig",
        },
    },
    emmet_ls = {
        init_options = {
            html = {
                options = {
                    ["bem.enable"] = true,
                },
            },
        },
        filetypes = {
            "astro",
            "css",
            "eruby",
            "html",
            "htmldjango",
            "javascriptreact",
            "less",
            "pug",
            "php",
            "sass",
            "scss",
            "svelte",
            "typescriptreact",
            "twig",
            "vue",
            "htmlangular",
        },
    },
    cssls = {},
    ts_ls = {},
    jsonls = {},
    serve_d = {},
}

for name, config in pairs(servers) do
    require("lspconfig")[name].setup(config)
end

for type, icon in pairs({
    Error = "",
    Warn = "",
    Info = "",
    Hint = "",
    Ok = "",
}) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    signs = true,
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
    },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "single",
    title = "Hover",
    title_pos = "left",
    focusable = false,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "single",
    title = "Signature",
    title_pos = "left",
    focusable = false,
})
