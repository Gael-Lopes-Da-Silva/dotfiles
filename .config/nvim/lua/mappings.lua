MiniDeps.now(function()
    local set = vim.keymap.set

    -- default
    set("i", "jk", "<ESC>")
    set("n", "U", "<C-r>")
    set("n", "<TAB>", "<C-^>")
    set("t", "<C-q>", "<C-\\><C-n>")
    set("t", "jk", "<C-\\><C-n>")
    set("n", "<Esc>", function()
        require("mini.files").close()
        vim.cmd.nohlsearch()
        vim.cmd.echo()
    end, { noremap = true })

    -- lsp
    set("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "LSP Go to declaration" })
    set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP Go to definition" })
    set("n", "<leader>lk", vim.lsp.buf.hover, { desc = "LSP Hover" })
    set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "LSP Go to implementation" })
    set("n", "<leader>lK", vim.lsp.buf.signature_help, { desc = "LSP Signature help" })
    set("n", "<leader>lt", vim.lsp.buf.type_definition, { desc = "LSP Type definition" })
    set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })
    set("n", "<leader>lc", vim.lsp.buf.code_action, { desc = "LSP Code action" })
    set("n", "<leader>lR", vim.lsp.buf.references, { desc = "LSP Go to references" })
    set({ "n", "v" }, "<leader>lf", vim.lsp.buf.format, { desc = "LSP Format" })

    -- dap
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

    -- buffer
    set("n", "<leader>c", function()
        require("mini.files").close()
        require("mini.bufremove").delete()
    end, { desc = "Close buffer" })
    set("n", "<leader>bn", "<cmd> enew <cr>", { desc = "New buffer" })
    set("n", "<leader>bh", "<cmd> new <cr>", { desc = "New horizontal buffer" })
    set("n", "<leader>bv", "<cmd> vnew <cr>", { desc = "New vertical buffer" })
    set("n", "<leader>bt", "<cmd> tabnew <cr>", { desc = "New tab" })
    set("n", "<leader>bT", "<cmd> tabclose <cr>", { desc = "Close tab" })

    -- terminal
    set("n", "<leader>tn", "<cmd> terminal <cr> cd expand('%:p:h') <cr>", { desc = "Open terminal" })
    set("n", "<leader>th", "<cmd> horizontal terminal <cr> cd expand('%:p:h') <cr>",
        { desc = "Open hotizontal terminal" })
    set("n", "<leader>tv", "<cmd> vertical terminal <cr> cd expand('%:p:h') <cr>", { desc = "Open vertical terminal" })

    -- completion
    set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
    set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

    -- file
    set("n", "<leader>fF", "<cmd> Format <cr>", { desc = "Format file" })
    set("n", "<leader>ff", "<cmd> lua MiniFiles.open() <cr>", { desc = "Open file explorer" })
    set("n", "<leader>fc", "<cmd> lua MiniFiles.close() <cr>", { desc = "Close file explorer" })
    set("n", "<leader>fr", "<cmd> lua MiniFiles.refresh() <cr>", { desc = "Refresh file explorer" })
    set("n", "<leader>fR", "<cmd> lua MiniFiles.reset() <cr>", { desc = "Reset file explorer" })
    set("n", "<leader>fh", "<cmd> lua MiniFiles.show_help() <cr>", { desc = "Show file explorer help" })
    set("n", "<leader>fs", "<cmd> lua MiniFiles.synchronize() <cr>", { desc = "Synchronize file explorer" })
    set("n", "<leader>fm", "<cmd> lua MiniMap.toggle() <cr>", { desc = "Toggle mini map" })

    -- pick
    set("n", "<leader>pf", "<cmd> lua MiniPick.builtin.files() <cr>", { desc = "Pick files" })
    set("n", "<leader>pb", "<cmd> lua MiniPick.builtin.buffers() <cr>", { desc = "Pick buffers" })
    set("n", "<leader>pg", "<cmd> lua MiniPick.builtin.grep() <cr>", { desc = "Pick grep" })
    set("n", "<leader>pG", "<cmd> lua MiniPick.builtin.grep_live() <cr>", { desc = "Pick grep live" })
    set("n", "<leader>ph", "<cmd> lua MiniPick.builtin.help() <cr>", { desc = "Pick help" })
    set("n", "<leader>pd", "<cmd> lua MiniExtra.pickers.diagnostic() <cr>", { desc = "Pick diagnostics" })
    set("n", "<leader>pk", "<cmd> lua MiniExtra.pickers.keymaps() <cr>", { desc = "Pick keymaps" })
    set("n", "<leader>pc", "<cmd> lua MiniExtra.pickers.commands() <cr>", { desc = "Pick commands" })
    set("n", "<leader>pl", "<cmd> lua MiniExtra.pickers.buf_lines({ scope = 'current' }) <cr>",
        { desc = "Pick line in buffer" })

    -- git
    set("n", "<leader>gP", "<cmd> Git pull <cr>", { desc = "Pull" })
    set("n", "<leader>gp", "<cmd> Git push <cr>", { desc = "Push" })
    set("n", "<leader>ga", "<cmd> Git add % <cr>", { desc = "Add" })
    set("n", "<leader>gA", "<cmd> Git add . <cr>", { desc = "Add all" })
    set("n", "<leader>gc", "<cmd> Git commit <cr>", { desc = "Commit" })
    set("n", "<leader>gs", "<cmd> Git status <cr>", { desc = "Status" })
    set("n", "<leader>gC", "<cmd> lua MiniExtra.pickers.git_commits() <cr>", { desc = "Show commits" })
    set("n", "<leader>gS", "<cmd> lua MiniGit.show_at_cursor() <cr>", { desc = "Show at cursor" })
end)
