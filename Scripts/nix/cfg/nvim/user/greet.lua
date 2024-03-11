local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
require("alpha.term")

local artsDir = os.getenv("XDG_CONFIG_HOME") .. "/nvim/arts/"
local arts = {
	artsDir .. "astolfo_2x1.txt",
	artsDir .. "astolfo_watch_2x1.txt",
	artsDir .. "needystreamer_2x1.txt",
}

local padding = 2

dashboard.section.terminal.opts.redraw = true
dashboard.section.terminal.command = "cat " .. arts[math.random(#arts)]
dashboard.section.terminal.width = 80
dashboard.section.terminal.height = 20

dashboard.config.layout = {
	{ type = "padding", val = padding },
	dashboard.section.terminal,
	{ type = "padding", val = padding },
}

alpha.setup(dashboard.config)
