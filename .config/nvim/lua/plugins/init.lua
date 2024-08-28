--
-- Treesitter:
--
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

--
-- Mason:
--
MiniDeps.later(function()
	MiniDeps.add({
		source = "williamboman/mason.nvim",
		hooks = {
			post_checkout = function()
				vim.cmd("MasonUpdate")
			end,
		},
	})
	require("plugins.plugin-mason")
end)

--
-- Lspconfig:
--
MiniDeps.later(function()
	MiniDeps.add({
		source = "williamboman/mason-lspconfig.nvim",
		depends = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"nvim-lua/plenary.nvim",
		},
	})
	require("plugins.plugin-mason-lspconfig")
end)

--
-- Null-ls:
--
MiniDeps.later(function()
	MiniDeps.add({
		source = "jay-babu/mason-null-ls.nvim",
		depends = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
			"nvim-lua/plenary.nvim",
		},
	})
	require("plugins.plugin-mason-null-ls")
end)

--
-- Dap:
--
MiniDeps.later(function()
	MiniDeps.add({
		source = "jay-babu/mason-nvim-dap.nvim",
		depends = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
			"nvim-lua/plenary.nvim",
		},
	})
	require("plugins.plugin-mason-nvim-dap")
end)

--
-- Lazygit:
--
MiniDeps.later(function()
	MiniDeps.add({
		source = "kdheepak/lazygit.nvim",
		depends = {
			"nvim-lua/plenary.nvim",
		},
	})
	require("plugins.plugin-lazygit")
end)
