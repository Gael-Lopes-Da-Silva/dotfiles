MiniDeps.later(function()
    local mini_snippets = require('mini.snippets')
    mini_snippets.setup({
        snippets = {
            mini_snippets.gen_loader.from_file('~/.config/nvim/lua/configs/config-snippets.json'),
            mini_snippets.gen_loader.from_lang()
        }
    })
end)
