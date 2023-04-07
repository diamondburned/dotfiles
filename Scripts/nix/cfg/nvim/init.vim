set nocompatible

call plug#begin('~/.vim/bundle')

Plug 'gioele/vim-autoswap'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'tomtom/tcomment_vim'
" Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'plasticboy/vim-markdown'
Plug 'godlygeek/tabular'
Plug 'bogado/file-line'
Plug 'rhysd/conflict-marker.vim'
Plug 'gpanders/editorconfig.nvim'
Plug 'folke/todo-comments.nvim'
Plug 'chrisbra/Colorizer'
Plug 'luochen1990/rainbow'

Plug 'hhhapz/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'andreypopp/vim-colors-plain'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

"Better highlighting"
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-refactor'

"Autocomplete brackets/parens/etc like vscode"
Plug 'jiangmiao/auto-pairs'

"Autocompletion"
" Plug 'neovim/nvim-lspconfig'
" Plug 'hrsh7th/nvim-cmp'
Plug 'prabirshrestha/vim-lsp/'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
Plug 'dense-analysis/ale'
Plug 'github/copilot.vim'

"Languages"
Plug 'makerj/vim-pdf'
Plug 'cespare/vim-toml'
Plug 'LnL7/vim-nix'
Plug 'symphorien/vim-nixhash'
" Plug 'evanleck/vim-svelte'
Plug 'mattn/vim-gotmpl'
Plug 'isobit/vim-caddyfile'
" Plug 'vim-pandoc/vim-pandoc'
" Plug 'vim-pandoc/vim-pandoc-syntax'
" Plug 'vim-pandoc/vim-rmarkdown'

call plug#end()

"Better mouse support"
set mouse=a
vnoremap <C-c> "+y
vnoremap <C-v> "+p
inoremap <C-v> <Esc>"+pi<Right>
map - dd

set clipboard+=unnamedplus

"80/100 column styling"
set textwidth=80
hi Column80  ctermfg=3
hi Column100 ctermbg=1

function! HighlightLong() abort
	call matchadd("Column80",  '\%<101v.\%>81v')
	call matchadd("Column100", '\%>100v.\+')
endfunction
au BufNew * call HighlightLong()

"Make comments NOT italicized
hi Comment cterm=none

"Auto-commands for type-specific files"
autocmd BufRead,BufNewFile *.nix    setlocal noautoindent
autocmd BufRead,BufNewFile *.nix    setlocal noexpandtab
autocmd BufRead,BufNewFile *.nix    setlocal shiftwidth=4
autocmd BufRead,BufNewFile *.nix    setlocal textwidth=100
autocmd BufRead,BufNewFile *.md     setlocal spell
autocmd BufRead,BufNewFile *.md     setlocal wrap
autocmd BufRead,BufNewFile *.md     setlocal textwidth=0
autocmd BufRead,BufNewFile *.txt    setlocal spell
autocmd BufRead,BufNewFile *.vue    syntax sync fromstart
autocmd BufRead,BufNewFile *.vugu   setlocal filetype=html
autocmd BufRead,BufNewFile *.svelte setfiletype svelte
autocmd BufRead,BufNewFile .env*    setlocal syntax=sh
autocmd BufRead,BufNewFile *.html   setlocal textwidth=100
autocmd BufRead,BufNewFile *.cpp    setlocal expandtab tabstop=2 shiftwidth=2
autocmd BufRead,BufNewFile *.asm    set filetype=nasm textwidth=400
autocmd BufRead,BufNewFile *.hpp    set filetype=cpp

"Go to last cursor on file open"
autocmd BufReadPost *
	\ if line("'\"") >= 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

"Autoindent"
set smartindent
filetype indent on

"Thick gutter"
set numberwidth=8
set number

"Tab size 4"
set tabstop=4
set shiftwidth=4

"Better colors and highlighting"
let g:material_terminal_italics = 1
let g:material_theme_style='lighter'
set background=dark

"Transparent background"
hi Normal guibg=NONE ctermbg=NONE

"Tweaks"
filetype plugin indent on
syntax on

if exists('g:started_by_firenvim')
	colorscheme plain
	hi Normal guibg=#242424 guifg=#EEEEEE
	hi Comment gui=NONE

	set guifont=Monospace:h10.5:b
	set linespace=-2

	let g:firenvim_config = {
	\	'localSettings': {
	\		'.*discord\.com.*': { 'takeover': 'never', 'priority': 1 },
	\		'.*ponies\.im.*'  : { 'takeover': 'never', 'priority': 1 },
	\		'.*element\.io.*' : { 'takeover': 'never', 'priority': 1 },
	\	},
	\ }

	" let g:nvim_tree_auto_open = 0
endif

"Nvim Tree configs"
hi NvimTreeCursorLine ctermbg=8
hi NvimTreeFolderName ctermfg=NONE
hi NvimTreeFolderIcon ctermfg=14
hi NvimTreeExecFile   ctermfg=12
hi NvimTreeGitDirty   ctermfg=9
hi NvimTreeGitStaged  ctermfg=2
hi NvimTreeGitRenamed ctermfg=6
hi NvimTreeGitDeleted ctermfg=1
hi NvimTreeGitIgnored ctermfg=8

lua <<EOF
	local function git_add(node)
		vim.cmd('Git add ' .. node.absolute_path)
		vim.cmd('NvimTreeRefresh')
	end

	local function git_restore_staged(node)
		vim.cmd('Git restore --staged ' .. node.absolute_path)
		vim.cmd('NvimTreeRefresh')
	end

	require'nvim-tree'.setup {
		disable_netrw = true,
		open_on_tab = true,
		open_on_setup = true,
		auto_reload_on_write = true,
		update_cwd = true,
		git = {
			enable = true,
			ignore = false,
		},
		filters = {
			custom = { '^\\.git$', '^node_modules$' },
			dotfiles = false,
		},
		actions = {
			open_file = {
				window_picker = { enable = true },
			},
		},
		update_focused_file = { enable = true },
		view = {
			width = 28,
			signcolumn = "no",
			mappings = {
				custom_only = true,
				list = {
					{ key = {"<CR>", "<2-LeftMouse>"}, action = "edit" },
					{ key = "<2-RightMouse>",          action = "cd" },
					{ key = "<C-t>",                   action = "tabnew" },
					{ key = "<",                       action = "prev_sibling" },
					{ key = ">",                       action = "next_sibling" },
					{ key = "<BS>",                    action = "close_node" },
					{ key = "d",                       action = "remove" },
					{ key = "r",                       action = "rename" },
					{ key = "q",                       action = "close" },
					{ key = "/",                       action = "search_node" },
					{ key = "a",                       action = "", action_cb = git_add },
					{ key = "s",                       action = "", action_cb = git_restore_staged },
				},
			},
		},
		renderer = {
			add_trailing = true,
			highlight_git = true,
			icons = {
				show = {
					git = true,
					file = true,
					folder = true,
					folder_arrow = true,
				},
				glyphs = {
					default = " ",
					symlink = " ",
					git = {
						unstaged = "M",
						staged = "M",
						unmerged = "U",
						renamed = "R",
						untracked = "U",
						deleted = "D",
						ignored = "I",
					},
					folder = {
						default = ">",
						open = "v",
						empty = ">",
						empty_open = "v",
						symlink = ">",
						symlink_open = "v",
						arrow_open = "",
						arrow_closed = "",
					},
				},
			},
		},
	}

	require'nvim-treesitter.configs'.setup {
		indent    = { enable = false },
		highlight = { enable = true },
		refactor  = {
			highlight_definitions = { enable = true },
		},
	}
EOF

"TODO comments"
lua << EOF
	require("todo-comments").setup {
		signs = true,
		keywords = {
			FIX  = { icon = "" },
			TODO = { icon = "" },
			HACK = { icon = "" },
			WARN = { icon = "" },
			PERF = { icon = "" },
			NOTE = { icon = "" },
			TEST = { icon = "" },
		},
	}
EOF

"Custom colors"
hi TabLine     cterm=NONE ctermfg=15 ctermbg=NONE
hi TabLineSel  ctermbg=15 ctermfg=0
hi TabLineFill cterm=NONE

hi Todo     ctermbg=14
hi Search   ctermbg=14   ctermfg=0
hi SpellBad ctermbg=NONE cterm=undercurl guisp=#FF6961

hi StatusLine   ctermfg=5
hi StatusLineNC ctermfg=13

hi Special     ctermfg=15
hi SpecialChar ctermfg=5
hi Comment     ctermfg=4
hi Constant    ctermfg=15
hi String      ctermfg=13
hi Number      ctermfg=13
hi Boolean     ctermfg=13
hi Identifier  ctermfg=15
hi Function    ctermfg=14
hi Statement   ctermfg=6
hi Operator    ctermfg=12

hi Type ctermfg=2

hi SignColumn   ctermbg=NONE
hi EndOfBuffer  ctermfg=7
hi QuickFixLine cterm=reverse

"Change NERDTree's colors"
hi Directory     ctermfg=14
hi NERDTreeFlags ctermfg=6

"NERDTree executable highlight but also something else"
hi Title ctermfg=10

"Custom negative number highlighting"
syntax match negativeNumber '[-+]\d\+\(\.\d*\)\?'
hi def link  negativeNumber Number

"Custom cursor mode: normal-visual block, insert-command IBeam"
set guicursor=n-v-sm:block
set guicursor+=i-c-ci-ve:ver25
set guicursor+=r-cr-o:hor20

"Change completion colors"
hi Pmenu    ctermfg=15 ctermbg=8
hi PmenuSel ctermfg=13 ctermbg=0

"Extra Go colors"
"hi goParamName       ctermfg=15
"hi goReceiverType    ctermfg=15
"hi goTypeConstructor ctermfg=15
"hi goTypeName        ctermfg=15
"hi goFunctionCall    ctermfg=15

"Resume past cursor location on open"
au InsertLeave * call cursor([getpos('.')[1], getpos('.')[2]+1])

"GUI shit"
if exists('g:GtkGuiLoaded')
	let g:GuiInternalClipboard = 1
	call rpcnotify(1, 'Gui', 'Font', 'Monospace 11')
	call rpcnotify(1, 'Gui', 'Command', 'SetCursorBlink', '0')
	hi Normal guibg=#1D1D1D
endif

"Autoindentation"
set autoindent

"ToggleWrap from the vim wiki"
set linebreak
nnoremap <Up>   gk
nnoremap <Down> gj
nnoremap <Home> g<Home>
nnoremap <End>  g<End>

"Disable line-wrap; use ellipsis"
set nowrap
set list
set listchars=tab:\ \ \,extends:…

"Backups"
"Turn on backup option
set backup
set backupdir=~/.vim/backup/
set writebackup
set backupcopy=no
au BufWritePre * let &bex = '@' . strftime("%F.%H:%M")

"Better highlighting, less broken"
autocmd BufEnter * :syntax sync fromstart
syntax sync minlines=100

"Custom keybinds"
nmap <Tab> :NvimTreeToggle<CR> <bar> :NvimTreeRefresh<CR>
nmap <C-_> gcc
vmap <C-_> gc<CR>gv
nmap <C-j> =G
nnoremap f :F<CR>

vnoremap ' :s/\%V.*\%V./'&'/<CR>
vnoremap " :s/\%V.*\%V./"&"/<CR>
vnoremap ` :s/\%V.*\%V./`&`/<CR>

"Better Vim regexes"
set smartcase

"Markdown stuff"
let g:vim_markdown_folding_disabled = 1
let g:mkdp_browser = 'xdg-open'
let g:mkdp_preview_options = {
	\ 'katex': {},
	\ }
let g:mkdp_page_title = '${name}'
let g:preview_markdown_auto_update = 1

"Remove background"
hi LineNr       guibg=NONE ctermbg=NONE
hi SignColumn   guibg=NONE ctermbg=NONE
hi VertSplit    guibg=NONE ctermbg=NONE gui=NONE cterm=NONE ctermfg=240
hi StatusLine   guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi StatusLineNC guibg=NONE ctermbg=NONE gui=NONE cterm=NONE

"Set wildmenu colors"
hi WildMenu ctermbg=12
hi WildMenu ctermfg=21

"Current Line highlighting"
" hi CursorLine    ctermbg=7 cterm=NONE
set cursorline
hi clear CursorLine
hi CursorLineNR ctermfg=14

"Nicer vertical separators"
set fillchars=vert:\▏

"Cooler git diffs"
" let g:gitgutter_sign_added='▓'
" let g:gitgutter_sign_modified='░'
" let g:gitgutter_sign_removed_first_line='_'
" let g:gitgutter_sign_modified_removed='_'
let g:gitgutter_sign_added='+'
let g:gitgutter_sign_modified='¦'
let g:gitgutter_sign_removed='-'
let g:gitgutter_sign_removed_first_line='-'
let g:gitgutter_sign_modified_removed='-'
let g:gitgutter_override_sign_column_highlight = 0

"245 is a grey-ish shade."
hi! GitGutterAdd          guibg=NONE ctermbg=NONE guifg=#6c6c6c ctermfg=245
hi! GitGutterChange       guibg=NONE ctermbg=NONE guifg=#6c6c6c ctermfg=245
hi! GitGutterDelete       guibg=NONE ctermbg=NONE guifg=#6c6c6c ctermfg=245
hi! GitGutterChangeDelete guibg=NONE ctermbg=NONE guifg=#6c6c6c ctermfg=245

"Cooler git conflicts"
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

highlight ConflictMarkerBegin  ctermbg=28
highlight ConflictMarkerOurs   ctermbg=22
highlight ConflictMarkerTheirs ctermbg=23
highlight ConflictMarkerEnd    ctermbg=30

"Line number color to match Limelight"
highlight LineNr guifg=#6c6c6c ctermfg=242

"New file in buffer directory"
command -nargs=1 New :e %:p:h/<args>

":GitAdd to add the current file to git."
command GitAdd           :Git add %
command Ga               :Git add %
command Gm               :Git commit
command GitRestoreStaged :Git restore "--staged" %
command GitUnadd         :Git restore "--staged" %

"Optimized drawing"
set ttyfast
set lazyredraw

"Use a low redraw time, because these times may accumulate each keypress, which
"is annoying."
set redrawtime=500

"Configuring the update delay after buffer updates"
set updatetime=150
let g:cursorhold_updatetime = 150

"Undo history"
set undofile

"Make nvim show changes done by commands in real-time"
"Actually very buggy"
set inccommand=nosplit

"Better scrolloff"
set scrolloff=7
"Better sidescroll"
set sidescroll=1
set sidescrolloff=5

"Tree Sitter configs"
lua <<EOF
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
EOF

"Auto-reload changed files"
set autoread
au CursorHold * checktime

"Autocompletion"
"Fix aggressive preemptive completion with noselect"
set completeopt=menuone,noselect

"ALE configs"
set omnifunc=ale#completion#OmniFunc

hi ALEError cterm=undercurl gui=undercurl guisp=#FF6961
hi ALEWarningSign ctermbg=NONE

call ale#linter#Define('nasm', {
	\ 'name': 'nasmfmt',
	\ 'lsp': 'stdio',
	\ 'executable': 'sqls',
	\ 'command': '%e',
	\ 'project_root': '.',
	\ })

call ale#linter#Define('sql', {
	\ 'name': 'sqls',
	\ 'lsp': 'stdio',
	\ 'executable': 'sqls',
	\ 'command': '%e',
	\ 'project_root': '.',
	\ })

call ale#linter#Define('jsonnet', {
	\ 'name': 'jsonnet-language-server',
	\ 'lsp': 'stdio',
	\ 'executable': 'jsonnet-language-server',
	\ 'command': '%e',
	\ 'project_root': '.',
	\ })

call ale#linter#Define('astro', {
	\ 'name': 'astro-ls',
	\ 'lsp': 'stdio',
	\ 'executable': 'astro-ls',
	\ 'command': '--stdio %e',
	\ 'project_root': '.',
	\ })

call ale#linter#Define('javascript', {
	\ 'name': 'svelteserver',
	\ 'lsp': 'stdio',
	\ 'executable': 'svelteserver',
	\ 'command': '%e --stdio',
	\ 'project_root': '.',
	\ })

call ale#linter#Define('typescript', {
	\ 'name': 'svelteserver',
	\ 'lsp': 'stdio',
	\ 'executable': 'svelteserver',
	\ 'command': '%e --stdio',
	\ 'project_root': '.',
	\ })

function! FixSQLFormatter(buffer) abort
    return {
    \   'command': 'sql-formatter'
    \}
endfunction

function! FixNasmfmt(buffer) abort
    return {
    \   'command': 'nasmfmt -'
    \}
endfunction

function! FixDenoJSON(buffer) abort
    return {
    \   'command': 'deno fmt --ext json -'
    \}
endfunction

function! FixDenoJSONC(buffer) abort
    return {
    \   'command': 'deno fmt --ext jsonc -'
    \}
endfunction

function! FixCMark(buffer) abort
    return {
    \   'command': 'cmark -t commonmark'
    \}
endfunction

function! FixCMarkGFM(buffer) abort
    return {
    \   'command': 'cmark-gfm --extension table --extension autolink --extension tagfilter --extension tasklist --extension strikethrough --extension footnotes -t commonmark'
	\ }
endfunction

"https://github.com/dense-analysis/ale/issues/3167"
execute ale#fix#registry#Add('sql-formatter', 'FixSQLFormatter', ['sql'], 'sql-formatter for sql')
execute ale#fix#registry#Add('nasmfmt', 'FixNasmfmt', ['nasm'], 'nasmfmt')
execute ale#fix#registry#Add('denojson', 'FixDenoJSON', ['json'], 'deno fmt for json')
execute ale#fix#registry#Add('denojsonc', 'FixDenoJSONC', ['jsonc'], 'deno fmt for jsonc')
execute ale#fix#registry#Add('prettier', 'ale#fixers#prettier#Fix', ['astro'], 'prettier for astro')
execute ale#fix#registry#Add('prettier', 'ale#fixers#prettier#Fix', ['scss'], 'prettier for astro')
execute ale#fix#registry#Add('cmark', 'FixCMark', ['markdown'], 'cmark for markdown')
execute ale#fix#registry#Add('cmark-gfm', 'FixCMarkGFM', ['markdown'], 'cmark-gfm for markdown')

let g:ale_virtualtext_cursor = 1
let g:ale_sign_error = '!'
let g:ale_sign_warning = '>'
let g:ale_sign_column_always = 1
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 0
let g:ale_completion_autoimport = 1
" let g:ale_linter_aliases = {
" 			\ 'svelte': ['svelte', 'css', 'javascript'],
" 			\ }
let g:ale_fixers = {
			\ 'go':         [ "goimports" ],
			\ 'zig':        [ "zigfmt" ],
			\ 'css':        [ "prettier" ],
			\ 'scss':       [ "prettier" ],
			\ 'c':          [ "clang-format" ],
			\ 'cpp':        [ "uncrustify", "clang-format" ],
			\ 'sql':        [ "sql-formatter" ],
			\ 'rust':       [ "rustfmt" ],
			\ 'json':       [ "prettier", "jq", "denojson" ],
			\ 'jsonc':      [ "prettier", "denojsonc" ],
			\ 'html':       [ "prettier" ],
			\ 'yaml':       [ "prettier" ],
			\ 'nasm':       [ "nasmfmt" ],
			\ 'python':     [ "autopep8", "black" ],
			\ 'astro':	    [ "prettier" ],
			\ 'svelte':     [ "prettier", "prettier_standard", "eslint" ],
			\ 'jsonnet':    [ "jsonnetfmt" ],
			\ 'markdown':   [ "cmark-gfm", "cmark", "prettier" ],
			\ 'javascript': [ "deno", "prettier", "prettier_standard", "eslint" ],
			\ 'typescript': [ "deno", "prettier", "prettier_standard", "eslint" ],
			\ }
let g:ale_completion_enabled = 1
"Previously for Go: staticcheck and go vet"
let g:ale_linters = {
			\ 'go':         [ "gopls", "staticcheck", "go vet" ],
			\ 'zig':        [ "zls" ],
			\ 'c':          [ "clangd" ],
			\ 'cpp':        [ "clangd" ],
			\ 'sql':        [ "sqls" ],
			\ 'rust':       [ "analyzer", "cargo" ],
			\ 'nasm':       [ "nasm" ],
			\ 'astro':      [ "astro-ls" ],
			\ 'python':     [ "pyright" ],
			\ 'svelte':     [ "svelteserver", "tsserver", "eslint" ],
			\ 'jsonnet':    [ "jsonnetfmt", "jsonnet_lint", "jsonnet-language-server" ],
			\ 'javascript': [ "deno", "tsserver", "deno", "standard" ],
			\ 'typescript': [ "deno", "tsserver", "deno", "standard" ],
			\ }
nnoremap gd :ALEGoToDefinition<CR>
nnoremap K :ALEHover<CR>

let g:copilot_filetypes = {
	\ 'markdown': v:true,
	\ 'yaml': v:true,
	\ }

""Assistive LSP bindings"
"function! ToggleQf()
"	for buffer in tabpagebuflist()
"		if bufname(buffer) == ''
"			cclose
"			return
"		endif
"	endfor
"	botright copen
"	wincmd p
"endfunction

""Next error"
"nnoremap <M-n> :cnext<CR>zz
""Show errors"
"nnoremap <silent><M-c> :call ToggleQf()<CR>
""Previous error"
"nnoremap <M-p> :cprev<CR>zz

nmap ; :

"Lambda Calculus moment"
let g:rainbow_active = 1