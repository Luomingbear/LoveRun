local class = require('lib.hump.class')
local keys = require('lib.keys')

local RunScreen = class{}

function RunScreen:init(ScreenManager)
    self.screen = ScreenManager
end

function RunScreen:activate()
	love.graphics.clear(1,1,1) 
end

local function player(x, y)

    local status = 0

    local object = {
        x = x,
        y = y,
    }

    function object:setStatus(s)
        self.status = s
    end        

    function object:getStatus()
        return self.status
    end

    function object:isMaxHeight()
        return self.y - 180 <= 0
    end

    function object:isOnTheFloor()
        return self.y - 200 >= 0
    end

    function object:jumping(vy)
        self.y = self.y - (vy or 0)
        print(self.y)
    end

    function object:failing(vy)
        self.y = self.y + (vy or 0)
        print(self.y)
    end

    function object:move(vx)
        self.x = self.x + (vx or 0)
    end

    function object:draw()
        love.graphics.setColor(148,134,168)
        love.graphics.circle("fill", self.x, self.y, 15)
    end
    return object
end

local playerA = player(30, 200)
local moveSpeed = 200
local jumpSpeed = 100
local lastPressed

function RunScreen:update(dt)
    local vx = 0
    local vy = 0
    
    if love.keyboard.isDown(keys.DPad_right) then
        if lastPressed == keys.DPad_right then return end
        vx = moveSpeed
        playerA:move(vx * dt)
        lastPressed = keys.DPad_right
    end
    if love.keyboard.isDown(keys.DPad_left) then
        if lastPressed == keys.DPad_left then return end
        vx = moveSpeed
        playerA:move(vx * dt)
        lastPressed = keys.DPad_left
    end
    if love.keyboard.isDown(keys.A) then
        if lastPressed == nil then return end
        --vy = jumpSpeed
        playerA:setStatus(1)
        lastPressed = keys.A
    end

    if playerA:getStatus() == 1 and (not playerA:isMaxHeight()) then
        playerA:jumping(jumpSpeed * dt)
        print("jumping")
    end
    if playerA:getStatus() == 1 and playerA:isMaxHeight() then
        playerA:setStatus(2)
        playerA:failing(jumpSpeed * dt)
        print("failing1")
    end
    if playerA:getStatus() == 2 and (not playerA:isOnTheFloor()) then
        playerA:failing(jumpSpeed * dt)
        print("failing2")
    end
    if playerA:getStatus() == 2 and playerA:isOnTheFloor() then
        playerA:setStatus(0)
        print("idle")
    end

end

function RunScreen:keypressed(key)
    if key == keys.A then
        lastPressed = keys.A
    end
    if key == keys.B then
        self.screen:view('/', 'reset')
    end
end

function RunScreen:draw()
    playerA:draw()
end

return RunScreen