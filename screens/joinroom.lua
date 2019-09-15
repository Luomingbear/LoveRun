-- 加入房间的场景 路由参数{online = true} ,如果online == true 表示联机，否则表示离线
local class = require('lib.hump.class')

-- 密码框
function rect(text,x,y)
    local object = {
        text = text,
        x = x,
        y = y
    }

    function object:update(dt)
    
    end


    function object:draw()
        love.graphics.setColor(40,40,40)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("fill",140,100,40,40,8,8)
        love.graphics.setColor(80,80,80)
        love.graphics.rectangle("line",140,100,40,40,8,8)
        love.graphics.setColor(181,74,92)
        drawText(self.text,self.x,self.y,14)
    end

    return object
end

local JoinRoomScreen = class{}

function JoinRoomScreen:init(ScreenManager)
    self.screen = ScreenManager 
end

function JoinRoomScreen:activate()
    love.graphics.clear(100,100,100)
end

function JoinRoomScreen:update(dt)
	socket:update(dt)
    info = love.thread.getChannel("client"):pop()
    if info == nil then
    elseif info.key == "s" then
        -- 开始游戏 
        self.screen:view("game/track",{online = true ,isServer = false})
    elseif info.key =="l" then
        -- 离开房间
        self.screen:view("/")
    elseif info.key =="connect" then
        -- 连接上
        socket:clientSend({key="i",data = nil})
    elseif info.key =="disconnect" then
        -- 断开联接
        self.screen:view("/")
    end 
end

function JoinRoomScreen:draw()
    love.graphics.clear(0,100,100)
    love.graphics.print("Join")

end

function JoinRoomScreen:keypressed(key)
    if (key == keys.A) then
        -- socket:connect("\"192.168.0.17:6789\"")
        socket:connect("\"localhost:6789\"")
    elseif key == keys.B then
        --back home
        socket:destroy()
        self.screen:view('/', 'reset')
    end
end

return JoinRoomScreen