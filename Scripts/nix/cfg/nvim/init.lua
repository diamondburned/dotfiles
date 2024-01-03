require("Comment").setup({})
require("nvim-autopairs").setup({})

if vim.g.neovide then
	-- Only a GUI client like Neovide can do this.
	require("shade").setup({ overlay_opacity = 60 })
end

require("user.copilot")
require("user.lsp")
require("user.cokeline")
require("user.clipboard")
require("user.file-tree")
