for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/configs/mini", [[v:val =~ '\.lua$']])) do
    if not (file == "init.lua") then
        require("configs.mini." .. file:gsub("%.lua$", ""))
    end
end
