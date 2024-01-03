local lspconfig = require("lspconfig")

local lsp_configurations = {
	gopls = {}, -- example
}

-- Try to load everything that is available in PATH.
for lsp_name, lsp in pairs(lspconfig) do
	local binary = lsp.document_config.default_config.cmd[1]
	local config = lsp_configurations[lsp_name] or {}
	if vim.fn.executable(binary) == 1 then
		lspconfig[lsp].setup(config)
	end
end
