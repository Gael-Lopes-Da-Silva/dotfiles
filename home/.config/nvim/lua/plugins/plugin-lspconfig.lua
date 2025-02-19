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
                        runtime = { version = "LuaJIT" },
                        diagnostics = { workspaceDelay = -1 },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                            lazy_load = true,
                            ignoreSubmodules = true,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },
})

for type, icon in pairs({ Error = "", Warn = "", Info = "", Hint = "", Ok = "" }) do
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

require("lspconfig.ui.windows").default_options = { border = "single" }
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "FloatBorder" })

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#d3869b", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#8ec07c", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#83a598", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextOk", { fg = "#b8bb26", bg = "#504945" })

vim.api.nvim_set_hl(0, "Pmenu", { fg = "#fbf1c7", bg = "#504945" })
vim.api.nvim_set_hl(0, "PmenuKind", { fg = "#fbf1c7", bg = "#504945", bold = true })
vim.api.nvim_set_hl(0, "PmenuExtra", { fg = "#fbf1c7", bg = "#504945", bold = true })
vim.api.nvim_set_hl(0, "PmenuMatch", { fg = "#fbf1c7", bg = "#504945", bold = true })
vim.api.nvim_set_hl(0, "PmenuSbar", { fg = "#fbf1c7", bg = "#665c54" })
