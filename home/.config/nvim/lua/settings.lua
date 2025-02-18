MiniDeps.now(function()
	vim.g.autoformat = false
    vim.g.markdown_folding = 1

	-- Indentation settings
    vim.opt.autoindent = true
    vim.opt.smartindent = true
    vim.opt.breakindent = true
    vim.opt.expandtab = true
    vim.opt.smarttab = true
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4

    -- Encoding
    vim.opt.encoding = "utf-8"
    vim.bo.fileencoding = "utf-8"

    -- Shell
    vim.opt.shell = "nu"
    vim.opt.shellcmdflag = "-c"

    -- Auto read/write
    vim.opt.autoread = true
    vim.opt.autowrite = true

    -- Disable backup files
    vim.opt.backup = false
    vim.opt.writebackup = false

    -- Clipboard
	vim.opt.clipboard = "unnamed,unnamedplus"

    -- UI & usability improvements
    vim.opt.cmdheight = 1
    vim.opt.list = false
    vim.opt.mouse = "a"
    vim.opt.pumblend = 0
    vim.opt.winblend = 0
    vim.opt.scrolloff = 5

    -- Status line and numbering
    vim.wo.relativenumber = true
    vim.wo.number = false

    -- Folding
    vim.opt.foldcolumn = "0"
    vim.opt.foldenable = true
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldmethod = "expr"
    vim.opt.foldtext = ""

    -- Searching
	vim.opt.hlsearch = true
	vim.opt.ignorecase = true
	vim.opt.incsearch = true
	vim.opt.smartcase = true

    -- Performance optimizations
    vim.opt.redrawtime = 100
    vim.opt.updatetime = 250

    -- Undo options
    vim.opt.undofile = true
    vim.opt.undolevels = 1000

    -- Wrapping
    vim.opt.wrap = true

    -- Disable intro screen
    vim.opt.shortmess = "ItToOCF"
end)
