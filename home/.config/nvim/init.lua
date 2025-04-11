local package_path = vim.fn.stdpath("data") .. "/site/"
local snapshot_path = vim.fn.stdpath("config") .. "/snapshot/"
local log_path = vim.fn.stdpath("data") .. "/logs/mini-deps.log"
local mini_path = package_path .. "pack/deps/start/mini.nvim"

if vim.fn.isdirectory(mini_path) == 0 then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path })
    vim.cmd("packadd mini.nvim | helptags ALL")
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

local mini_deps = require("mini.deps")
mini_deps.setup({ path = { package = package_path, snapshot = snapshot_path, log = log_path } })
mini_deps.add("mini.nvim")

require("plugins")
require("configs")
