local osc52 = require("osc52")
local is_ssh = vim.fn.getenv("SSH_CONNECTION") ~= ""
local is_vte = vim.fn.getenv("VTE_VERSION") ~= ""

if is_ssh or (not vim.g.neovide and not is_vte) then
	osc52.setup {
		max_length = 0,
		silent = true,
		trim = false,
	}

	local function copy(lines, _)
		osc52.copy(table.concat(lines, "\n"))
	end
	
	local function paste()
		return {
			vim.fn.split(vim.fn.getreg(""), "\n"),
			vim.fn.getregtype(""),
		}
	end

	vim.g.clipboard = {
		name = "osc52",
		copy = {["+"] = copy, ["*"] = copy},
		paste = {["+"] = paste, ["*"] = paste},
	}
end
