MiniDeps.now(function()
    local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

    vim.api.nvim_create_autocmd("TermOpen", {
        desc = "Remove number or relative number from terminal",
        pattern = { "term://*" },
        group = group,
        command = "setlocal signcolumn=no nonumber norelativenumber | setfiletype terminal",
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        desc = "Hot reload neovim configuration on save",
        pattern = "*/.config/nvim/**.lua",
        group = group,
        callback = function()
            vim.cmd("Reload")
            vim.cmd("source " .. vim.fn.expand("<afile>"))
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "Format the current buffer on save",
        group = group,
        callback = function()
            if vim.g.autoformat then
                vim.lsp.buf.format()
            end
        end,
    })

    vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
        desc = "Hide empty buffers from the tabline",
        group = group,
        callback = function(args)
            if (vim.bo[args.buf].buftype == "" or vim.bo[args.buf].buftype == "nofile") and vim.api.nvim_buf_get_name(args.buf) == "" then
                vim.bo[args.buf].buflisted = false
            end
        end,
    })
end)
