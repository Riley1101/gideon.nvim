local API_KEY = os.getenv("GEMINI_API_KEY")

local function gemini(message, history_json)
	local has_gemini_token = API_KEY and true ~= nil
	if not has_gemini_token then
		print("Please set the GEMINI_API_KEY environment variable")
		return
	end

	local parts_with_history = history_json
	parts_with_history[#parts_with_history + 1] = {
		text = message,
	}
	local data = {
		contents = {
			{
				parts = parts_with_history,
			},
		},
	}

	local json_data = vim.fn.json_encode(data)

	local handle = io.popen(
		"curl -s -H 'Content-Type: application/json' -X POST -d '"
			.. json_data
			.. "' "
			.. "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key="
			.. API_KEY
	)

	---@diagnostic disable-next-line: need-check-nil
	local response = handle:read("*a")

	---@diagnostic disable-next-line: need-check-nil
	handle:close()

	if response == "" then
		print("Error fetching JSON: curl returned empty response")
		return nil, "curl returned empty response"
	end

	local decoded_data, err = vim.fn.json_decode(response)

	if err then
		print("Error decoding JSON:", err, response) -- Print the response for debugging
		return nil, err .. "\nResponse: " .. response -- Include the response in the error
	end

	local result = {}

	if decoded_data and decoded_data.candidates and #decoded_data.candidates > 0 then -- Check for candidates
		local first_candidate = decoded_data.candidates[1]
		if
			first_candidate
			and first_candidate.content
			and first_candidate.content.parts
			and #first_candidate.content.parts > 0
		then
			local first_part = first_candidate.content.parts[1]
			if first_part and first_part.text then
				local generated_text = first_part.text
				result.data = generated_text
			end
		end
	end

	return result, nil
end

return {
	gemini = gemini,
}
