local osc52 = require("osc52")

if not vim.g.neovide then
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
