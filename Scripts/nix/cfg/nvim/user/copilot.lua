local copilot = require("copilot")

copilot.setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = {
			accept = "<Tab>",
			accept_word = false,
			accept_line = false,
		},
	},
	panel = {
		enabled = true,
		auto_refresh = true,
	},
	filetypes = {
		yaml = true,
		markdown = true,
		gitcommit = true,
		gitrebase = true,
		sh = function()
			-- Disable for .env files
			return not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*')
		end,
	},
})

vim.cmd([[hi CopilotSuggestion guifg=#888888 ctermfg=245]])
vim.cmd([[hi CopilotAnnotation guifg=#888888 ctermfg=245]])
