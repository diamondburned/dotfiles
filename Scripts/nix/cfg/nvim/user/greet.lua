local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
require("alpha.term")

local artsDir = os.getenv("XDG_CONFIG_HOME") .. "/nvim/arts/"
local arts = {
	-- artsDir .. "astolfo_2x1.txt",
	-- artsDir .. "astolfo_watch_2x1.txt",
	artsDir .. "needystreamer_2x1.txt",
}

local function half_padding()
	local height = math.floor(vim.api.nvim_win_get_height(0) / 2)
	-- spare half the art's height
	return height - (20 / 2)
end

-- dashboard.section.terminal.opts.redraw = true
dashboard.section.terminal.command = "sh -c cat\\ " .. arts[math.random(#arts)]
dashboard.section.terminal.width = 80
dashboard.section.terminal.height = 20

dashboard.config.layout = {
	{ type = "padding", val = half_padding },
	dashboard.section.terminal,
	{ type = "padding", val = 2 },
	{
		type = "text",
		val = "<3",
		opts = {
			position = "center",
			hl = "GreetFooter",
		},
	},
	{ type = "padding", val = 1 },
}

vim.cmd([[hi GreetFooter gui=bold guifg=#FFD1DC]])

alpha.setup(dashboard.config)
