local create_autocmd = vim.api.nvim_create_autocmd
local create_user_command = vim.api.nvim_create_user_command

local group = vim.api.nvim_create_augroup("UserConfig", {})

create_autocmd({ "BufAdd", "BufEnter" }, {
    desc = "Unlist empty unnamed buffers with special buftype or missing buftype",
    group = group,
    callback = function(args)
        local buftypes = { [""] = true, ["nofile"] = true }

        if buftypes[vim.bo[args.buf].buftype] and vim.api.nvim_buf_get_name(args.buf) == "" then
            vim.bo[args.buf].buflisted = false
        end
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
        rust = "cargo run %",
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

create_user_command("Pipe", function(opts)
    local text
    local start_pos, end_pos
    local word_start, word_end
    local cursor_pos

    if opts.range > 0 then
        start_pos = vim.fn.getpos("'<")
        end_pos = vim.fn.getpos("'>")
        local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

        if #lines == 1 then
            lines[1] = lines[1]:sub(start_pos[3], end_pos[3])
        else
            lines[1] = lines[1]:sub(start_pos[3])
            lines[#lines] = lines[#lines]:sub(1, end_pos[3])
        end

        text = table.concat(lines, "\n")
    else
        cursor_pos = vim.fn.getpos(".")
        local line = vim.api.nvim_get_current_line()
        local col = cursor_pos[3]

        word_start, word_end = line:match("()%S+()")
        while word_start and word_end do
            if word_start <= col and col <= word_end then
                break
            end
            word_start, word_end = line:match("()%S+()", word_end)
        end

        if word_start and word_end then
            text = line:sub(word_start, word_end - 1)
        else
            text = ""
        end
    end

    if text == "" then
        print("No valid text found under cursor or in selection")
        return
    end

    local prefix = text:sub(1, 1)
    local command = text

    if prefix == ":" then
        command = text:sub(2)
        if command == "" then
            print("No command provided after ':'")
            return
        end
        vim.cmd(command)
    elseif prefix == "<" then
        command = text:sub(2)
        if command == "" then
            print("No command provided after '<'")
            return
        end
        local output = vim.fn.system(command)
        if opts.range > 0 then
            vim.api.nvim_buf_set_text(
                0,
                start_pos[2] - 1,
                start_pos[3] - 1,
                end_pos[2] - 1,
                end_pos[3],
                vim.split(output, "\n")
            )
        else
            vim.api.nvim_buf_set_text(
                0,
                cursor_pos[2] - 1,
                word_start - 1,
                cursor_pos[2] - 1,
                word_end - 1,
                vim.split(output, "\n")
            )
        end
    else
        local output = vim.fn.system(text)
        local buf = vim.api.nvim_create_buf(false, true)
        local output_lines = vim.split(output, "\n")
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
        vim.api.nvim_command("vsplit")
        vim.api.nvim_win_set_buf(0, buf)
    end
end, { range = true })
