local Constant = {}

Constant.restitution = 1
Constant.friction = 0
Constant.epsilon = 1e-5
Constant.maxspeed = 500
Constant.acceleration = 1200
Constant.out_of_control = 0.0001
Constant.init_radius = 30

-- websocket
Constant.WEBSOCKET_TEXT_MESSAGE_TYPE           = "text"
Constant.WEBSOCKET_BINARY_MESSAGE_TYPE         = "binary"
Constant.WEBSOCKET_SUBPROTOCOL_PATTERN         = "quickserver%-([%w%d%-]+)"
Constant.WEBSOCKET_DEFAULT_TIME_OUT            = 10 * 1000 -- 10s
Constant.WEBSOCKET_DEFAULT_MAX_PAYLOAD_LEN     = 16 * 1024 -- 16KB
Constant.WEBSOCKET_DEFAULT_MAX_RETRY_COUNT     = 5 -- 5 times
Constant.WEBSOCKET_DEFAULT_MAX_SUB_RETRY_COUNT = 10 -- 10 timess

return Constant
