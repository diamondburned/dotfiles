local lspconfig = require("lspconfig")
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- This table is the base configuration for all LSPs.
local lsp_configuration_base = {
	capabilities = {
		unpack(cmp_nvim_lsp.default_capabilities()),
	},
}

-- This table defines overrides for specific LSPs.
-- gopls is included as an example.
local lsp_configurations = {
	gopls = {},
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
	"path",
}

-- This function returns a table that contains all the supported LSPs that the
-- nvim-lspconfig plugin provides.
function find_all_lsp_modules()
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

function load_lsp(name)
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

local cmp_opts = { sources = {} }
for _, source in ipairs(cmp_sources) do
	table.insert(cmp_opts.sources, { name = source })
end
cmp.setup(cmp_opts)
