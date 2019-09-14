local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')
local Camera = require('lib.hump.camera')

local function athlete(x, y)
    
    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        width = 40,
        height = 30,
        xVelocity = 0, -- x方向速度
        yVelocity = 0, -- y方向速度
        jumpHeight = -130, -- 跳跃高度
        force = 30, -- 前进动力
        maxSpeed = 200, -- 最大速度
        gravity = -240, -- 重力
        ground = y, -- 地面坐标
        xDuration = 0,
        fallDuration = 0,
        sprite = peachy.new("assets/images/runer2run.json", love.graphics.newImage("assets/images/runer2run.png"), "Idle")
    }

    function object:jump()
        if self.yVelocity == 0 then
            self.yVelocity = self.jumpHeight
        end
    end

    function object:move(dt)
        self.xVelocity = self.force
        self.xDuration = 150 * dt
    end

    function object:fall(dt)
        self.sprite:setTag("Fall")
        self.fallDuration = 350 * dt
    end

    function object:update(dt)

        self.sprite:play()

        if love.keyboard.isDown(keys.DPad_right) then
            self.sprite:setTag("Right")
        elseif love.keyboard.isDown(keys.DPad_left) then
            self.sprite:setTag("Left")
        else
            self.sprite:pause()
        end

        -- x轴
        if self.xVelocity ~= 0 then
            self.xVelocity = self.xVelocity + self.force
            self.xDuration = self.xDuration - 25 * dt
        end
        self.x = self.x + self.xVelocity * dt

        if self.xDuration <= 0 then
            self.xVelocity = 0
            self.sprite:setTag("Idle")
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
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height) -- 碰撞盒
        self.sprite:draw(self.x, self.y)
    end

    function object:getPoints()
        return self.x, self.y, self.x + self.width, self.y + self.height
    end

    return object
end

local function hurdle(x, y)

    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        width = 5,
        height = 25,
        ground = y
    }

    function object:update(dt)
        -- body
    end

    function object:draw()
        love.graphics.setColor(200, 200, 200)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end

    function object:getPoints()
        return self.x, self.y, self.x + self.width, self.y + self.height
    end

    return object
end

local TrackScreen = class {}

local playerA = athlete(0, 180)
local lastPressed

camera = {}
hurdleTable = {}

-- 矩形碰撞
function testRect(athlete, hurdle)
    return athlete.x<hurdle.x+hurdle.width and athlete.y<hurdle.y+hurdle.height and athlete.x+athlete.width>hurdle.x and athlete.y+athlete.height>hurdle.y
end

function TrackScreen:init(ScreenManager)
    self.screen = ScreenManager
end

function TrackScreen:activate()
    camera = Camera(0, 0)
    for i=1,10 do
        table.insert(hurdleTable, i, hurdle(200 * i, 185))
    end
    love.graphics.clear(1, 1, 1)
end

function TrackScreen:update(dt)

    if love.keyboard.isDown(keys.DPad_right) then
        if lastPressed ~= keys.DPad_right then
            playerA:move(dt)
            lastPressed = keys.DPad_right
        end
    end
    if love.keyboard.isDown(keys.DPad_left) then
        if lastPressed ~= keys.DPad_left then
            playerA:move(dt)
            lastPressed = keys.DPad_left
        end
    end
    if love.keyboard.isDown(keys.A) then
        if lastPressed ~= nil then
            playerA:jump()
            lastPressed = keys.A
        end
    end

    local dx,dy = playerA.x - camera.x, playerA.y - camera.y
    camera:move(dx/2, dy/2)

    playerA:update(dt)
end

function TrackScreen:draw()

    camera:attach()

    love.graphics.print(math.floor(playerA.x), 60, 30)
    love.graphics.print(math.floor(playerA.y),100,30)
    love.graphics.setColor(255, 255, 255)

    playerA:draw()

    for i=1,10 do
        hurdleTable[i]:draw()
    end

    camera:detach()
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