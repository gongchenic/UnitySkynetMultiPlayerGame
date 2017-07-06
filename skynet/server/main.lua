local skynet = require "skynet"
require "skynet.manager"
local snax = require "skynet.snax"

local max_client = 3000

skynet.start(function()
	local game = snax.uniqueservice("game")
	local gate = skynet.newservice("gate")
	local watchdog = skynet.newservice("watchdog",gate)
	skynet.call(watchdog, "lua", "start", {
		port = skynet.getenv("websocketport"),
		maxclient = max_client,
		nodelay = true,
	})
	skynet.exit()
end)