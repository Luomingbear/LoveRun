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
        local info = love.thread.getChannel("server").pop()
        if info == nil then
        elseif info.key == "s" then 
            -- 开始游戏        
            self.screen:view("game/track",{online = true ,isServer = false})
        end 
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

function JoinRoomScreen:draw()
    love.graphics.clear(0,100,100)
    love.graphics.print("Join")

end
return JoinRoomScreen