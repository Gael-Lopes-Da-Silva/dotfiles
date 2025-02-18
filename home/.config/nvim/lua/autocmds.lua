MiniDeps.now(function()
    local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

    vim.api.nvim_create_autocmd("TermOpen", {
        desc = "Remove number or relative number from terminal",
        pattern = { "term://*" },
        group = group,
        command = "setlocal signcolumn=no nonumber norelativenumber | setfiletype terminal",
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        desc = "Auto source neovim configuration on change",
        pattern = "*/.config/nvim/**.lua",
        group = group,
        callback = function()
            vim.cmd("source " .. vim.fn.expand("<afile>"))
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "Format the buffer on save",
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
            if vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) == "" then
                vim.bo[args.buf].buflisted = false
            end
        end,
    })
end)
