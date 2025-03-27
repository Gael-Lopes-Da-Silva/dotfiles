MiniDeps.now(function()
    local opt = vim.opt

    vim.g.autoformat = false

    -- Indentation settings
    opt.autoindent = true
    opt.smartindent = true
    opt.breakindent = true
    opt.expandtab = true
    opt.smarttab = true
    opt.tabstop = 4
    opt.softtabstop = 4
    opt.shiftwidth = 4

    -- Encoding
    opt.encoding = "utf-8"
    opt.fileencoding = "utf-8"

    -- Auto read/write
    opt.autoread = true
    opt.autowrite = true

    -- Disable backup files
    opt.backup = false
    opt.writebackup = false

    -- Clipboard
    opt.clipboard:append("unnamedplus")

    -- UI & usability improvements
    opt.cmdheight = 1
    opt.mouse = "a"
    opt.pumblend = 0
    opt.winblend = 0
    opt.scrolloff = 5
    opt.cursorlineopt = 'screenline,number'

    -- Status line and numbering
    opt.relativenumber = false
    opt.number = false

    -- Folding
    opt.foldenable = true
    opt.foldmethod = "expr"
    opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    opt.foldlevel = 99
    opt.foldlevelstart = 99
    opt.foldcolumn = "0"
    opt.foldtext = ""

    -- Searching
    opt.hlsearch = true
    opt.ignorecase = true
    opt.incsearch = true
    opt.smartcase = true

    -- Performance optimizations
    opt.redrawtime = 100
    opt.updatetime = 250

    -- Undo options
    opt.undofile = true
    opt.undolevels = 1000

    -- Wrapping
    opt.wrap = true
    opt.showbreak = '󱞶 '

    -- Disable intro screen
    opt.shortmess = "ItToOcCF"

    -- Sign column
    opt.signcolumn = "yes:1"

    -- Window settings
    opt.winborder = "single"

    -- Special characters
    opt.list = true
    opt.breakindentopt = 'list:-1'
    opt.fillchars = table.concat({
        'fold:╌',
        'eob: ',
    }, ',')
    opt.listchars = table.concat({
        'tab: ',
        'nbsp:␣',
        'conceal:*',
        'extends:…',
        'precedes:…',
    }, ',')
end)
