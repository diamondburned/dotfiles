require("Comment").setup({})
require("nvim-autopairs").setup({})

require("copilot").setup({
	-- Rely on user.lsp's Copilot source instead.
	panel      = { enabled = false },
	suggestion = { enabled = false },

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
