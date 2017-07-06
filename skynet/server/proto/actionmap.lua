local ACTION_MAP =
{
    -- 登陆模块
    C_2_S_LOGIN = { id = 10001, data_type = "json", pb_file = "MessageCode", server_action = "user.login" },
    S_2_C_LOGIN = { id = 10002, data_type = "json" },

    -- GAME模块
    C_2_S_GAME_MATCH = { id = 20001, data_type = "json", server_action = "game.match"},
    S_2_C_GAME_MATCH = { id = 20002, data_type = "json" },
    C_2_S_GAME_UPDATE = { id = 20003, data_type = "json", server_action = "game.update"},
    S_2_C_GAME_UPDATE = { id = 20004, data_type = "pb", pb_file = "BattleTick"},
}

local id2name = {}
for name,action in pairs(ACTION_MAP) do
    id2name[action.id] = name
end
ACTION_MAP.id2name = id2name

return ACTION_MAP