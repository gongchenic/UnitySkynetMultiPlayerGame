-----------------------------------------------------------------------------
-- 创建者  : gogo
-- 创建时间: 2017-06-28 11:47:00
-- 功能说明: 游戏相关
-----------------------------------------------------------------------------
local skynet = require "skynet"
local snax = require "skynet.snax"

local GameAction = class("GameAction")

function GameAction:ctor(connect)
    self.connect = connect
end

function GameAction:matchAction(data)
	local game = snax.queryservice("game")
	local args = {}
	args.user_id = self.user_id
	Log("args.user_id ================ ",self.user_id)
	args.agent = self.connect.agent
	local ret = game.req.add(args)
    return "S_2_C_GAME_MATCH", ret
end

function GameAction:updateAction(data)
	local game = snax.queryservice("game")
	local args = {}
	args.user_id = self.user_id
	args.cmd = data
	local ret = game.req.update(args)
end

return GameAction