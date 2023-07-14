local M = { log = {} }

M.levels = {
	trace = "Comment",
	debug = "Comment",
	info = "None",
	warn = "WarningMsg",
	error = "ErrorMsg",
}

M._log = function(message, color)
	color = color or M.levels.OFF
	vim.api.nvim_echo({ { message, color } }, true, {})
end

for k, v in pairs(M.levels) do
	M.log[k] = function(...)
		return M._log(..., v)
	end
end

return M
