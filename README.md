# gideon.nvim

This Neovim plugin allows you to visually select chunks of code and leverage an AI assistant to perform actions on them. It's designed to seamlessly integrate into your Neovim workflow, making it easy to offload repetitive or complex code manipulation tasks.

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
- **Configuration:** Customizable settings allow you to fine-tune the interaction with the AI assistant (API keys, model selection, etc.).

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

MIT License

Copyright (c) [year] [your name or organization name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
