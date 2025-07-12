local M = {}

local function escape_json_string(str)
	str = str:gsub("\\", "\\\\")
	str = str:gsub("\"", "\\\"")
	str = str:gsub("\n", "\\n")
	str = str:gsub("\r", "\\r")
	str = str:gsub("\t", "\\t")
	str = str:gsub("'", "'\\''")
	return str
end

local function postMemo(content, api_token, base_url)
	local payload = string.format(
		'{"state":"NORMAL","content":"%s","visibility":"PRIVATE","pinned": false}',
		escape_json_string(content)
	)

	-- format base_url (remove trailing whitespaces and slashes)
	base_url = base_url:gsub("%s+$", "")
	base_url = base_url:gsub("/+$", "")


	local cmd = string.format(
		"curl %s/api/v1/memos --request POST --header 'Content-Type: application/json' --header 'Authorization: Bearer %s' --data '%s' -sS",
		base_url,
		api_token,
		payload
	)

	-- TODO better error handling.
	-- notify user if this command run succesfull. maybe even parse output of curl command.
	local handle = io.popen(cmd, "r")
	if handle == nil then
		return
	end
	local output = handle:read("*a")
	handle:close()
end

M.sendToMemos = function(opts)
	-- TODO error handling if not present
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local bufferContent = table.concat(lines, "\n")
	postMemo(bufferContent, opts.api_key, opts.base_url)
	vim.notify("Sent to Memos")
end

return M
