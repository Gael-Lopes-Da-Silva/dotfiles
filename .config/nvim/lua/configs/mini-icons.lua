MiniDeps.later(function()
	local mini_icons = require("mini.icons")
	mini_icons.setup({
		style = "glyph",
	})
	mini_icons.tweak_lsp_kind()
end)
