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
	-- don't post empty content:
	if not content or content == "" then
		return
	end

	-- Payload string for Memos api
	local payload = string.format(
		'{"state":"NORMAL","content":"%s","visibility":"PRIVATE","pinned": false}',
		escape_json_string(content)
	)

	-- format base_url (remove trailing whitespaces and slashes)
	base_url = base_url:gsub("%s+$", "")
	base_url = base_url:gsub("/+$", "")


	local cmd = string.format(
		"curl %s/api/v1/memos --request POST --header 'Content-Type: application/json' --header 'Authorization: Bearer %s' --data '%s' --max-time 10 -sS 2>&1",
		base_url,
		api_token,
		payload
	)

	local handle = io.popen(cmd, "r")
	if not handle then
		vim.notify("[memos.nvim] Failed to run curl", vim.log.levels.ERROR)
		return
	end
	local output = handle:read("*a")
	handle:close()

	-- Empty output = likely a timeout or network failure
	if not output or output == "" then
		vim.notify("[memos.nvim] NO response from server.", vim.log.levels.ERROR)
		return
	end

	-- Try to parse JSON response
	local ok, decoded = pcall(vim.fn.json_decode, output)
	if not ok or type(decoded) ~= "table" then
		vim.notify("[memos.nvim] Unexpected response: \n" .. output, vim.log.levels.ERROR)
		return
	end

	-- API returned an error object
	if decoded.message or (decoded.code and decoded.code ~= 0) then
		vim.notify("[memos.nvim] Error response: \n" .. (decoded.message or "") .. " " .. (decoded.code or ""),
			vim.log.levels.ERROR)
		return
	end

	vim.notify("Memo saved!", vim.log.levels.INFO)
end

M.sendToMemos = function(opts)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local bufferContent = table.concat(lines, "\n")
	postMemo(bufferContent, opts.api_key, opts.base_url)
end

return M
