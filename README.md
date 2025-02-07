# gideon.nvim

Neovim plugin with GEMINI's power.

## Features

- **Visual Selection:** Select code chunks in visual mode (character, line, or block).
- **AI-Powered Actions:** Send the selected code to an AI assistant (currently supports [specify supported AI assistants, e.g., OpenAI's API]).
- **Action Variety:** Perform various actions, including (but not limited to):
  - Code formatting (re-indenting, style adjustments)
  - Code refactoring (renaming variables, extracting functions)
  - Code generation (filling in missing parts, generating test cases)
  - Code translation (converting between languages)
  - Code explanation (receiving comments and explanations)
- **Result Integration:** The AI's response is integrated back into your Neovim buffer, replacing the selected chunk.

## Preview

![Gideon.nvim Demo](https://raw.githubusercontent.com/Riley1101/gideon.nvim/refs/heads/main/preview/demo.gif)

## Installation

This plugin requires a Neovim installation with Lua support. Install using your preferred plugin manager (e.g., Packer, vim-plug):

**Packer:**

```lua
use { "Riley1101/gideon.nvim" }
```

**vim-plug:**

```vim
Plug 'Riley1101/gideon.nvim'
```

## Configuration

The plugin uses a Lua configuration table located at `lua/yourconfig/ai_chunk_processor.lua`. Example configuration:

```lua
{
	name = "gideon",
	config = function()
		local gideon = require("gideon")
		gideon.setup()
	end,
}
```

**Note:** Make sure you have `"GEMINI_API_KEY"` in your shell environment variables.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License.
