require("lspconfig").lua_ls.setup {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
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
        })
    end,
    settings = {
        Lua = {}
    }
}

require("lspconfig.ui.windows").default_options = { border = "single" }
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "FloatBorder" })

local signs = {
    Error = "",
    Warn = "",
    Info = "",
    Hint = "",
    Ok = "",
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

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#fb4934", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#d3869b", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#8ec07c", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#83a598", bg = "#504945" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextOk", { fg = "#b8bb26", bg = "#504945" })
