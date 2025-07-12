local module = require("memos.module")

local M = {}

M.options = {}

M.setup = function(options)
	M.options = vim.tbl_deep_extend('force', M.options, options or {})
end

M.sendToMemos = function()
	module.sendToMemos(M.options)
end

return M
