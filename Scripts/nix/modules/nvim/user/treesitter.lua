require'nvim-treesitter.configs'.setup {
	indent    = { enable = false },
	highlight = { enable = true },
	-- refactor  = {
	-- 	highlight_definitions = {
	-- 		enable = true,
	-- 		clear_on_cursor_move = false,
	-- 	},
	-- 	highlight_current_scope = { enable = true },
	-- },
	additional_vim_regex_highlighting = false,
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.x86asm = {
	install_info = {
		url = "https://github.com/bearcove/tree-sitter-x86asm.git",
		files = {"src/parser.c"},
		branch = "main",
		generate_requires_npm = true,
		requires_generate_from_grammar = false,
	},
	filetype = "nasm",
}
