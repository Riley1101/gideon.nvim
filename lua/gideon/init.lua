local API_KEY = os.getenv("GEMINI_API_KEY")

local system_prompt = [[
	You are a intelligent coding partner, your job is to assist user in his coding project. You will have to sometimes provide what user is asked in correct and working code snippets. Sometimes users will ask to do basic task like renaming variables and rewriting in different format. 
	For example, rename all object to some key etc in that case you just copy and repaste the result without providing code snippets
	For example if user ask like quick sort in js and you only give the snippet without any text. Do not add any examples or how to use just provide a correct test.
]]

-- Function to escape newlines and carriage returns (optional, but recommended)
local function escape_newlines(str)
	return str:gsub("\n", "\\n"):gsub("\r", "\\r") -- Escape \n to \\n and \r to \\r
end

-- Construct the history as a Lua table
local history_table = {
	{ text = escape_newlines(system_prompt) }, -- Escape newlines if needed
}

local function push_message_to_history(history_table, message)
	history_table[#history_table + 1] = {
		text = message,
	}
end

local function send_message(message, history_json)
	-- local content = push_message_to_history(history_table, message)

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

	local response = handle:read("*a")

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

	return decoded_data, nil
end
local function setup()
	local has_gemini_token = API_KEY and true ~= nil
	if not has_gemini_token then
		print("Please set the GEMINI_API_KEY environment variable")
		return
	end
end

local function insert_ai_text(text)
	local lines = vim.split(text, "\n")
	vim.api.nvim_buf_set_lines(0, vim.fn.line("."), vim.fn.line("."), true, lines)
end

local function get_selected_text()
	local selected_text = {}

	-- Get all selected ranges (works for visual, visual block, etc.)
	local ranges = vim.fn.getreg('""', true).ranges -- Get ranges from unnamed register

	if ranges and #ranges > 0 then
		for _, range in ipairs(ranges) do
			local start_line = range.start_line + 1 -- Ranges are 0-indexed
			local end_line = range.end_line + 1
			local start_col = range.start_col + 1
			local end_col = range.end_col + 1

			local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false) -- nvim_buf_get_lines is 0 indexed

			local current_selection = ""

			if start_line == end_line then -- single line selection
				current_selection = string.sub(lines[1], start_col, end_col)
			else
				current_selection = string.sub(lines[1], start_col) .. "\n" -- first line
				for i = 2, #lines - 1 do -- middle lines
					current_selection = current_selection .. lines[i] .. "\n"
				end
				current_selection = current_selection .. string.sub(lines[#lines], 1, end_col) -- last line
			end

			table.insert(selected_text, current_selection)
		end
	else -- if no ranges, try visual mode selection
		local start_line = vim.fn.line("'<")
		local end_line = vim.fn.line("'>")
		local start_col = vim.fn.col("'<")
		local end_col = vim.fn.col("'>")

		if start_line > 0 and end_line > 0 then -- Check if selection exists
			local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false) -- nvim_buf_get_lines is 0 indexed
			local selected_text_str = table.concat(lines, "\n")
			table.insert(selected_text, selected_text_str)
		end
	end

	return selected_text
end

local function generate() end

local function arg_mode(args)
	local text = args[1] -- Get the argument

	local chunks = get_selected_text()

	local input = table.concat(chunks, "\n")

	history_table[#history_table + 1] = {
		text = "Take a look at this snippet " .. input,
	}

	local decoded_data = send_message(text, history_table)

	local response = {}

	if decoded_data.candidates and #decoded_data.candidates > 0 then -- Check for candidates
		local first_candidate = decoded_data.candidates[1]
		if first_candidate.content and first_candidate.content.parts and #first_candidate.content.parts > 0 then
			local first_part = first_candidate.content.parts[1]
			if first_part.text then
				local generated_text = first_part.text
				response.data = generated_text
			end
		end
	end
	local text = response.data
	insert_ai_text(text)
	-- clear the history
	history_table = {
		{ text = escape_newlines(system_prompt) }, -- Escape newlines if needed
	}
end

vim.api.nvim_command("command! -nargs=1 Gideongen :lua require('gideon').arg_mode({<f-args>})")

return { setup = setup, generate = generate, arg_mode = arg_mode }
