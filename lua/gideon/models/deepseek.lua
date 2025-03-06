local API_KEY = os.getenv("DEEPSEEK_API_KEY")

local function deepseek(message, history_json)
	local has_deepseek_token = API_KEY and true ~= nil
	if not has_deepseek_token then
		print("Please set the DEEPSEEK_API_KEY environment variable")
		return
	end

	local parts_with_history = history_json

	parts_with_history[#parts_with_history + 1] = {
		role = "user",
		content = message,
	}

	local data = {
		model = "deepseek-chat",
		stream = false,
		messages = parts_with_history,
	}

	local json_data = vim.fn.json_encode(data)

	-- Construct the curl command
	local curl_command = string.format(
		"curl -s -H 'Content-Type: application/json' -H 'Authorization: Bearer %s' -X POST -d '%s' %s",
		API_KEY,
		json_data,
		"https://api.deepseek.com/chat/completions"
	)

	-- Execute the curl command and capture the response
	local handle = io.popen(curl_command)

	-- Read the response from the handle
	---@diagnostic disable-next-line: need-check-nil
	local response = handle:read("*a")

	---@diagnostic disable-next-line: need-check-nil
	handle:close()

	local decoded_data, err = vim.fn.json_decode(response)

	local result = {}
	if decoded_data and decoded_data.choices and #decoded_data.choices > 0 then -- Check for candidates
		local first_candidate = decoded_data.choices[1]
		if first_candidate and first_candidate.message and first_candidate.message.content then
			result.data = first_candidate.message.content
		end
	end

	return result, nil
end

return {
	deepseek = deepseek,
}
