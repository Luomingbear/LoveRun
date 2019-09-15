local enet = require("enet")

function TableToStr(t)
  if t == nil then return "" end
  local retstr= "{"

  local i = 1
  for key,value in pairs(t) do
      local signal = ","
      if i==1 then
        signal = ""
      end

      if key == i then
          retstr = retstr..signal..ToStringEx(value)
      else
          if type(key)=='number' or type(key) == 'string' then
              retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
          else
              if type(key)=='userdata' then
                  retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
              else
                  retstr = retstr..signal..key.."="..ToStringEx(value)
              end
          end
      end

      i = i+1
  end

   retstr = retstr.."}"
   return retstr
end

function StrToTable(str)
  if str == nil or type(str) ~= "string" then
      return
  end
  
  return loadstring("return " .. str)()
end

sockets = {}

local serverHost = nil
local clientHost = nil

--server
function sockets:on(url)
    serverHost = enet.host_create(url)
    love.thread.getChannel("debug"):push({key="server创建连接。。。",data=url})
    local event = nil
    while true do
        local event = serverHost:service(100)
        while event do
          if event.type == "receive" then
            if event.data ~= nil then
              love.thread.getChannel("server"):push({key = "server接收到数据",data = event.data})
              love.thread.getChannel("debug"):push({key="server接收到数据",data = event.data})
            end
            event.peer:send( "pong" )
          elseif event.type == "connect" then
            love.thread.getChannel("server"):push({key="connect",data=nil})
            love.thread.getChannel("debug"):push({key="server已创建连接",data=url})
          elseif event.type == "disconnect" then
            love.thread.getChannel("server"):push({key="disconnect",data=nil})
            love.thread.getChannel("debug"):push({key="server断开连接",data=url})
          end
          event = serverHost:service()
        end
    end
end

function sockets:threadOn(url)
  local code = [[
    local socket = require("socket_enet")
    socket:connect(
    ]]..url..")"
end

function sockets:serverSend(data)
    if serverHost then
        local peer = serverHost:get_peer(1)
        if peer then
            peer:send(data)
        end
        love.thread.getChannel("debug"):push({key="server发送数据",data=TableToStr(data)})
    end
end


--client
function sockets:connect(url)
    clientHost = enet.host_create()
    local server = clientHost:connect(url)
    --while true do
      local event = clientHost:service(100)
      while event do
        if event.type == "receive" then
          print("Got message: ", event.data, event.peer)
          love.thread.getChannel("client"):push({key = "client接收到数据",data = event.data}) 
          love.thread.getChannel("debug"):push({key = "client接收到数据",data = event.data}) 
          event.peer:send( "ping" )
        elseif event.type == "connect" then
          print(event.peer, "connected.")
          love.thread.getChannel("client"):push({key="connect",data=nil})
          love.thread.getChannel("debug"):push({key="client已连接",data=url})
          event.peer:send( "ping" )
        elseif event.type == "disconnect" then
          print(event.peer, "disconnected.")
          love.thread.getChannel("client"):push({key="disconnect",data=nil})
          love.thread.getChannel("debug"):push({key="client断开连接",data=url})
        end
        event = clientHost:service()
      end
    --end
end

function sockets:clientSend(data)
    if clientHost then
        local peer = clientHost:get_peer(1)
        if peer then
            peer:send(data)
        end
        love.thread.getChannel("debug"):push({key="client发送数据",data=TableToStr(data)})
    end
end


function sockets:destroy()
  if serverHost then
    serverHost:destroy()
  end
  if clientHost then
    clientHost:destroy()
  end
  love.thread.getChannel("debug"):push({key="销毁网络",data=data})
end

return sockets