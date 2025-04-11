local opt = vim.opt

opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
opt.expandtab = true
opt.smarttab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.autoread = true
opt.autowrite = true
opt.backup = false
opt.writebackup = false
opt.clipboard:append("unnamedplus")
opt.cursorline = false
opt.cmdheight = 1
opt.mouse = "a"
opt.pumblend = 0
opt.winblend = 0
opt.scrolloff = 5
opt.relativenumber = false
opt.number = false
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "0"
opt.foldtext = ""
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true
opt.redrawtime = 100
opt.updatetime = 250
opt.undofile = true
opt.undolevels = 1000
opt.wrap = true
opt.shortmess = "ItToOcCF"
opt.signcolumn = "yes:1"
opt.winborder = "single"
opt.list = true
opt.breakindentopt = 'list:-1'
opt.fillchars = table.concat({
    'fold:•',
    'eob: ',
}, ',')
opt.listchars = table.concat({
    'tab: ',
    'nbsp:␣',
    'conceal:*',
    'extends:…',
    'precedes:…',
}, ',')
