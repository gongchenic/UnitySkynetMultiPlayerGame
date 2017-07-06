require "globalvar"
local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "skynet.snax"

local Battle = require "battle.battle"
local battle = {}
local agents = {}

function response.add(args)
    local user_id = args.user_id
    agents[user_id] = args.agent

    -- 添加玩家
    local game_id = battle:addPlayer(user_id)
    local ret = {}
    ret.gameID = game_id
    ret.servertime = battle.model:timestamp()
    ret.trees = {}
    for id,ori in pairs(battle.trees) do
        table.insert(ret.trees, ori)
    end
    return ret
end

function response.update(args)
    local user_id = args.user_id
    local cmd = args.cmd
    battle.cmdmanager:apply(cmd)
    return true
end

function accept.exit(...)
    snax.exit(...)
end

local function doframe()
    battle:view()
    local snapshot = {}
    snapshot.time = battle.model.__snapshot
    snapshot.state = {}
    for _,ori in pairs(battle.model.__state) do
        local playerState = clone(ori)
        playerState.lastupdate = nil
        table.insert(snapshot.state, clone(playerState))
    end
    for user_id,agent in pairs(agents) do
        skynet.send(agent,"lua","send", "S_2_C_GAME_UPDATE", snapshot)
    end
end

function init( ... )
    local info = {}
    battle = Battle.create(info)
    battle:addSimulater("AI1")
    battle:addSimulater("AI2")
    battle:addSimulater("AI3")
    battle:addSimulater("AI4")
    battle:addSimulater("AI5")
    battle:addSimulater("AI6")
    battle:addSimulater("AI7")
    battle:addSimulater("AI8")
    battle:addSimulater("AI9")
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
            battle:controlSimulater()
            skynet.sleep(100 * math.random(5))
        end
    end)
end

function exit(...)
end