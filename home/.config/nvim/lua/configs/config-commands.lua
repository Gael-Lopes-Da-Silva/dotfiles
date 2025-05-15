local create_autocmd = vim.api.nvim_create_autocmd
local create_user_command = vim.api.nvim_create_user_command

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

create_autocmd({ 'BufWrite', 'BufWinLeave' }, {
    desc = "Save folds when saving or closing a buffer",
    group = group,
    callback = function()
        vim.cmd('silent! mkview')
    end,
})

create_autocmd('BufWinEnter', {
    desc = "Load saved folds when openning a buffer",
    group = group,
    callback = function()
        vim.cmd('silent! loadview')
    end,
})

create_user_command("Compile", function()
    local languages = {
        c = "clang % -o %:r",
        cpp = "clang++ % -o %:r",
        python = "python %",
        java = "javac %",
        rust = "rustc %",
        go = "go build %",
        javascript = "node %",
        typescript = "tsc %",
        sh = "bash %",
        ruby = "ruby %",
        lua = "lua %",
        php = "php %",
        r = "Rscript %",
    }

    local filetype = vim.bo.filetype
    local cmd = languages[filetype]
    if not cmd then
        vim.notify("No compile command defined for filetype: " .. filetype, vim.log.levels.WARN)
        return
    end

    cmd = cmd:gsub("%%:r", vim.fn.expand("%:r"))
    cmd = cmd:gsub("%%", vim.fn.expand("%"))

    vim.cmd("write")
    vim.cmd("belowright 10split | terminal " .. cmd)
    vim.cmd("startinsert")
end, {})
