local Constants = {}

Constants.templet_user = "newplayer"

Constants.init_user = {
	regpf = "",
	regdate = "",
	regtime = "",
	loginpf = "",
	logintime = "",
	openid = "",
	deviceid = "",
	isbinded = false,
}

local ret_info = {
	player = {},
	heros = {},
}

Constants.getRetInfoTable = function()
	return clone(ret_info)	
end

Constants.getRetOtherInfoTable = function()
	return clone(ret_info)
end

local ret_reward = {
	player = {},
	heros = {},
}

Constants.getRetRewardTable = function()
	return clone(ret_reward)	
end

Constants.USER_ID_BASE = 1000000

-- request type
Constants.HTTP_REQUEST_TYPE      = "http"
Constants.WEBSOCKET_REQUEST_TYPE = "websocket"
Constants.CLI_REQUEST_TYPE       = "cli"

-- action
Constants.ACTION_PACKAGE_NAME                   = 'actions'
Constants.DEFAULT_ACTION_MODULE_SUFFIX          = 'Action'
Constants.MESSAGE_FORMAT_JSON                   = "json"
Constants.MESSAGE_FORMAT_TEXT                   = "text"
Constants.DEFAULT_MESSAGE_FORMAT                = Constants.MESSAGE_FORMAT_JSON

-- redis keys
Constants.NEXT_CONNECT_ID_KEY                   = "_NEXT_CONNECT_ID"
Constants.NEXT_USER_ID_KEY                   	= "_NEXT_USER_ID"
Constants.NEXT_GAME_ID_KEY						= "_NEXT_GAME_ID"
Constants.NEXT_FAKER_ID_KEY                   	= "_NEXT_FAKER_ID"
Constants.NEXT_EQUIP_ID_KEY                   	= "_NEXT_EQUIP_ID"
Constants.NEXT_HERO_ID_KEY                   	= "_NEXT_HERO_ID"
Constants.NEXT_BILL_ID_KEY                   	= "_NEXT_BILL_ID"
Constants.NEXT_PUBLIC_MAIL_ID_KEY               = "_NEXT_PUBLIC_MAIL_ID"
Constants.NEXT_PRIVATE_MAIL_ID_KEY              = "_NEXT_PRIVATE_MAIL_ID"
Constants.NEXT_CHAT_ID_KEY                   	= "_NEXT_CHAT_ID"
Constants.NEXT_GUILD_ID_KEY                   	= "_NEXT_GUILD_ID"
Constants.CONNECT_CHANNEL_PREFIX                = "_C"
Constants.RANK_PREFIX_VERSION                	= "_RANK_VERSION_"
Constants.RANK_VERSION_RANGE                 	= 200

-- websocket
Constants.WEBSOCKET_TEXT_MESSAGE_TYPE           = "text"
Constants.WEBSOCKET_BINARY_MESSAGE_TYPE         = "binary"
Constants.WEBSOCKET_SUBPROTOCOL_PATTERN         = "quickserver%-([%w%d%-]+)"
Constants.WEBSOCKET_DEFAULT_TIME_OUT            = 10 * 1000 -- 10s
Constants.WEBSOCKET_DEFAULT_MAX_PAYLOAD_LEN     = 16 * 1024 -- 16KB
Constants.WEBSOCKET_DEFAULT_MAX_RETRY_COUNT     = 5 -- 5 times
Constants.WEBSOCKET_DEFAULT_MAX_SUB_RETRY_COUNT = 10 -- 10 times

return Constants
