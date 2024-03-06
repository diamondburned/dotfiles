local copilot = require("copilot")

copilot.setup({
	panel = {
		enabled = false,
	},
	suggestion = {
		enabled = false,
	},
	filetypes = {
		sh = function ()
			-- Disable for .env files
			return not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*')
		end,
		["*"] = true,
	},
})

vim.cmd([[hi CopilotSuggestion guifg=#888888 ctermfg=245]])
vim.cmd([[hi CopilotAnnotation guifg=#888888 ctermfg=245]])
