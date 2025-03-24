MiniDeps.later(function()
    local mini_extra = require("mini.extra")
    require("mini.ai").setup({
        custom_textobjects = {
            B = mini_extra.gen_ai_spec.buffer(),
            D = mini_extra.gen_ai_spec.diagnostic(),
            I = mini_extra.gen_ai_spec.indent(),
            L = mini_extra.gen_ai_spec.line(),
            N = mini_extra.gen_ai_spec.number(),
        },
    })
end)
