local augroup = "GideonScratch"

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
	{
		role = "system",
		parts = {
			{ text = escape_newlines(system_prompt) }, -- Escape newlines if needed
		},
	},
}

-- Convert the Lua table to a JSON string
local history_json = vim.fn.json_encode(history_table)

local function send_message(message, history_json)
	local data = {
		contents = {
			{
				parts = {
					{ text = system_prompt }, -- Use the 'system_prompt' variable here
					{ text = message }, -- Use the 'message' argument here
				},
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

local function create_buffer()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buf, "*gideon-scratch*")
	vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
	return buf
end

local function main()
	local buf = create_buffer()

	vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "-- Welcome to Gideon!", "" })

	vim.api.nvim_win_set_buf(0, buf)

	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 0 })
end

local function setup()
	local augroup = vim.api.nvim_create_augroup(augroup, { clear = true })

	vim.api.nvim_create_autocmd(
		"VimEnter",
		{ group = augroup, desc = "Set a fennel scratch buffer on load", once = true, callback = main }
	)
end

local function fetch_dummy_json(callback, selected_text)
	local url = "https://jsonplaceholder.typicode.com/todos/1"

	local handle = io.popen("curl -s " .. url) -- Execute curl command
	local response = handle:read("*a") -- Read all output from curl
	handle:close() -- Close the handle

	if response == "" then -- Check for empty response (curl error)
		print("Error fetching JSON: curl returned empty response")
		callback(nil, "curl returned empty response")
		return
	end

	local data, err = vim.fn.json_decode(response)

	if err then
		print("Error decoding JSON:", err)
		callback(nil, err)
		return
	end

	callback(data, nil)
end

local function insert_ai_text(text)
	local lines = vim.split(text, "\n")

	vim.api.nvim_buf_set_lines(0, vim.fn.line("."), vim.fn.line("."), true, lines)
end

local function generate()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local response = {}

	local selected_text = vim.fn.getline(".")

	local decoded_data = send_message(selected_text, history_json)
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
end

local function arg_mode(args)
	local text = args[1] -- Get the argument

	local decoded_data = send_message(text, history_json)
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
end

vim.api.nvim_command("command! -nargs=1 Gideongen :lua require('gideon').arg_mode({<f-args>})")

return { setup = setup, generate = generate, arg_mode = arg_mode }
