-- Install mini.nvim
local package_path = vim.fn.stdpath("data") .. "/site/"
local mini_path = package_path .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
    vim.fn.system(clone_cmd)
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Configure mini.deps
local mini_deps = require("mini.deps")
mini_deps.setup({ path = { package = package_path } })
mini_deps.add("mini.nvim")

-- User defined config
require("configs.init")
require("options")
require("mappings")
require("plugins.init")
