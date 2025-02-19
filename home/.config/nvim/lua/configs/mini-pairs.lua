MiniDeps.later(function()
    local mini_pairs = require("mini.pairs")
    mini_pairs.setup({
        modes = {
            command = true,
            terminal = true
        }
    })

    vim.keymap.set('i', '<CR>', function()
        local keycode = vim.keycode or function(x)
            return vim.api.nvim_replace_termcodes(x, true, true, true)
        end

        if vim.fn.pumvisible() ~= 0 then
            return vim.fn.complete_info()['selected'] ~= -1 and keycode('<C-y>') or keycode('<C-y><CR>')
        else
            return mini_pairs.cr()
        end
    end, { expr = true })
end)
