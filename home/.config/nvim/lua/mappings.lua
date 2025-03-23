MiniDeps.now(function()
    local set = vim.keymap.set

    -- Default
    set("t", "<C-q>", "<C-\\><C-n>")
    set("n", "<Esc>", function()
        if not require("mini.files").close() then
            vim.cmd.nohlsearch()
            vim.cmd.echo()
        end
    end, { noremap = true })

    -- Completion
    set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
    set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
    set("i", "<C-Space>", "<cmd>lua MiniCompletion.complete_twostage()<cr>", { desc = "Signature help" })
    set("i", "<C-S-Space>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "Signature help" })

    -- LSP
    set("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "Declaration" })
    set("n", "<leader>lH", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "Signature help" })
    set("n", "<leader>lR", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "References" })
    set("n", "<leader>lc", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code action" })
    set("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Definition" })
    set("n", "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "Hover" })
    set("n", "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "Implementation" })
    set("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
    set("n", "<leader>lt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", { desc = "Type definition" })

    -- Buffers
    set("n", "<S-Tab>", "<cmd>lua MiniBracketed.buffer('backward')<cr>")
    set("n", "<Tab>", "<cmd>lua MiniBracketed.buffer('forward')<cr>")
    set("n", "<leader>d", "<cmd>lua MiniBufremove.delete()<cr>", { desc = "Delete buffer" })
    set("n", "<leader>bd", "<cmd>lua MiniBufremove.delete()<cr>", { desc = "Delete" })
    set("n", "<leader>bD", "<cmd>lua MiniBufremove.delete(0, true)<cr>", { desc = "Delete!" })
    set("n", "<leader>bw", "<cmd>lua MiniBufremove.wipeout()<cr>", { desc = "Wipeout" })
    set("n", "<leader>bW", "<cmd>lua MiniBufremove.wipeout(0, true)<cr>", { desc = "Wipeout!" })

    -- Files
    set("n", "<leader>ff", "<cmd>lua MiniFiles.open()<cr>", { desc = "Files" })
    set("n", "<leader>ft", "<cmd>lua MiniTrailspace.trim()<cr>", { desc = "Trim whitespace" })
    set("n", "<leader>fT", "<cmd>lua MiniTrailspace.trim_last_lines()<cr>", { desc = "Trim last line" })

    -- Pickers
    set("n", "<leader>pG", "<cmd>lua MiniPick.builtin.grep_live()<cr>", { desc = "Grep live" })
    set("n", "<leader>pb", "<cmd>lua MiniPick.builtin.buffers()<cr>", { desc = "Buffers" })
    set("n", "<leader>pf", "<cmd>lua MiniPick.builtin.files()<cr>", { desc = "Files" })
    set("n", "<leader>pg", "<cmd>lua MiniPick.builtin.grep()<cr>", { desc = "Grep" })
    set("n", "<leader>ph", "<cmd>lua MiniPick.builtin.help()<cr>", { desc = "Help" })
    set("n", "<leader>p/", "<cmd>lua MiniExtra.pickers.history({ scope = '/' })<cr>", { desc = "Search history" })
    set("n", "<leader>p:", "<cmd>lua MiniExtra.pickers.history({ scope = ':' })<cr>", { desc = "Commands hitory" })
    set("n", "<leader>pd", "<cmd>lua MiniExtra.pickers.diagnostic()<cr>", { desc = "Diagnostics" })
    set("n", "<leader>pk", "<cmd>lua MiniExtra.pickers.keymaps()<cr>", { desc = "Keymaps" })
    set("n", "<leader>pl", "<cmd>lua MiniExtra.pickers.buf_lines({ scope = 'current' })<cr>", { desc = "Lines" })
    set("n", "<leader>po", "<cmd>lua MiniExtra.pickers.options()<cr>", { desc = "Options" })
    set("n", "<leader>pr", "<cmd>lua MiniExtra.pickers.registers()<cr>", { desc = "Registers" })
    set("n", "<leader>pt", "<cmd>lua MiniExtra.pickers.hipatterns()<cr>", { desc = "Todos" })
    set("n", "<leader>pc", "<cmd>lua MiniExtra.pickers.hl_groups()<cr>", { desc = "Colors" })

    -- Notifications
    set("n", "<leader>nc", "<cmd>lua MiniNotify.clear()<cr>", { desc = "Clear" })
    set("n", "<leader>nh", "<cmd>lua MiniNotify.show_history()<cr>", { desc = "History" })

    -- Git
    set("n", "<leader>gA", "<cmd>Git add .<cr>", { desc = "Add all" })
    set("n", "<leader>gC", "<cmd>Git commit --amend<cr>", { desc = "Commit amend" })
    set("n", "<leader>gP", "<cmd>Git pull<cr>", { desc = "Pull" })
    set("n", "<leader>ga", "<cmd>Git add %<cr>", { desc = "Add" })
    set("n", "<leader>gb", "<cmd>Git blame %<cr>", { desc = "Blame" })
    set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Commit" })
    set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Log" })
    set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Push" })
    set("n", "<leader>gs", "<cmd>Git status<cr>", { desc = "Status" })
    set("n", "<leader>go", "<cmd>lua MiniDiff.toggle_overlay()<cr>", { desc = "Diff overlay" })

    -- Toggles
    set("n", "\\m", "<cmd>lua MiniMap.toggle()<cr>", { desc = "Toggle 'minimap'" })
    set("n", "\\z", "<cmd>lua MiniMisc.zoom()<cr>", { desc = "Toggle 'zoom'" })
    set("n", "\\d", "<cmd>lua MiniBasics.toggle_diagnostic()<cr>", { desc = "Toggle 'diagnostics'" })
    set("n", "\\h", "<cmd>set hlsearch!<cr>", { desc = "Toggle 'search highlight'" })
end)
