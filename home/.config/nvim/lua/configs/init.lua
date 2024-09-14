for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/configs", [[v:val =~ '\.lua$']])) do
	if not (file == "init.lua") then
		require("configs." .. file:gsub("%.lua$", ""))
	end
end
