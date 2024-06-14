local now, later = MiniDeps.now, MiniDeps.later

now(function()
    vim.g.mapleader      = " "
    vim.o.autoindent     = true
    vim.o.backup         = false
    vim.o.breakindent    = true
    vim.o.clipboard      = "unnamed,unnamedplus"
    vim.o.expandtab      = true
    vim.o.list           = false
    vim.o.relativenumber = true
    vim.o.shiftwidth     = 4
    vim.o.tabstop        = 4
    vim.o.wrap           = true
    vim.o.scrolloff      = 5
end)
