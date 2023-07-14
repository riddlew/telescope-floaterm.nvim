local log = require("log").log

local M = {}

Config = {}

local defaults = {
	hl_groups = {
		bufnum = "JumperDirectory",
		title = "JumperFile",
	},
}

function M.setup(opts)
	opts = opts or {}
	Config = vim.tbl_deep_extend("force", defaults, opts)
end

return M
