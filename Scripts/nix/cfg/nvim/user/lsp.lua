local lspconfig = require("lspconfig")
local lsp_inlayhints = require("lsp-inlayhints")
local cmp = require("cmp")
local cmptypes = require("cmp.types")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local snippy = require("snippy")
local copilot_cmp = require("copilot_cmp")

-- I might be the only person in this planet who has a sane LSP configuration
-- for Neovim, bruh. ALE has this behavior, vim-lsp has this behavior, so why
-- can't nvim-lsp have this behavior? Why is every stock config a dance of
-- 3-keypresses to do anything and "just install all LSPs in the world"?

-- This table is the base configuration for all LSPs.
local lsp_configuration_base = {
	capabilities = {
		unpack(cmp_nvim_lsp.default_capabilities()),
	},
}

-- This table defines overrides for specific LSPs.
-- gopls is included as an example.
local lsp_configurations = {
	gopls = {
		settings = {
			gopls = {
				analyses = {
					unusedwrite = true,
					unusedparams = true,
					unusedvariable = true,
				},
				staticcheck = true,
				-- Enable inlay hints.
				allExperiments = true,
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
			},
		},
	},
}

-- This table defines LSP keybindings that are local to the buffer.
-- It contains everything that I care about.
local lsp_local_mappings = {
	{ "n", "gd", vim.lsp.buf.definition },
	{ "n", "gD", vim.lsp.buf.declaration },
	{ "n", "gi", vim.lsp.buf.implementation },
	{ "n", "gr", vim.lsp.buf.references },
	{ "n", "K", vim.lsp.buf.hover },
}

-- This table contains all autocompletion sources.
local cmp_sources = {
	-- {name = "cody", keyword_length = 0},
	{name = "copilot", keyword_length = 0},
	"nvim_lsp",
	"nvim_lsp_signature_help",
	"snippy",
	"path",
}

-- This function returns true if the cursor is before a word.
-- Using this function, Tab will fallback to indenting unless a non-whitespace
-- character has actually been typed.
local has_words_before = function()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

local cmp_opts = {
	enabled = function()
		return true
	end,
	completion = {
		autocomplete = {
			cmptypes.cmp.TriggerEvent.TextChanged,
			cmptypes.cmp.TriggerEvent.InsertEnter,
		},
		-- Disable selecting the first item to avoid messing up signature_help.
		completeopt = "menu,menuone,noinsert,noselect",
	},
	performance = {
		-- For 50 WPM, you get ~250 CPM or ~4.16 CPS.
		-- This leaves about 24ms per character. We keep the default debounce
		-- but bump throttle up a bit.
		debounce = 60,
		throttle = 60,
		-- Make fetching a bit more responsive.
		fetching_timeout = 150,
		-- Not sure what async_budget is for but 1 seems really low?
		-- Increase it to 4.
		async_budget = 4,
		-- 200 is way too many entries. Reduce it.
		max_view_entries = 24,
	},
	-- view = {
	-- 	entries = "native",
	-- },
	window = {
		completion = {
			-- I had to steal this off someone else.
			-- cmp's developer has the BALLS to have this in the demo yet never
			-- included a single example configuration showing it. What even is
			-- the fucking point.
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
			scrollbar = "║",
		},
		documentation = {
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
			winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
			scrollbar = "║",
		},
	},
	snippet = {
		expand = function(args)
			snippy.expand_snippet(args.body)
		end,
	},
	experimental = {
		ghost_text = { hl_group = "LspGhostText" },
	},
	mapping = cmp.mapping.preset.insert({
		-- Ignore Tab.
		-- TODO: find the right way to do this

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() and has_words_before() then
				cmp.confirm({
					select = true,
					behavior = cmp.ConfirmBehavior.Replace,
				})
			else
				fallback()
			end
		end, {"i", "s"}),
		["<CR>"] = cmp.mapping({
			i = function(fallback)
				if not cmp.visible() then
					fallback()
					return
				end

				local selected = cmp.get_selected_entry()
				-- Ignore completions from signature_help
				if not selected or selected.source.name == "nvim_lsp_signature_help" then
					fallback()
					return
				end

				cmp.confirm({
					select = false,
					behavior = cmp.ConfirmBehavior.Replace,
				})
			end,
			s = cmp.mapping.confirm({
				select = true,
				behavior = cmp.ConfirmBehavior.Replace,
			}),
			c = cmp.mapping.confirm({
				select = true,
				behavior = cmp.ConfirmBehavior.Replace,
			}),
		}),
		["<C-a>"] = cmp.mapping.complete {
			config = {
				sources = {
					{ name = "copilot" },
				}
			}
		},
	}),
}

-- This function returns a table that contains all the supported LSPs that the
-- nvim-lspconfig plugin provides.
local function find_all_lsp_modules()
	-- We use this hack to find the source directory of nvim-lspconfig.
	-- This is the only way to find the directory that contains the LSP modules.
	local lspconfig_path = nil
	for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
		local lspconfig_file = path .. "/lua/lspconfig.lua"
		if vim.fn.filereadable(lspconfig_file) == 1 then
			lspconfig_path = path
			break
		end
	end

	if lspconfig_path == nil then
		error("Could not find lspconfig.lua in runtime paths.")
	end

	local lsp_modules = {}
	local lspconfig_servers_dir = lspconfig_path .. "/lua/lspconfig/server_configurations"
	for _, file in ipairs(vim.fn.globpath(lspconfig_servers_dir, "*", true, true)) do
		local name = vim.fn.fnamemodify(file, ":t:r")
		table.insert(lsp_modules, name)
	end

	return lsp_modules
end

local function load_lsp(name)
	local binary = lspconfig[name].document_config.default_config.cmd[1]
	local config = {
		unpack(lsp_configuration_base),
		unpack(lsp_configurations[name] or {}),
	}
	if vim.fn.executable(binary) == 1 then
		-- print("LSP " .. name .. " is available through " .. binary .. ", loading it.")
		lspconfig[name].setup(config)
	end
end

-- Try to load everything that is available in PATH.
for _, name in ipairs(find_all_lsp_modules()) do
	if not pcall(load_lsp, name) then
		-- print("Failed to load LSP " .. name .. ".")
	end
end

-- Set up mappings.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		for _, mapping in ipairs(lsp_local_mappings) do
			local args = { unpack(mapping) }
			table.insert(args, opts)
			vim.keymap.set(unpack(args))
		end
	end
})

vim.api.nvim_create_user_command(
	"Rename",
	function(args)
		vim.lsp.buf.rename()
	end,
	{}
)

vim.api.nvim_create_user_command(
	"ShowReferences",
	function(args)
		vim.lsp.buf.references()
	end,
	{}
)

vim.api.nvim_create_user_command(
	"ShowDefinition",
	function(args)
		vim.lsp.buf.definition()
	end,
	{}
)

vim.api.nvim_create_user_command(
	"ShowImplementation",
	function(args)
		vim.lsp.buf.implementation()
	end,
	{}
)

vim.api.nvim_create_user_command(
	"ShowDeclaration",
	function(args)
		vim.lsp.buf.declaration()
	end,
	{}
)

-- Bordered hover.
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded', focusable = false})

-- Set up inlay hints.
-- lsp_inlayhints.setup({})

-- Set up Cody.
-- 
-- sg.setup()

-- Set up Copilot.
copilot_cmp.setup()

local cmp_sources_2 = {}
for _, source in ipairs(cmp_sources) do
	if type(source) == "string" then
		table.insert(cmp_sources_2, { name = source })
	else
		table.insert(cmp_sources_2, source)
	end
end
cmp_opts.sources = cmp.config.sources(cmp_sources_2)
cmp.setup(cmp_opts)
