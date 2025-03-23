MiniDeps.now(function()
    vim.g.autoformat = false
    vim.g.autosource = true

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
    vim.opt.mouse = "a"
    vim.opt.pumblend = 0
    vim.opt.winblend = 0
    vim.opt.scrolloff = 5
    vim.opt.cursorlineopt = 'screenline,number'

    -- Status line and numbering
    vim.wo.relativenumber = false
    vim.wo.number = false

    -- Folding
    vim.opt.foldenable = true
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldcolumn = "0"
    vim.opt.foldtext = ""

    -- Formatting
    vim.opt.formatexpr = "v:lua.require('conform').formatexpr()"

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
    vim.opt.showbreak = '󱞶 '

    -- Disable intro screen
    vim.opt.shortmess = "ItToOCF"

    -- Sign column
    vim.opt.signcolumn = "yes:1"

    -- Special characters
    vim.opt.list = true
    vim.opt.breakindentopt = 'list:-1'
    vim.opt.fillchars = table.concat({
        'fold:╌',
        'eob: ',
    }, ',')
    vim.opt.listchars = table.concat({
        'tab: ',
        'nbsp:␣',
        'conceal:*',
        'extends:…',
        'precedes:…',
    }, ',')
end)
