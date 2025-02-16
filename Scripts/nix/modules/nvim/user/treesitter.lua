require("nvim-treesitter.configs").setup {
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

require("treesitter-context").setup{
	enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	multiwindow = false, -- Enable multiwindow support.
	max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
	min_window_height = 12, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
	line_numbers = true,
	multiline_threshold = 1, -- Maximum number of lines to show for a single context
	trim_scope = "inner", -- Which context lines to discard if `max_lines` is exceeded. Choices: "inner", "outer"
	mode = "topline",  -- Line used to calculate context. Choices: "cursor", "topline"
	-- Separator between context and content. Should be a single character string, like "-".
	-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	separator = nil,
	zindex = 20, -- The Z-index of the context window
	on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
