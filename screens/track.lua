local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')

local function athlete(x, y)
    
    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        xVelocity = 0, -- x方向速度
        yVelocity = 0, -- y方向速度
        jumpHeight = -80, -- 跳跃高度
        force = 20, -- 前进动力
        maxSpeed = 100, -- 最大速度
        gravity = -100, -- 重力
        ground = y, -- 地面坐标
        sprite = peachy.new("assets/images/runer2run.json", love.graphics.newImage("assets/images/runer2run.png"), "Left")
    }

    function object:jump()
        if self.yVelocity == 0 then
            self.yVelocity = self.jumpHeight
        end
    end

    function object:move()
        self.xVelocity = self.force
    end

    function object:update(dt)

        self.sprite:play()

        -- x轴
        if self.xVelocity ~= 0 then
            self.xVelocity = self.xVelocity + self.force
        end
        self.x = self.x + self.xVelocity * dt

        if self.xVelocity >= self.maxSpeed then
            self.xVelocity = 0
        end

        if love.keyboard.isDown(keys.DPad_right) then
            self.sprite:setTag("Right")
        elseif love.keyboard.isDown(keys.DPad_left) then
            self.sprite:setTag("Left")
        else
            self.sprite:pause()
        end

        -- y轴
        if self.yVelocity ~= 0 then
            self.y = self.y + self.yVelocity * dt
            self.yVelocity = self.yVelocity - self.gravity * dt
        end

        if self.y > self.ground then
            self.yVelocity = 0
            self.y = self.ground
        end

        self.sprite:update(dt)
    end

    function object:draw()
        love.graphics.setColor(148,134,168)
        love.graphics.rectangle("fill", self.x, self.y, 40, 38) -- 碰撞盒
        love.graphics.print(math.floor(self.y),100,30)
        self.sprite:draw(self.x, self.y)
    end
    return object
end

local TrackScreen = class {}

local playerA = athlete(30, 180)
local lastPressed

platform = {}

function TrackScreen:init(ScreenManager)
    self.screen = ScreenManager
end

function TrackScreen:activate()
    platform.width = love.graphics.getWidth()
    platform.height = love.graphics.getHeight()

    platform.x = 0
    platform.y = platform.height * 2 / 3

    love.graphics.clear(1, 1, 1)
end

function TrackScreen:update(dt)

    if love.keyboard.isDown(keys.DPad_right) then
        if lastPressed ~= keys.DPad_right then
            playerA:move()
            lastPressed = keys.DPad_right
        end
    end
    if love.keyboard.isDown(keys.DPad_left) then
        if lastPressed ~= keys.DPad_left then
            playerA:move()
            lastPressed = keys.DPad_left
        end
    end
    if love.keyboard.isDown(keys.A) then
        if lastPressed ~= nil then
            playerA:jump()
            lastPressed = keys.A
        end
    end

    playerA:update(dt)
end

function TrackScreen:draw()

    love.graphics.setColor(200, 200, 200)
    love.graphics.rectangle("fill", 100, 200, 5, 20)
    love.graphics.print(math.floor(playerA.x), 60, 30)
    love.graphics.setColor(255, 255, 255)

    playerA:draw()
end

function TrackScreen:keypressed(key)
    if key == keys.A then
        lastPressed = keys.A
    end
    if key == keys.B then
        self.screen:view('/', 'reset')
    end
end

return TrackScreen