local history_table = {}

local function push_message_to_history(table, message, model)
	if model == "gemini" then
		table[#table + 1] = {
			text = message,
		}
	elseif model == "deepseek" then
		table[#table + 1] = {
			role = "user",
			content = message,
		}
	end
end

return {
	history_table = history_table,
	push_message_to_history = push_message_to_history,
}
