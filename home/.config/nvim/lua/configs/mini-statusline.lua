MiniDeps.now(function()
    local mini_statusline = require("mini.statusline")
    mini_statusline.setup({
        content = {
            active = function()
                local mode, mode_hl = mini_statusline.section_mode({ trunc_width = 100 })
                local filename = mini_statusline.section_filename({ trunc_width = 100 })
                local fileinfo = mini_statusline.section_fileinfo({ trunc_width = 999 })
                local location = mini_statusline.is_truncated(100) and '%2l│%-2v' or '%2l/%-2L│%2v/%-2{virtcol("$") - 1}'

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
                        strings = { location },
                    },
                })
            end,
        },
    })
end)
