MiniDeps.now(function()
    vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
            local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
            range = {
                ["start"] = { args.line1, 0 },
                ["end"] = { args.line2, end_line:len() },
            }
        end
        vim.lsp.buf.format({ range = range })
    end, { range = true })

    vim.api.nvim_create_user_command("AutoFormat", function()
        vim.g.autoformat = not vim.g.autoformat
    end, {})

    vim.api.nvim_create_user_command("Compile", function()
        local commands = {
            bash = "bash %",
            go = "go run .",
            javascript = "node %",
            lua = "lua %",
            nim = "nim c -r %",
            python = "python %",
            rust = "cargo run",
            sh = "sh %",
        }

        local command = commands[vim.bo.filetype]
        vim.cmd(command ~= nil and "!" .. command or "echo 'Configuration not set for current file'")
    end, {})
end)
