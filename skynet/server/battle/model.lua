local skynet = require "skynet"
local MAP_SIZE = {x = 30, y = 30}
local QUEUE_LENGTH = 100

local function MIN_MAX(pos)
	pos.x = math.min(pos.x,MAP_SIZE.x)
	pos.y = math.min(pos.y,MAP_SIZE.y)
	pos.x = math.max(pos.x,-MAP_SIZE.x)
	pos.y = math.max(pos.y,-MAP_SIZE.y)
end

local Model = class("Model")

function Model.create(servertime)
    return Model.new(servertime)
end

function Model:ctor(servertime)
	self.__base = {}
	self.__state = {}
	self.__begintime = Model:gettime()
	self.__offsettime = Model:gettime() - servertime
	self.__command_queue = {}
	self.__snapshot = 0

	local method = {}
	function method.add (state, oriargs)
		local args = clone(oriargs)
		local obj = {
			gameID = args.gameID,
			heroID = args.heroID,
			hp = args.hp,
			pos = args.pos,
			dir = args.dir,
			face = args.face,
			speed = args.speed,
			lastupdate = args.lastupdate,
		}
		state[obj.gameID] = obj
	end

	function method.move (state, args)
		local gameID = args.gameID
		local dir = args.dir
		local t = args.timestamp
		local obj = state[gameID]
		if obj then
			if obj.hp > 0 then
				local dis_x = (t - obj.lastupdate) * obj.dir.x * obj.speed.x
				local dis_y = (t - obj.lastupdate) * obj.dir.y * obj.speed.y
				obj.pos.x = obj.pos.x + dis_x
				obj.pos.y = obj.pos.y + dis_y
				MIN_MAX(obj.pos)
				obj.dir = dir
				if dir.x ~= 0 or dir.y ~= 0 then obj.face = dir end
			end
			obj.lastupdate = t
		end
	end

	function method.revive(state, args)
		local gameID = args.gameID
		local obj = state[gameID]
		if obj then
			obj.hp = 100
		end
	end

	function method.attack (state, args)
		local gameID = args.gameID
		local t = args.timestamp
		local obj = state[gameID]
		if obj and obj.hp > 0 then
			if obj.hp > 0 then
				local dis_x = (t - obj.lastupdate) * obj.dir.x * obj.speed.x
				local dis_y = (t - obj.lastupdate) * obj.dir.y * obj.speed.y
				obj.pos.x = obj.pos.x + dis_x
				obj.pos.y = obj.pos.y + dis_y
				MIN_MAX(obj.pos)
				obj.lastupdate = t
			end
			for tarID,tar in pairs(state) do
				if gameID ~= tarID then
					if tar.hp > 0 then
						local dis_x = (t - tar.lastupdate) * tar.dir.x * tar.speed.x
						local dis_y = (t - tar.lastupdate) * tar.dir.y * tar.speed.y
						tar.pos.x = tar.pos.x + dis_x
						tar.pos.y = tar.pos.y + dis_y
						MIN_MAX(tar.pos)
						tar.lastupdate = t
					end
					local dis = Subtract(tar.pos,obj.pos)
					local dis_m = Magnitude(dis)
					if dis_m < ATTACK_RANGE then
						obj.hp = obj.hp - 100
					end
				end
			end
			local animation = {}
			animation.aniID = 1
			animation.startTime = t
			obj.animation = animation
		end
	end

	self.__method = method
end

function Model:gettime()
	return skynet.time()
end

function Model:timestamp()
	return Model:gettime() - self.__offsettime
end

function Model:queue_command(args)
	local name = args.name
	local timestamp = args.timestamp

	if not args.name and not args.timestamp then
		return false
	end

	local qlen = #self.__command_queue
	if qlen >= QUEUE_LENGTH then
		table.remove(self.__command_queue,1)
		qlen = qlen - 1
	end

	local cq = self.__command_queue
	for i = 1, #cq do
		if timestamp < cq[i].timestamp then
			table.insert(cq, i, args)
			return i
		end
	end
	table.insert(cq, args)
	return #cq
end

function Model:touch_snapshot(ti)
	if ti < self.__snapshot then
		self.__snapinvalid = true
	end
end

function Model:apply_command(args)
	local name = args.name
	local timestamp = args.timestamp

	if not args.name and not args.timestamp then
		return false
	end

	local cq = self.__command_queue
	local qlen = #cq
	local timeline = cq[1] and cq[1].timestamp or 0
	if args.timestamp < timeline then
		return false, "command expired"
	end

	if qlen >= QUEUE_LENGTH then
		self.__method[cq[1].name](self.__base, cq[1])
		table.remove(self.__command_queue,1)
		qlen = qlen - 1
	end

	for i = 1, #cq do
		if timestamp < cq[i].timestamp then
			self:touch_snapshot(timestamp)
			table.insert(cq, i, args)
			return i
		end
	end
	self:touch_snapshot(timestamp)
	table.insert(cq, args)
	return #cq
end

function Model:snapshot(ti)
	assert(ti >= self.__snapshot)
	local cq = self.__command_queue
	if self.__snapinvalid then
		self.__state = clone(self.__base)
		self.__snapshot = 0
		self.__snapinvalid = false
	end
	for i = 1, #cq do
		local t = cq[i].timestamp
		local name = cq[i].name
		if t > ti then
			break
		end
		if t > self.__snapshot then
			self.__method[name](self.__state, cq[i])
		end
	end
	for gameID,obj in pairs(self.__state) do
		if obj.hp > 0 then
			local dis_x = (ti - obj.lastupdate) * obj.dir.x * obj.speed.x
			local dis_y = (ti - obj.lastupdate) * obj.dir.y * obj.speed.y
			obj.pos.x = obj.pos.x + dis_x
			obj.pos.y = obj.pos.y + dis_y
			MIN_MAX(obj.pos)
		end
		obj.lastupdate = ti
		if obj.animation and ti - obj.animation.startTime > 1 then
			obj.animation = nil
		end
	end
	self.__snapshot = ti
	return self.__state
end

return Model