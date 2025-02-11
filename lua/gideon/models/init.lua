local gemini = require("gideon.models.gemini")
local deepseek = require("gideon.models.deepseek")

return {
	gemini = gemini.gemini,
	deepseek = deepseek.deepseek,
}
