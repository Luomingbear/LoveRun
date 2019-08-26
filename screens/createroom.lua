-- 创建房间的场景
local class = require('lib.hump.class')
local keys = require('lib.keys')
local socket = require "socket"
local pass = keys.A

local CreateRoomScreen = class{}

function CreateRoomScreen:init(ScreenManager)
    self.screen = ScreenManager 
end

function CreateRoomScreen:activate()
    -- 先断开所有的链接

end

function CreateRoomScreen:draw()
    love.graphics.print("Create")
end

function CreateRoomScreen:keypressed(key)
    if key == keys.A then
        pass = keys.A
    elseif key == keys.X then 
        pass = keys.X
    elseif key == keys.Y then
        pass = keys.Y
    elseif key == keys.B then
        --back home
        self.screen:view('/', 'reset')
    end
end

return CreateRoomScreen