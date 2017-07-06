local skynet  = require "skynet"
local Model   = require "battle.model"
local Human   = require "object.human"
local Treeman = require "object.treeman"
local CmdManager = require "battle.cmdmanager"

SIGHT_RANGE = 9.5
ATTACK_RANGE = 2.3
SIGHT_TIME = 0.5
function Magnitude( v )
	return math.sqrt(v.x * v.x + v.y * v.y)
end
function Normalize( v )
	local m = Magnitude( v )
	if m < 0.001 then
		v.x, v.y = 0, 0
	else
		v.x, v.y = v.x / m, v.y / m
	end
end
function Multiply( a, b )
	return a.x * b.x + a.y * b.y
end
function Subtract( a, b )
	return { x = a.x - b.x , y = a.y - b.y }
end
local dirs = {
	{ x = 1, y = 0 },
	{ x = -1, y = 0 },
	{ x = 0, y = 1 },
	{ x = 0, y = -1 },
}
local Speed = {
	human = {x = 5, y = 5},
	treeman = {x = 4, y = 4},
}

local Battle = class("battle")

function Battle.create(info)
    return Battle.new(info)
end

function Battle:ctor(info)
	-- 初始化数据
	self.info = info
	self.players = {}
	self.simulaters = {}
	self.trees = {}

	-- 初始阵容
	self.model = Model.create(0)
	self.cmdmanager = CmdManager.create(self.model)
	--self:addTrees()
end

-- 每帧形成一次快照
function Battle:view()
	local now = self.model:timestamp()
	local snapshot = self.model:snapshot(now)
	return snapshot
end

function Battle:addPlayer(id)
	local gameID = self.players[id]
	-- 如果已经存在，复活
	if gameID then
		self.cmdmanager:revive(gameID)
		return gameID
	end

	local cmd = self.cmdmanager:add_player()

	gameID = cmd.gameID
	self.players[id] = gameID
	return gameID
end

function Battle:addSimulater(id)
	local gameID = self.simulaters[id]
	-- 如果已经存在，复活
	if gameID then
		self.cmdmanager:revive(gameID)
		return gameID
	end

	local cmd = self.cmdmanager:add_simulater()

	gameID = cmd.gameID
	self.simulaters[id] = gameID
	return gameID
end

function Battle:controlSimulater()
	for _,gameID in pairs(self.simulaters) do
		self.cmdmanager:move(gameID,dirs[math.random(4)])
	end
	for _,gameID in pairs(self.simulaters) do
		self.cmdmanager:attack(gameID)
	end
end

-- function Battle:addTrees()
-- 	for i = 1,50 do
-- 		local tree = {}
-- 		tree.pos = {x = math.random(-30,30),y = math.random(-30,30)}
-- 		tree.face = dirs[math.random(4)]
-- 		table.insert(self.trees, tree)
-- 	end
-- end

return Battle

