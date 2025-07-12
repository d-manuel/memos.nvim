This is a simple plugin for sending the content of the current buffer to your [memos](https://github.com/usememos/memos) instance. Each time the sendToMemos function is invoked, a new memo with the current buffer is created.

## Installation

### lazy.nvim

```lua
{
	"memos.nvim",
	dev = true,
	name = "memos.nvim",
	config = function()
		require("memos").setup({
			api_key =
			"my_api_key",
			base_url =
			"https://mymemosinstance.com/"
		})
		vim.keymap.set({ "n", "i" }, "<M-b>", require("memos").sendToMemos)
	end
}
```

You can get an API key for your memos instance at `Settings` -> `My Account`. 
