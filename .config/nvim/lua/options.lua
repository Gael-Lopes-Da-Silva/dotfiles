MiniDeps.now(function()
	vim.g.autoformat = false

	--
	-- Better indents
	--
	vim.o.autoindent = true
	vim.o.breakindent = true
	vim.o.expandtab = true
	vim.o.smartindent = true

	--
	-- Set indents level
	--
	vim.o.softtabstop = 4
	vim.o.tabstop = 4
	vim.o.shiftwidth = 4

	--
	-- Set encoding:
	--
	vim.o.encoding = "utf-8"
	vim.o.fileencoding = "utf-8"

	--
	-- Enable auto read and write
	--
	vim.o.autoread = true
	vim.o.autowrite = true

	--
	-- Disable backup files
	--
	vim.o.backup = false

	--
	-- Better clipboard
	--
	vim.o.clipboard = "unnamed,unnamedplus"

	--
	-- Set status line height
	--
	vim.o.cmdheight = 1

	--
	-- Better folds
	--
	vim.o.foldcolumn = "0"
	vim.o.foldenable = true
	vim.o.foldexpr = "nvim_treesitter#foldexpr()"
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.foldmethod = "expr"

	--
	-- Better search
	--
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.incsearch = true
	vim.o.smartcase = true

	--
	-- Enable preview of commands effetc
	--
	vim.o.inccommand = "split"

	--
	-- Disable drawing of spaces and tabs
	--
	vim.o.list = false

	--
	-- Enable mouse use everywhere
	--
	vim.o.mouse = "a"

	--
	-- Enable relative line number
	--
	vim.o.relativenumber = true
	vim.o.number = false

	--
	-- Disable popup and windows transparency
	--
	vim.o.pumblend = 0
	vim.o.winblend = 0

	--
	-- Better update and redraw times
	--
	vim.o.redrawtime = 100
	vim.o.updatetime = 250

	--
	-- Better scrolloff
	--
	vim.o.scrolloff = 5

	--
	-- More undo levels
	--
	vim.o.undolevels = 1000

	--
	-- Enable warp
	--
	vim.o.wrap = true
end)
