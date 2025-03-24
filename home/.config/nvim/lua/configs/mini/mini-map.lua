MiniDeps.later(function()
    local mini_map = require("mini.map")
    mini_map.setup({
        integrations = {
            mini_map.gen_integration.diff(),
            mini_map.gen_integration.diagnostic(),
            mini_map.gen_integration.builtin_search(),
        },
    })
end)
