require "globalvar"
local skynet = require "skynet"
local snax = require "skynet.snax"
local socket = require "skynet.socket"
local protocoder = require "proto.protocoder"
local ActionMap = require "proto.actionmap"

local CMD = {}
local client_fd
local user_id
local config

function send_frame(data)
    local package = string.pack(">s2", data)
    socket.write(client_fd, package)
end

local function normalize_action(action)
    local action = action
    if not action or action == "" then
        action = "index.index"
    end
    action = string.lower(action)
    action = string.gsub(action, "[^%a.]", "")
    action = string.gsub(action, "^[.]+", "")
    action = string.gsub(action, "[.]+$", "")

    -- demo.hello.say --> {"demo", "hello", "say"]
    local parts = string.split(action, ".")
    local c = #parts
    if c == 1 then
        return string.ucfirst(parts[1]), "index"
    end
    -- method = "say"
    method = parts[c]
    table.remove(parts, c)
    c = c - 1
    -- mdoule = "demo.Hello"
    parts[c] = string.ucfirst(parts[c])
    return table.concat(parts, "."), method
end

local function dispatch_action(action_id,user_id,data)
    local actionName = ActionMap.id2name[action_id]
    local action = ActionMap[actionName]
    local moduleName, methodName = normalize_action(action.server_action)
    methodName = methodName .. "Action"
    modulePath = string.format("action.%s%s", moduleName, "Action")
    local ok, _actionModule = pcall(require,  modulePath)
    local actionModule
    if ok then
        actionModule = _actionModule
    else
        local err = _actionModule
        local pos = string.find(err, "\n")
        if pos then
            err = string.sub(err, 1, pos - 2)
        end
        skynet.error("failed to load action module \"%s\", %s", actionModulePath, err)
    end

    local t = type(actionModule)
    if t ~= "table" and t ~= "userdata" then
        skynet.error("failed to load action module \"%s\"", actionModulePath or actionModuleName)
    end

    local action = actionModule.create(config)
    action.user_id = user_id
    local method = action[methodName]
    if type(method) ~= "function" then
        skynet.error("invalid action method \"%s:%s()\"", actionModuleName, actionMethodName)
    end

    data = data or {}

    local actionName, rawmsg = method(action, data)
    if actionName and rawmsg then
        return protocoder:encode(actionName,rawmsg)
    end
end

-- {id, action, time, data}
skynet.register_protocol {
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function (msg, sz)
        if msg and sz and sz > 1 then
            local rawmsg = skynet.unpack(msg,sz)
            local data = protocoder:decode(rawmsg)
            return data
        else
            return nil
        end
    end,
    dispatch = function (_, __, msg)
        if msg and type(msg) == "table" then
            local action_id = msg.action_id
            user_id = msg.user_id
            protocoder.user_id = user_id
            local ret = dispatch_action(action_id,msg.user_id,msg.content)
            if ret then
                send_frame(ret)
            end
        end
    end
}

function CMD.start(conf)
    config = conf
    client_fd = conf.client
    config.agent = skynet.self()
    skynet.call(conf.gate, "lua", "forward", client_fd, skynet.self())
end

function CMD.send(actionName,rawmsg)
    local msg = protocoder:encode(actionName,rawmsg)
    send_frame(msg)
end

function CMD.disconnect()
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(_,_, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
end)