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
            require("lspconfig").lua_ls.setup(vim.fn.getcwd():match('/%.config/nvim/?') ~= nil and {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = {
                            workspaceDelay = -1,
                            disable = { 'missing-fields' }
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                            lazy_load = true,
                            ignoreSubmodules = true,
                        },
                        telemetry = { enable = false },
                    },
                },
            } or {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        telemetry = { enable = false },
                    },
                },
            })
        end,

        intelephense = function()
            require("lspconfig").intelephense.setup({
                init_options = {
                    globalStoragePath = os.getenv('HOME') .. "/.cache/intelephense"
                },
                settings = {
                    intelephense = {
                        initialization_options = {
                            globalStoragePath = os.getenv('HOME') .. "/.cache/intelephense"
                        },
                        telemetry = { enabled = false },
                    }
                }
            })
        end
    },
})

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
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "single",
})
