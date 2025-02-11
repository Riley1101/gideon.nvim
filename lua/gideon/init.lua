local models = require("gideon.models")
local vim_utils = require("gideon.vim")
local message = require("gideon.messages")

local default_prompt = [[
	You are a intelligent coding partner, your job is to assist user in his coding project. You will have to sometimes provide what user is asked in correct and working code snippets. Sometimes users will ask to do basic task like renaming variables and rewriting in different format. 
	For example, rename all object to some key etc in that case you just copy and repaste the result without providing code snippets
	For example if user ask like quick sort in js and you only give the snippet without any text. Do not add any examples or how to use just provide a correct test.
]]

-- Function to escape newlines and carriage returns (optional, but recommended)
local function escape_newlines(str)
	return str:gsub("\n", "\\n"):gsub("\r", "\\r") -- Escape \n to \\n and \r to \\r
end

-- Construct the history as a Lua table
local HISTORY_TABLE = message.history_table
local CURRENT_MODEL = "gemini"
local CONFIG = {}

local function setup(c)
	local config = c or {
		prompt = c.prompt or default_prompt,
		model = c.model or "gemini",
	}
	CONFIG = config

	CURRENT_MODEL = config.model
	message.push_message_to_history(HISTORY_TABLE, config.prompt, config.model)
end

local function send_to_model(name)
	local model
	if name == "gemini" then
		model = models.gemini
	elseif name == "deepseek" then
		model = models.deepseek
	end
	return model
end

local function arg_mode(args)
	local text = args[1] -- Get the argument

	local chunks = vim_utils.get_selected_text()

	local input = table.concat(chunks, "\n")

	message.push_message_to_history(
		HISTORY_TABLE,
		string.format("Take a look at this snippet %s", input),
		CURRENT_MODEL
	)

	local ai = send_to_model(CURRENT_MODEL)

	---@diagnostic disable-next-line: unused-local
	local response, _err = ai(text, HISTORY_TABLE)

	---@diagnostic disable-next-line: need-check-nil
	local t = response.data

	vim_utils.insert_ai_text(t)
	-- clear the history , no plan to support multiple context for now
	HISTORY_TABLE = {
		{ text = escape_newlines(default_prompt) }, -- Escape newlines if needed
	}
end

vim.api.nvim_command("command! -nargs=1 Gideongen :lua require('gideon').arg_mode({<f-args>})")

return { setup = setup, arg_mode = arg_mode }
