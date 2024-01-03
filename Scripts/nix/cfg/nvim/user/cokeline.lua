local cokeline = require("cokeline")
local hlgroups = require("cokeline.hlgroups")

local get_hex = hlgroups.get_hl_attr

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
				return buffer.filename .. " " end,
			bold = function(buffer)
				return buffer.is_focused end,
			underline = function(buffer)
				return buffer.is_hovered and not buffer.is_focused end,
		},
		{
			text = function(buffer)
				return buffer.is_modified and "● " or "" end,
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

