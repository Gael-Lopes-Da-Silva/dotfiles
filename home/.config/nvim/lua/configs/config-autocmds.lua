local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local create_autocmd = vim.api.nvim_create_autocmd

create_autocmd("TermOpen", {
    desc = "Hide numbers in integrated terminal",
    pattern = { "term://*" },
    group = group,
    command = "setlocal signcolumn=no nonumber norelativenumber | setfiletype terminal",
})

create_autocmd({ "BufAdd", "BufEnter" }, {
    desc = "Hide empty buffers from the tabline",
    group = group,
    callback = function(args)
        local buftype = vim.bo[args.buf].buftype
        local bufname = vim.api.nvim_buf_get_name(args.buf)

        if (buftype == "" or buftype == "nofile") and bufname == "" then
            vim.bo[args.buf].buflisted = false
        end
    end,
})
