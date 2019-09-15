local enet = require("enet")

socket = {}

local serverHost = nil
local clientHost = nil

--server
function socket:on(url)
    love.thread.getChannel("server"):push({key="开始",data=url})
    serverHost = enet.host_create(url)
    local event = nil
    while true do
        local event = serverHost:service(100)
        while event do
          if event.type == "receive" then
            print("Got message: ", event.data, event.peer)
            love.thread.getChannel("server"):push({key="receive",data=event.data})
            event.peer:send( "pong" )
          elseif event.type == "connect" then
            print(event.peer, "connected.")
            love.thread.getChannel("server"):push({key="connect",data=nil})
          elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
            love.thread.getChannel("server"):push({key="disconnect",data=nil})
          end
          event = serverHost:service()
        end
    end
end

function socket:threadOn(url)
  local code = [[
    local socket = require("socket_enet")
    socket:connect(
    ]]..url..")"
end

function socket:serverSend(data)
    if serverHost then
        local peer = serverHost:get_peer(1)
        if peer then
            peer:send(data)
        end
    end
end


--client
function socket:connect(url)
    clientHost = enet.host_create()
    local server = clientHost:connect(url)
    --while true do
      local event = clientHost:service(100)
      while event do
        if event.type == "receive" then
          print("Got message: ", event.data, event.peer)
          love.thread.getChannel("client"):push({key="receive",data=event.data})
          event.peer:send( "ping" )
        elseif event.type == "connect" then
          print(event.peer, "connected.")
          love.thread.getChannel("client"):push({key="connect",data=event.data})
          event.peer:send( "ping" )
        elseif event.type == "disconnect" then
          print(event.peer, "disconnected.")
          love.thread.getChannel("client"):push({key="disconnect",data=event.data})
        end
        event = clientHost:service()
      end
    --end
end

function socket:clientSend(data)
    if clientHost then
        local peer = clientHost:get_peer(1)
        if peer then
            peer:send(data)
        end
    end
end


function socket:destroy()
  if serverHost then
    serverHost:destroy()
  end
  if clientHost then
    clientHost:destroy()
  end
end

---------------------- 网络管理 ------------------