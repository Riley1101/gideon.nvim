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

return {
	get_selected_text = get_selected_text,
	insert_ai_text = insert_ai_text,
}
