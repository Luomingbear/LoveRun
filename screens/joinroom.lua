-- 加入房间的场景
local class = require('lib.hump.class')

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