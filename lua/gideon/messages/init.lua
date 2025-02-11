local history_table = {}

local function push_message_to_history(table, message)
	table[#table + 1] = {
		text = message,
	}
end

return {
	history_table = history_table,
	push_message_to_history = push_message_to_history,
}
