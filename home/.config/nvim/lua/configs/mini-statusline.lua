MiniDeps.now(function()
    local mini_statusline = require("mini.statusline")
    mini_statusline.setup({
        content = {
            active = function()
                local mode, mode_hl = mini_statusline.section_mode({ trunc_width = 120 })
                local filename = mini_statusline.section_filename({ trunc_width = 140 })
                local location = mini_statusline.section_location({ trunc_width = 75 })
                local search = mini_statusline.section_searchcount({ trunc_width = 75 })
                local fileinfo = mini_statusline.section_fileinfo({ trunc_width = 999 })

                return mini_statusline.combine_groups({
                    {
                        hl = mode_hl,
                        strings = { mode },
                    },
                    "%<",
                    {
                        hl = "MiniStatuslineFilename",
                        strings = { filename },
                    },
                    "%=",
                    {
                        hl = "MiniStatuslineFileinfo",
                        strings = { fileinfo },
                    },
                    {
                        hl = mode_hl,
                        strings = { search, location },
                    },
                })
            end,
        },
    })
end)
