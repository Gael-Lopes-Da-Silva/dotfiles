MiniDeps.now(function()
	vim.o.autoindent = true
	vim.o.autoread = true
	vim.o.autowrite = true
	vim.o.backup = false
	vim.o.breakindent = true
	vim.o.clipboard = "unnamed,unnamedplus"
	vim.o.cmdheight = 1
	vim.o.expandtab = true
	vim.o.foldexpr = "nvim_treesitter#foldexpr()"
	vim.o.foldlevelstart = 99
	vim.o.foldmethod = "expr"
	vim.o.inccommand = "split"
	vim.o.list = false
	vim.o.number = false
	vim.o.pumblend = 0
	vim.o.redrawtime = 100
	vim.o.relativenumber = true
	vim.o.scrolloff = 5
	vim.o.shiftwidth = 4
	vim.o.tabstop = 4
	vim.o.undolevels = 1000
	vim.o.updatetime = 250
	vim.o.winblend = 0
	vim.o.wrap = true
end)
