local create_autocmd = vim.api.nvim_create_autocmd

local group = vim.api.nvim_create_augroup("UserConfig", {})

create_autocmd({ "BufAdd", "BufEnter" }, {
    desc = "Unlist empty unnamed buffers with no or special buftype",
    group = group,
    callback = function(args)
        local buftypes = { [""] = true, ["nofile"] = true }

        if buftypes[vim.bo[args.buf].buftype] and vim.api.nvim_buf_get_name(args.buf) == "" then
            vim.bo[args.buf].buflisted = false
        end
    end,
})

create_autocmd('BufWinEnter', {
    desc = "Removes title from minicompletion windows",
    group = group,
    callback = function(args)
        local completion_type = vim.api.nvim_buf_get_name(args.buf):match('^minicompletion://%d+/(.*)$')
        if completion_type == nil then return end

        local win_id = vim.fn.win_findbuf(args.buf)[1]
        local config = vim.api.nvim_win_get_config(win_id)
        config.title = ""
        vim.api.nvim_win_set_config(win_id, config)
    end,
})
