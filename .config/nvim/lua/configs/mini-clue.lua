local now, later = MiniDeps.now, MiniDeps.later

now(function()
    local mini_clue = require("mini.clue")
    mini_clue.setup({
        triggers = {
            { mode = "n", keys = "<Leader>" },
            { mode = "x", keys = "<Leader>" },

            { mode = "n", keys = "\\" },

            { mode = "i", keys = "<C-x>" },

            { mode = "n", keys = "g" },
            { mode = "x", keys = "g" },

            { mode = "n", keys = "[" },
            { mode = "n", keys = "]" },

            { mode = "n", keys = "\"" },
            { mode = "n", keys = "`" },
            { mode = "x", keys = "\"" },
            { mode = "x", keys = "`" },

            { mode = "n", keys = "\"" },
            { mode = "x", keys = "\"" },
            { mode = "i", keys = "<C-r>" },
            { mode = "c", keys = "<C-r>" },

            { mode = "n", keys = "<C-w>" },

            { mode = "n", keys = "z" },
            { mode = "x", keys = "z" },

            { mode = "n", keys = "s" },
            { mode = "x", keys = "s" },
        },
        clues = {
            { mode = "n", keys = "<Leader>l", desc = "LSP" },
            { mode = "n", keys = "<Leader>f", desc = "File" },
            { mode = "n", keys = "<Leader>p", desc = "Pick" },
            { mode = "n", keys = "<Leader>b", desc = "Buffer" },
            { mode = "n", keys = "<Leader>t", desc = "Terminal" },
            { mode = "n", keys = "<Leader>d", desc = "DAP" },
            { mode = "n", keys = "<Leader>g", desc = "Git" },
            mini_clue.gen_clues.builtin_completion(),
            mini_clue.gen_clues.g(),
            mini_clue.gen_clues.marks(),
            mini_clue.gen_clues.registers(),
            mini_clue.gen_clues.windows(),
            mini_clue.gen_clues.z(),
        },
        window = {
            delay = 300
        },
    })
end)
