--网络管理类

--[[
  在最外层的main.lua的load 调用socket:load()
-- main.lua
socket = require("lib.socket_m")
function love.load()
  socket:load()
end

-- server on
socket:on()
-- server send
socket:ServerSend(data)
-- server recive 在update里面监听
info = love.thread.getChannel("server"):pop() --info的格式 {key="recive",data=""}

-- client connect
socket:connect()
-- client send
socket:ClientSend(data)
-- client recive 在update里面监听
info = love.thread.getChannel("client"):pop() --info的格式 {key="recive",data=""}

]]

local sockets = require("lib.socket_enet")
local manager = {}

local threadCode = [[
local sockets = require("lib.socket_enet")
love.thread.getChannel("debug"):push({key="load"})
while true do
    -- 接收跨线程数据
    local info = love.thread.getChannel("socket"):pop()
    if info == nil then
    elseif info.key == "on" then
      love.thread.getChannel("debug"):push(info)
      sockets:on(info.data)
    elseif info.key == "serverSend" then
      sockets:serverSend(info.data)
      love.thread.getChannel("debug"):push(info.data)
    elseif info.key == "connect" then
      sockets:connect(info.data)
      love.thread.getChannel("debug"):push(info.data)
    elseif info.key == "clientSend" then
      sockets:clientSend(info.data)
      love.thread.getChannel("debug"):push(info.data)
    elseif info.key == "destroy" then
      sockets:destroy()
      love.thread.getChannel("debug"):push({key = "销毁",data = nil})
    end
end
]]

function manager:load()
    self.thread = love.thread.newThread(threadCode)
    self.thread:start()
end

function manager:update(dt)
  local info = love.thread.getChannel("debug"):pop()
  if info ~= nil then
    print(string.format("debug:%s",info.key))
  end
end

-- 开启server
function manager:on()
  love.thread.getChannel("socket"):push({key="on", data = "localhost:6789"})
end

function manager:serverSend(info)
  -- sockets:serverSend(info)
  love.thread.getChannel("socket"):push({key="serverSend", data = info})
end

function manager:connect(url)
    love.thread.getChannel("socket"):push({key="connect", data = url})
end

function manager:clientSend(info)
    love.thread.getChannel("socket"):push({key="clientSend", data = info})
  end

function manager:destroy()
    love.thread.getChannel("socket"):push({key="destroy", data = nil})
end

return manager