MiniDeps.later(function()
	MiniDeps.add({
		source = "nvim-treesitter/nvim-treesitter",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
	require("plugins.plugin-nvim-treesitter")
end)

MiniDeps.later(function()
	MiniDeps.add({
		source = "williamboman/mason.nvim",
		hooks = {
			post_checkout = function()
				vim.cmd("MasonUpdate")
			end,
		},
	})
	require("plugins.plugin-nvim-mason")
end)

MiniDeps.later(function()
	MiniDeps.add({
		source = "neovim/nvim-lspconfig",
	})
	require("plugins.plugin-nvim-lspconfig")
end)

MiniDeps.later(function()
	MiniDeps.add({
		source = "mfussenegger/nvim-dap",
	})
	require("plugins.plugin-nvim-dap")
end)
