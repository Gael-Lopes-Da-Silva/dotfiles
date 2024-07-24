MiniDeps.now(function()
    require("mini.statusline").setup({
        content = {
            active = function()
                local diagnostics = require("mini.statusline").section_diagnostics({
                    trunc_width = 75,
                    signs = {
                        ERROR = "",
                        WARN  = "",
                        INFO  = "",
                        HINT  = "",
                        OK    = "",
                    },
                })
                local filename = require("mini.statusline").section_filename({ trunc_width = 140 })
                local git = require("mini.statusline").section_git({ trunc_width = 40 })
                local location = require("mini.statusline").section_location({ trunc_width = 75 })
                local mode, mode_hl = require("mini.statusline").section_mode({ trunc_width = 120 })
                local search = require("mini.statusline").section_searchcount({ trunc_width = 75 })

                return require("mini.statusline").combine_groups({
                    {
                        hl = mode_hl,
                        strings = { mode }
                    },
                    {
                        hl = "MiniStatuslineDevinfo",
                        strings = { diagnostics }
                    },
                    "%<",
                    {
                        hl = "MiniStatuslineFilename",
                        strings = { filename }
                    },
                    "%=",
                    {
                        hl = "MiniStatuslineDevinfo",
                        strings = { git }
                    },
                    {
                        hl = mode_hl,
                        strings = { search, location }
                    },
                })
            end,
        },
    })
end)
