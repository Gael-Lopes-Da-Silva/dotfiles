MiniDeps.later(function()
    local mini_snippets = require('mini.snippets')
    mini_snippets.setup({
        snippets = {
            mini_snippets.gen_loader.from_file('~/.config/nvim/lua/snippets/global.json'),
            mini_snippets.gen_loader.from_lang()
        }
    })
end)
