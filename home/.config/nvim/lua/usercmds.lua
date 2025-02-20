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

    vim.api.nvim_create_user_command("Reload", function()
        for name, _ in pairs(package.loaded) do
            if name:match('^cnull') then
                package.loaded[name] = nil
            end
        end

        dofile(vim.env.MYVIMRC)
    end, {})
end)
