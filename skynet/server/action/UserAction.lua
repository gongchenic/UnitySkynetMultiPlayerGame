-----------------------------------------------------------------------------
-- 创建者  : gogo
-- 创建时间: 2016-03-30 17:51:57
-- 功能说明: 用户相关
-----------------------------------------------------------------------------
local skynet = require "skynet"

local UserAction = class("UserAction")

function UserAction:ctor(connect)
    self.connect = connect
end

function UserAction:loginAction(data)
    local ret = {}
    ret.id = self.user_id
    ret.success = true
    Log("ret.id =============== ",ret.id)
    return "S_2_C_LOGIN", ret
end

return UserAction
