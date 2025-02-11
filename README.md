# gideon.nvim

Gemini powered minimal quick and easy assistant for Neovim.

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

![Gideon.nvim Demo](https://raw.githubusercontent.com/Riley1101/gideon.nvim/refs/heads/main/preview/demo-2.gif)

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

```lua
-- lazy
return {
  "Riley1101/gideon.nvim",
  config = function()
    local gideon = require("gideon")
    gideon.setup()
  end,
}
```

## Usage

```
:Gideongen <your prompt>
```

Select text visually, then `:Gideongen <your prompt>`

This command sends the visually selected text to the AI for processing.`<your prompt>` should describe the desired transformation or task.

**Note:** Make sure you have `"GEMINI_API_KEY"` in your shell environment variables.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License.

