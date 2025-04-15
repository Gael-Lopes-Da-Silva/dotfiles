local create_user_command = vim.api.nvim_create_user_command

create_user_command("Config", function()
    vim.cmd("cd ~/.config/nvim")
    vim.lsp.stop_client(vim.lsp.get_clients())
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
            Lua = {
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
            },
        },
    })
    vim.cmd("e init.lua")
end, { desc = "Open neovim configuration file" })
