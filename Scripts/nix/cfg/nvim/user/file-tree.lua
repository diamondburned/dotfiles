local nvim_tree = require('nvim-tree')

local function git_add(node)
	vim.cmd('Git add ' .. node.absolute_path)
	vim.cmd('NvimTreeRefresh')
end

local function git_restore_staged(node)
	vim.cmd('Git restore --staged ' .. node.absolute_path)
	vim.cmd('NvimTreeRefresh')
end

nvim_tree.setup({
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
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	update_focused_file = { enable = true },
	view = {
		width = 30,
		signcolumn = "no",
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
				-- Using a single space actually adds 2 spaces but using an
				-- empty string adds 0 spaces, so we'll use a zero-width space
				-- :)
				default = "​",
				symlink = "​",
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
})

vim.cmd([[hi NvimTreeCursorLine ctermbg=8    guibg=#52494C]])
vim.cmd([[hi NvimTreeFolderName ctermfg=NONE guifg=NONE   ]])
vim.cmd([[hi NvimTreeFolderIcon ctermfg=14   guifg=#55CDFC]])
vim.cmd([[hi NvimTreeExecFile   ctermfg=12   guifg=#779ECB]])
vim.cmd([[hi NvimTreeGitDirty   ctermfg=9    guifg=#FF6961]])
vim.cmd([[hi NvimTreeGitStaged  ctermfg=2    guifg=#3DCCB2]])
vim.cmd([[hi NvimTreeGitRenamed ctermfg=6    guifg=#00B5FC]])
vim.cmd([[hi NvimTreeGitDeleted ctermfg=1    guifg=#FF473D]])
vim.cmd([[hi NvimTreeGitIgnored ctermfg=8    guifg=#52494C]])

