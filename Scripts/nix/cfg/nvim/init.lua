require("Comment").setup({})
require("nvim-autopairs").setup({})

require("colorizer").setup({
	user_default_options = {
		RGB = true,
		RRGGBB = true,
		names = false,
		RRGGBBAA = true,
		AARRGGBB = false,
		rgb_fn = true,
		hsl_fn = true,
		mode = "virtualtext",
		virtualtext = "●",
		always_update = true,
	},
})

if vim.g.neovide then
	-- Only a GUI client like Neovide can do this.
	-- require("shade").setup({ overlay_opacity = 60 })

	vim.keymap.set(
		{'n', 'v', 's', 'x', 'o', 'i', 'l', 'c', 't'},
		'<C-S-v>',
		function()
			vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
		end,
		{
			noremap = true,
			silent = true,
		}
	)
end

local rainbow_delimiters = require('rainbow-delimiters')
require('rainbow-delimiters.setup').setup {
	strategy = {
		[''] = rainbow_delimiters.strategy['global'],
		-- commonlisp = rainbow_delimiters.strategy['local'],
	},
	query = {
		[''] = 'rainbow-delimiters',
		xml = 'rainbow-blocks',
	},
}

require("user.greet")
require("user.copilot")
require("user.lsp")
require("user.cokeline")
require("user.clipboard")
require("user.file-tree")
