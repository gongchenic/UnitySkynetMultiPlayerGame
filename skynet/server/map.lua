require "globalvar"
local skynet = require "skynet"
require "skynet.manager"

local Game = require "game.game"
local game

-- 游戏内数据
local command = {}

function command.add(id,cmd)
	game:add(id)
	local ret = {}
	ret.action = "add"
	ret.servertime = game.model:timestamp()
	ret.trees = {}
	for id,ori in pairs(game.trees) do
		table.insert(ret.trees, ori)
	end
	return ret
end

function command.update(id,cmd)
	game:action(cmd)
end

function command.attack(id,cmd)
	game:attack(cmd)
end

function command.query(id)
	local snapshot = {}
	snapshot.action = "query"
	snapshot.time = game.model.__snapshot
	snapshot.state = {}
	for id,ori in pairs(game.model.__state) do
		table.insert(snapshot.state, ori)
	end
	return snapshot
end

local function reopen()
	local chapter = 1
	local info = {}
	game = Game.create(info)
	game:addAI("AI1")
end

local function doframe()
	game:view()
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "map"
	reopen()
	skynet.fork(function()
        while true do
            local ok,err = pcall(doframe)
            if not ok then
            	Log("err : ",err)
            end
            skynet.sleep(5)
        end
    end)
    skynet.fork(function()
        while true do
        	game:controlAI()
            skynet.sleep(100 * math.random(5))
        end
    end)
end)