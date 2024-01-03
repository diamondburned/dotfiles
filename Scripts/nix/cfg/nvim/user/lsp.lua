local lspconfig = require("lspconfig")
local lsp_inlayhints = require("lsp-inlayhints")
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local cmp_copilot = require("copilot_cmp")
local snippy = require("snippy")

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
	"hints": {
		"assignVariableTypes": true,
		"compositeLiteralFields": true,
		"constantValues": true,
		"functionTypeParameters": true,
		"parameterNames": true,
		"rangeVariableTypes": true
	}
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
	"copilot",
	"nvim_lsp",
	"snippy",
	"path",
}

local cmp_opts = {
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
	mapping = cmp.mapping.preset.insert({
		-- Ignore Tab.
		-- TODO: find the right way to do this
		-- ["<Tab>"] = function(fallback)
		-- 	fallback()
		-- end,
		["<CR>"] = cmp.mapping({
			i = function(fallback)
				if cmp.visible() and cmp.get_selected_entry() then
					cmp.confirm({
						select = false,
						behavior = cmp.ConfirmBehavior.Replace,
					})
				else
					fallback()
				end
			end,
			s = cmp.mapping.confirm({
				select = true,
			}),
			c = cmp.mapping.confirm({
				select = true,
				behavior = cmp.ConfirmBehavior.Replace,
			}),
		}),
	}),
}

-- Set up inlay hints.
lsp_inlayhints.setup({

})

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

-- Set up :Rename command.
vim.api.nvim_create_user_command(
	"Rename",
	function(args)
		vim.lsp.buf.rename()
	end,
	{}
)

-- Bordered hover.
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded', focusable = false})

local cmp_sources_2 = {}
for _, source in ipairs(cmp_sources) do
	table.insert(cmp_sources_2, { name = source })
end
cmp_opts.sources = cmp.config.sources(cmp_sources_2)

cmp_copilot.setup()
cmp.setup(cmp_opts)
