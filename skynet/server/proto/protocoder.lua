local protobuf = require "protobuf"
local ActionMap = require "proto.actionmap"

local protocoder = {}

function protocoder:encode(actionName,rawMessage)
	local action = ActionMap[actionName]

	-- 将源内容json或pb编码，嵌套一个基础包
	local message = {}
	message.action_id = action.id
	message.user_id = self.id
	if action.data_type == "json" then
		message.content = json.encode(rawMessage)
	else
		message.content = protobuf.encode(action.pb_file, rawMessage)
	end

	return protobuf.encode("MessageBase", message)
end

function protocoder:decode(rawMessage)
	-- 解码基础包
	local message = protobuf.decode("MessageBase", rawMessage)

	local action_id = message.action_id
	local actionName = ActionMap.id2name[action_id]
	local action = ActionMap[actionName]

	-- 解码数据包
	local content = {}
	if action.data_type == "json" then
		content = json.decode(message.content)
	else
		content = protobuf.encode(action.pb_file, message.content)
	end
	message.content = content

	return message
end

function protocoder:init()
	protobuf.register_file("server/proto/MessageBase.pb")
	protobuf.register_file("server/proto/Battle.pb")
end
protocoder:init()

return protocoder