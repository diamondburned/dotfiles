local cokeline = require("cokeline")
local hlgroups = require("cokeline.hlgroups")

local get_hex = hlgroups.get_hl_attr

local function str_or(condition, str)
	return condition and str or ""
end

-- IT ACTUALLY TOOK ME AN ETERNITY TO FIGURE OUT WHAT THE HIGHLIGHT GROUP FOR
-- NVIM-LSP IS. Every single post has given some bullshit irrelevant answer
-- or it's something like LspDiagnosticsSomething, which is completely WRONG!
--
-- This one StackOverflow post actually got it: https://stackoverflow.com/a/70220682
-- It's DiagnosticSomething.

cokeline.setup({
	default_hl = {
		fg = function(buffer)
			return
				buffer.is_focused
				and get_hex("StatusLine", "fg")
				 or get_hex("StatusLineNC", "fg")
		end,
		bg = function(buffer)
			return
				buffer.is_focused
				and get_hex("Pmenu", "bg")
				 or get_hex("StatusLineNC", "bg")
		end,
	},
	components = {
		{
			text = " ",
		},
		{
			text = function(buffer)
				return buffer.filename .. " "
			end,
			bold = function(buffer)
				return buffer.is_focused
			end,
			underline = function(buffer)
				return buffer.is_hovered
			end,
			fg = function(buffer)
				if not buffer.is_focused then
					return get_hex("StatusLineNC", "fg")
				elseif buffer.diagnostics.errors > 0 then
					return get_hex("DiagnosticError", "fg")
				else
					return get_hex("StatusLine", "fg")
				end
			end
		},
		{
			text = function(buffer)
				return str_or(
					buffer.diagnostics.errors > 0,
					"(" .. buffer.diagnostics.errors .. ") "
				)
			end,
			fg = get_hex("DiagnosticError", "fg"),
		},
		{
			text = function(buffer)
				return str_or(buffer.is_modified, "● ")
			end,
		},
		{
			text = "🗙",
			fg = get_hex("NvimTreeGitDirty", "fg"),
			on_click = function(_, _, _, _, buffer) buffer:delete() end,
		},
		{
			text = " ",
		}
	},
})
