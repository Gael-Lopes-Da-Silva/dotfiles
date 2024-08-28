MiniDeps.now(function()
	local set = vim.keymap.set

	--
	-- Default:
	--
	set("n", "U", "<C-r>")
	set("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

	set("n", "<Esc>", function()
		if not require("mini.files").close() then
			vim.cmd.nohlsearch()
			vim.cmd.echo()
		end
	end, { noremap = true })

	--
	-- Completion:
	--
	set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
	set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
	set("i", "<C-S-Space>", vim.lsp.buf.signature_help)

	--
	-- Lsp:
	--
	set("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "LSP Go to declaration" })
	set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP Go to definition" })
	set("n", "<leader>lk", vim.lsp.buf.hover, { desc = "LSP Hover" })
	set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "LSP Go to implementation" })
	set("n", "<leader>lK", vim.lsp.buf.signature_help, { desc = "LSP Signature help" })
	set("n", "<leader>lt", vim.lsp.buf.type_definition, { desc = "LSP Type definition" })
	set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })
	set("n", "<leader>lc", vim.lsp.buf.code_action, { desc = "LSP Code action" })
	set("n", "<leader>lR", vim.lsp.buf.references, { desc = "LSP Go to references" })

	--
	-- Dap:
	--
	set("n", "<F5>", "<cmd> lua require('dap').continue() <cr>")
	set("n", "<F10>", "<cmd> lua require('dap').step_over() <cr>")
	set("n", "<F11>", "<cmd> lua require('dap').step_into() <cr>")
	set("n", "<F12>", "<cmd> lua require('dap').step_out() <cr>")
	set("n", "<leader>ds", "<cmd> lua require('dap').continue() <cr>", { desc = "DAP Start/Continue" })
	set("n", "<leader>do", "<cmd> lua require('dap').step_over() <cr>", { desc = "DAP Step over" })
	set("n", "<leader>di", "<cmd> lua require('dap').step_into() <cr>", { desc = "DAP Step into" })
	set("n", "<leader>dO", "<cmd> lua require('dap').step_out() <cr>", { desc = "DAP Step out" })
	set("n", "<leader>db", "<cmd> lua require('dap').toggle_breakpoint() <cr>", { desc = "DAP Toggle breakpoint" })
	set("n", "<leader>dr", "<cmd> lua require('dap').repl.open() <cr>", { desc = "DAP Open REPL" })
	set("n", "<leader>dR", "<cmd> lua require('dap').run_last() <cr>", { desc = "DAP Run last" })
	set({ "n", "v" }, "<leader>dh", "<cmd> lua require('dap.ui.widgets').hover() <cr>", { desc = "DAP Hover" })
	set({ "n", "v" }, "<leader>dp", "<cmd> lua require('dap.ui.widgets').preview() <cr>", { desc = "DAP Preview" })

	--
	-- Buffer:
	--
	set("n", "<S-Tab>", "<cmd> lua MiniBracketed.buffer('backward') <cr>")
	set("n", "<Tab>", "<cmd> lua MiniBracketed.buffer('forward') <cr>")
    set("n", "<leader>c", "<cmd> lua MiniBufremove.delete() <cr>", { desc = "Close buffer" })
	set("n", "<leader>bn", "<cmd> enew <cr>", { desc = "New buffer" })
	set("n", "<leader>bh", "<cmd> new <cr>", { desc = "New horizontal buffer" })
	set("n", "<leader>bv", "<cmd> vnew <cr>", { desc = "New vertical buffer" })
	set("n", "<leader>bt", "<cmd> tabnew <cr>", { desc = "New tab" })
	set("n", "<leader>bT", "<cmd> tabclose <cr>", { desc = "Close tab" })

	--
	-- File:
	--
	set("n", "<leader>ff", "<cmd> lua MiniFiles.open() <cr>", { desc = "Open file explorer" })
	set("n", "<leader>fc", "<cmd> lua MiniFiles.close() <cr>", { desc = "Close file explorer" })
	set("n", "<leader>fh", "<cmd> lua MiniFiles.show_help() <cr>", { desc = "Show file explorer help" })
	set("n", "<leader>fm", "<cmd> lua MiniMap.toggle() <cr>", { desc = "Toggle mini map" })
	set("n", "<leader>fz", "<cmd> lua MiniMisc.zoom() <cr>", { desc = "Toggle file zoom" })
	set("n", "<leader>ft", "<cmd> lua MiniTrailspace.trim() <cr>", { desc = "Trim trailing whitespace" })
	set("n", "<leader>fT", "<cmd> lua MiniTrailspace.trim_last_lines() <cr>", { desc = "Trim trailing last line" })

	--
	-- Pick:
	--
	set("n", "<leader>pf", "<cmd> lua MiniPick.builtin.files() <cr>", { desc = "Pick files" })
	set("n", "<leader>pb", "<cmd> lua MiniPick.builtin.buffers() <cr>", { desc = "Pick buffers" })
	set("n", "<leader>pg", "<cmd> lua MiniPick.builtin.grep() <cr>", { desc = "Pick grep" })
	set("n", "<leader>pG", "<cmd> lua MiniPick.builtin.grep_live() <cr>", { desc = "Pick grep live" })
	set("n", "<leader>ph", "<cmd> lua MiniPick.builtin.help() <cr>", { desc = "Pick help" })
	set("n", "<leader>pt", "<cmd> lua MiniExtra.pickers.hipatterns() <cr>", { desc = "Pick todos" })
	set("n", "<leader>pd", "<cmd> lua MiniExtra.pickers.diagnostic() <cr>", { desc = "Pick diagnostics" })
	set("n", "<leader>pk", "<cmd> lua MiniExtra.pickers.keymaps() <cr>", { desc = "Pick keymaps" })
	set("n", "<leader>po", "<cmd> lua MiniExtra.pickers.options() <cr>", { desc = "Pick options" })
	set("n", "<leader>pc", "<cmd> lua MiniExtra.pickers.commands() <cr>", { desc = "Pick commands" })
	set("n", "<leader>pr", "<cmd> lua MiniExtra.pickers.registers() <cr>", { desc = "Pick registers" })
	set("n", "<leader>pl", "<cmd> lua MiniExtra.pickers.buf_lines({ scope = 'current' }) <cr>", { desc = "Pick line in buffer" })

	--
	-- Notify:
	--
	set("n", "<leader>nc", "<cmd> lua MiniNotify.clear() <cr>", { desc = "Clear notifications" })
	set("n", "<leader>nh", "<cmd> lua MiniNotify.show_history() <cr>", { desc = "Show history" })

	--
	-- Git:
	--
    set("n", "<leader>gl", "<cmd> LazyGit <cr>", { desc = "Show lazygit" })
	set("n", "<leader>gP", "<cmd> Git pull <cr>", { desc = "Pull" })
	set("n", "<leader>gp", "<cmd> Git push <cr>", { desc = "Push" })
	set("n", "<leader>ga", "<cmd> Git add % <cr>", { desc = "Add" })
	set("n", "<leader>gA", "<cmd> Git add . <cr>", { desc = "Add all" })
	set("n", "<leader>gc", "<cmd> Git commit <cr>", { desc = "Commit" })
	set("n", "<leader>gb", "<cmd> Git blame % <cr>", { desc = "Blame" })
	set("n", "<leader>gs", "<cmd> Git status <cr>", { desc = "Status" })
    set("n", "<leader>gS", "<cmd> lua MiniGit.show_at_cursor() <cr>", { desc = "Show at cursor" })
    set("n", "<leader>gg", "<cmd> lua MiniGit.show_diff_source() <cr>", { desc = "Go to diff source" })
    set("n", "<leader>gh", "<cmd> lua MiniGit.show_range_history() <cr>", { desc = "Show range history" })
    set("n", "<leader>go", "<cmd> lua MiniDiff.toggle_overlay() <cr>", { desc = "Toggle diff overlay" })
	set("n", "<leader>gC", "<cmd> lua MiniExtra.pickers.git_commits() <cr>", { desc = "Show commits" })
	set("n", "<leader>gB", "<cmd> lua MiniExtra.pickers.git_branches() <cr>", { desc = "Show branches" })
	set("n", "<leader>gH", "<cmd> lua MiniExtra.pickers.git_hunks() <cr>", { desc = "Show hunks" })
end)
