local dir = vim.fn.stdpath("config") .. "/lua/configs/mini"
local files = vim.fn.readdir(dir)

for _, file in ipairs(files) do
    if file:match("%.lua$") and not (file == "init.lua") then
        require("configs.mini." .. file:gsub("%.lua$", ""))
    end
end
