require("Comment").setup({})
require("nvim-autopairs").setup({})

require("copilot").setup({
	panel      = { enabled = true },
	suggestion = { enabled = true },

	filetypes = {
		yaml = true,
		markdown = true,
		gitcommit = true,
		gitrebase = true,
	},
})

require("user.lsp")
require("user.cokeline")
require("user.clipboard")
require("user.file-tree")
