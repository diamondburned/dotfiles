local lspconfig = require("lspconfig")
local cmp = require("cmp")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local lsp_configurations = {
	gopls = {}, -- example
}

local cmp_sources = {
	"copilot",
	"nvim_lsp",
	"path",
}

local lsp_configuration_base = {
	capabilities = {
		table.unpack(cmp_nvim_lsp.default_capabilities()),
	},
}

local lsp_local_mappings = {
	{ "n", "gd", vim.lsp.buf.definition },
	{ "n", "gD", vim.lsp.buf.declaration },
	{ "n", "gi", vim.lsp.buf.implementation },
	{ "n", "gr", vim.lsp.buf.references },
	{ "n", "K", vim.lsp.buf.hover },
}

-- Try to load everything that is available in PATH.
function try_loading_lsp(name)
	local binary = lspconfig[name].document_config.default_config.cmd[1]
	local config = {
		table.unpack(lsp_configuration_base),
		table.unpack(lsp_configurations[name] or {}),
	}
	if vim.fn.executable(binary) == 1 then
		lspconfig[name].setup(config)
		return true
	end
end
for lsp_name in pairs(lspconfig) do
	if lsp_name == "util" then
		-- Not a real LSP.
		goto continue
	end

	if pcall(try_loading_lsp, lsp_name) then
		print("Loaded LSP: " .. lsp_name)
	end

	-- Lua not having continue is a pain and makes happy pathing hard.
	-- Lua code is destined to be ugly.
	::continue::
end

-- Set up mappings.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		for _, mapping in ipairs(lsp_local_mappings) do
			vim.keymap.set(unpack(mapping, 1, 3), opts)
		end
	end
})

local cmp_opts = { sources = {} }
for _, source in ipairs(cmp_sources) do
	table.insert(cmp_opts.sources, { name = source })
end
cmp.setup(cmp_opts)
