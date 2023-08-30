set nocompatible

call plug#begin('~/.vim/bundle')

Plug 'gioele/vim-autoswap'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'numToStr/Comment.nvim'
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
" Plug 'airblade/vim-gitgutter'
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
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'diamondburned/vim-lsp-settings', { 'commit': 'c99ed5a' }
" Plug 'mattn/vim-lsp-settings'
Plug 'dense-analysis/ale'
Plug 'github/copilot.vim'

"Languages"
Plug 'makerj/vim-pdf'
Plug 'cespare/vim-toml'
Plug 'LnL7/vim-nix'
Plug 'symphorien/vim-nixhash'
" Plug 'evanleck/vim-svelte'
Plug 'mattn/vim-gotmpl'
Plug 'sago35/tinygo.vim'
Plug 'isobit/vim-caddyfile'
Plug 'joerdav/templ.vim'
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
autocmd BufRead,BufNewFile *.nix    setlocal shiftwidth=2
autocmd BufRead,BufNewFile *.nix    setlocal tabstop=2
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
autocmd BufRead,BufNewFile *.templ  setlocal textwidth=100
autocmd BufRead,BufNewFile *.cpp    setlocal expandtab tabstop=2 shiftwidth=2
autocmd BufRead,BufNewFile *.asm    set filetype=nasm textwidth=400
autocmd BufRead,BufNewFile *s       set filetype=mips textwidth=400
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

"Transparent background in TUI"
hi Normal ctermbg=NONE

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

"I fucking hate it when Nvim makes things harder than they need to be.
"See https://github.com/vhakulinen/gnvim/issues/97#issuecomment-536731701.
function! s:gnvimInit()
	if get(v:event, "chan") == 1
		set guifont=Monospace\ 11
		set linespace=2
	endif
endfunction
autocmd UIEnter * call s:gnvimInit()

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
		auto_reload_on_write = true,
		update_cwd = true,
		git = {
			enable = true,
			ignore = false,
		},
		tab = {
			sync = {
				open = true,
			},
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
		-- Why the fuck did they decide to break a perfectly working declarative
		-- API in favor of a shitty imperative one that is twice as verbose???
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")
			local function opts(desc)
				return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			vim.keymap.set("n", "<CR>", api.node.open.edit, opts('open file'))
			vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts('open file'))
			vim.keymap.set("n", "<C-t>", api.node.open.tab, opts('tabnew'))
			vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts('prev_sibling'))
			vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts('next_sibling'))
			vim.keymap.set("n", "d", api.fs.remove, opts('remove'))
			vim.keymap.set("n", "r", api.fs.rename, opts('rename'))
			vim.keymap.set("n", "q", api.tree.close, opts('close'))
			vim.keymap.set("n", "/", api.tree.search_node, opts('search_node'))
			vim.keymap.set("n", "a", git_add, opts('git add'))
			vim.keymap.set("n", "s", git_restore_staged, opts('git restore --staged'))
		end
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

" backgroundColor = "#1D1D1D";
" foregroundColor = "#FFFFFF";
" palette = [
" 	0  "#272224" "#FF473D" "#3DCCB2" "#FF9600"
" 	4  "#3B7ECB" "#F74C6D" "#00B5FC" "#3E3E3E"
"
" 	8  "#52494C" "#FF6961" "#85E6D4" "#FFB347"
" 	12 "#779ECB" "#F7A8B8" "#55CDFC" "#EEEEEC"
" ];
"Custom colors"
hi Normal guibg=#1D1D1D

hi TabLine     cterm=NONE ctermfg=15 ctermbg=NONE  gui=NONE guifg=#EEEEEC guibg=NONE
hi TabLineSel  ctermbg=15 ctermfg=0                guibg=#EEEEEC guifg=#272224
hi TabLineFill cterm=NONE                          gui=NONE

hi Todo     ctermbg=14                   guibg=#55CDFC
hi Search   ctermbg=14   ctermfg=0       guibg=#55CDFC guifg=#272224
hi SpellBad ctermbg=NONE cterm=undercurl guisp=#FF6961 

hi StatusLine   ctermfg=5
hi StatusLineNC ctermfg=13

hi Special     ctermfg=15 guifg=#EEEEEC
hi SpecialChar ctermfg=5  guifg=#F74C6D
hi Comment     ctermfg=4  guifg=#3B7ECB
hi Constant    ctermfg=15 guifg=#EEEEEC
hi String      ctermfg=13 guifg=#F7A8B8
hi Number      ctermfg=13 guifg=#F7A8B8
hi Boolean     ctermfg=13 guifg=#F7A8B8
hi Identifier  ctermfg=15 guifg=#EEEEEC
hi Function    ctermfg=14 guifg=#55CDFC
hi Statement   ctermfg=6  guifg=#00B5FC
hi Operator    ctermfg=12 guifg=#779ECB

hi Type ctermfg=2 guifg=#3DCCB2

hi SignColumn   ctermbg=NONE  guibg=NONE
hi EndOfBuffer  ctermfg=7     guifg=#3E3E3E
hi QuickFixLine cterm=reverse gui=reverse

hi Directory ctermfg=14 guifg=#55CDFC

"NERDTree executable highlight but also something else"
hi Title ctermfg=10 guifg=#85E6D4

"Custom negative number highlighting"
syntax match negativeNumber '[-+]\d\+\(\.\d*\)\?'
hi def link  negativeNumber Number

"Custom cursor mode: normal-visual block, insert-command IBeam"
set guicursor=n-v-sm:block
set guicursor+=i-c-ci-ve:ver25
set guicursor+=r-cr-o:hor20

"Change completion colors"
hi Pmenu    ctermfg=15 ctermbg=8 guifg=#EEEEEC guibg=#52494C
hi PmenuSel ctermfg=13 ctermbg=0 guifg=#F7A8B8 guibg=#272224

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
nmap <C-/> gcc
vmap <C-_> gc<CR>gv
vmap <C-/> gc<CR>gv
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
" let g:gitgutter_sign_added='+'
" let g:gitgutter_sign_modified='¦'
" let g:gitgutter_sign_removed='-'
" let g:gitgutter_sign_removed_first_line='-'
" let g:gitgutter_sign_modified_removed='-'
" let g:gitgutter_override_sign_column_highlight = 0
lua << EOF
require('gitsigns').setup({
	signs = {
		add          = { text = '+' },
		change       = { text = '¦' },
		delete       = { text = '-' },
		topdelete    = { text = '-' },
		changedelete = { text = '-' },
		untracked    = { text = ' ' },
	}
})
EOF

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

"ALE configs"
" set omnifunc=ale#completion#OmniFunc

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

function! FixMipsfmt(buffer) abort
    return {
    \   'command': 'mipsfmt -'
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

function! FixTempl(buffer) abort
	return {
	\	'command': 'templ fmt'
	\}
endfunction

"https://github.com/dense-analysis/ale/issues/3167"
execute ale#fix#registry#Add('sql-formatter', 'FixSQLFormatter', ['sql'], 'sql-formatter for sql')
execute ale#fix#registry#Add('nasmfmt', 'FixNasmfmt', ['nasm'], 'nasmfmt')
execute ale#fix#registry#Add('mipsfmt', 'FixMipsfmt', ['mips'], 'mipsfmt')
execute ale#fix#registry#Add('denojson', 'FixDenoJSON', ['json'], 'deno fmt for json')
execute ale#fix#registry#Add('denojsonc', 'FixDenoJSONC', ['jsonc'], 'deno fmt for jsonc')
execute ale#fix#registry#Add('prettier', 'ale#fixers#prettier#Fix', ['markdown'], 'prettier for markdown')
execute ale#fix#registry#Add('prettier', 'ale#fixers#prettier#Fix', ['postcss'], 'prettier for postcss')
execute ale#fix#registry#Add('prettier', 'ale#fixers#prettier#Fix', ['astro'], 'prettier for astro')
execute ale#fix#registry#Add('prettier', 'ale#fixers#prettier#Fix', ['scss'], 'prettier for scss')
execute ale#fix#registry#Add('cmark', 'FixCMark', ['markdown'], 'cmark for markdown')
execute ale#fix#registry#Add('cmark-gfm', 'FixCMarkGFM', ['markdown'], 'cmark-gfm for markdown')
execute ale#fix#registry#Add('templ', 'FixTempl', ['templ'], 'templ fmt for templ')

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
			\ 'postcss':    [ "prettier" ],
			\ 'c':          [ "clang-format" ],
			\ 'cpp':        [ "uncrustify", "clang-format" ],
			\ 'sql':        [ "sql-formatter" ],
			\ 'rust':       [ "rustfmt" ],
			\ 'json':       [ "prettier", "jq", "denojson" ],
			\ 'jsonc':      [ "prettier", "denojsonc" ],
			\ 'html':       [ "prettier" ],
			\ 'yaml':       [ "prettier" ],
			\ 'nasm':       [ "nasmfmt" ],
			\ 'mips':       [ "mipsfmt" ],
			\ 'templ':      [  ],
			\ 'python':     [ "autopep8", "black" ],
			\ 'proto':      [ "protolint" ],
			\ 'astro':	    [ "prettier" ],
			\ 'svelte':     [ "prettier", "prettier_standard", "eslint" ],
			\ 'haskell':    [ "ormolu" ],
			\ 'jsonnet':    [ "jsonnetfmt" ],
			\ 'markdown':   [ "cmark-gfm", "cmark", "prettier" ],
			\ 'javascript': [ "deno", "prettier", "prettier_standard", "eslint" ],
			\ 'typescript': [ "deno", "prettier", "prettier_standard", "eslint" ],
			\ }
let g:ale_completion_enabled = 0 
let g:ale_disable_lsp = 1 "Use nvim's built-in LSP"
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
			\ 'svelte':     [ "svelteserver" ],
			\ 'jsonnet':    [ "jsonnetfmt", "jsonnet_lint", "jsonnet-language-server" ],
			\ 'javascript': [ "deno", "tsserver", "deno", "standard" ],
			\ 'typescript': [ "deno", "tsserver", "deno", "standard" ],
			\ }

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

"vim-lsp stuff"
let g:lsp_inlay_hints_enabled = 1
let g:lsp_fold_enabled = 0
let g:lsp_float_max_width = 0 "full width"
let g:lsp_semantic_enabled = 1
" let g:lsp_preview_float = 0
"This prevents Copilot from working properly"
let lsp_signature_help_enabled = 0
"Fix aggressive preemptive completion with noselect"
" let g:asyncomplete_auto_completeopt = 0 "idk if i gotta put this first"
" set completeopt=menuone,noinsert,noselect

nnoremap gd :LspDefinition<CR>
nnoremap K :LspHover<CR>

" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('/tmp/vim-lsp.log')

command! -nargs=0 Rename LspRename
command! -nargs=0 ALERename LspRename

"Support the garbage that is PostCSS"
au BufRead,BufNewFile *.postcss set filetype=postcss

"Support templ"
au BufRead,BufNewFile *.templ set filetype=templ
if executable("templ")
	au User lsp_setup call lsp#register_server({
		\ 'name': 'templ',
		\ 'cmd': {server_info->['templ', 'lsp']},
		\ 'allowlist': ['templ'],
		\ })
endif

"Support Blueprint"
au BufRead,BufNewFile *.blueprint set filetype=blueprint
if executable("blueprint-compiler")
	au User lsp_setup call lsp#register_server({
		\ 'name': 'blueprint',
		\ 'cmd': {server_info->['blueprint-compiler', 'lsp']},
		\ 'allowlist': ['blueprint'],
		\ })
endif

lua << EOF
	require('Comment').setup({
	})
EOF
