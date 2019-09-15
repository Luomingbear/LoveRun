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


local manager = {}

function manager:load()
    local threadCode = [[
    local destory = false
    local sock = require("lib.socket_enet")
    while (true) do
        -- 接收跨线程数据
        info = love.thread.getChannel("socket"):pop()
        if info == nil then
        elseif info.key == "on" then
          sock:on(info.data)
        elseif info.key == "serverSend" then
          sock:serverSend(info.data)
        elseif info.key == "connect" then
          sock:connect(info.data)
        elseif info.key == "clientSend" then
          sock:clientSend(info.data)
        elseif info.key == "destroy" then
          sock:destroy()
        end
    end
    ]]
    self.thread = love.thread.newThread(threadCode)
    self.thread:start()
end

-- 开启server
function manager:on()
  love.thread.getChannel("socket"):push({key="on", data = "\"localhost:6789\""})
  print("\non\n")
end

function manager:serverSend(info)
  love.thread.getChannel("socket"):push({key="serverSend", data = info})
  print(string.format("\nserverSend:%s\n",info.k))
end

function manager:connect(url)
    love.thread.getChannel("socket"):push({key="connect", data = url})
    print("\nconnect\n")
end

function manager:clientSend(info)
    love.thread.getChannel("socket"):push({key="clientSend", data = info})
    print("\nclientSend\n")
  end

function manager:destroy()
    love.thread.getChannel("socket"):push({key="destroy", data = nil})
    print("\ndestroy\n")
end

return manager