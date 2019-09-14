local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')

local function athlete(x, y)
    
    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        width = 40,
        height = 40,
        xVelocity = 0, -- x方向速度
        yVelocity = 0, -- y方向速度
        jumpHeight = -130, -- 跳跃高度
        force = 30, -- 前进动力
        maxSpeed = 200, -- 最大速度
        gravity = -240, -- 重力
        ground = y, -- 地面坐标
        xDuration = 0,
        yDuration = 0,
        sprite = peachy.new("assets/images/runer2run.json", love.graphics.newImage("assets/images/runer2run.png"), "Idle")
    }

    function object:jump()
        if self.yVelocity == 0 then
            self.yVelocity = self.jumpHeight
        end
    end

    function object:move(dt)
        self.xVelocity = self.force
        self.xDuration = 200 * dt
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

local playerA = athlete(30, 180)
local hurdle1 = hurdle(150, 195)
local lastPressed

platform = {}

-- 碰撞点
function pointTest(x,y,l,t,r,b)
	if x< l or x> r or y< t or y>b then return false end
	return true
end

-- 碰撞盒
function bodyTest(Al,At,Ar,Ab,Bl,Bt,Br,Bb)
	if pointTest(Al,At,Bl,Bt,Br,Bb) 
		or pointTest(Ar,At,Bl,Bt,Br,Bb) 
		or pointTest(Al,Ab,Bl,Bt,Br,Bb) 
		or pointTest(Ar,Ab,Bl,Bt,Br,Bb) then
        return true
    else 
        return false
	end
end

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

    playerA:update(dt)
    hurdle1:update(dt)
end

function TrackScreen:draw()

    love.graphics.print(tostring(bodyTest(playerA.x, playerA.y, playerA.x + playerA.width, playerA.y + playerA.height, hurdle1.x, hurdle1.y, hurdle1.x + hurdle1.width, hurdle1.y + hurdle1.height)), 140, 30)
    love.graphics.print(math.floor(playerA.x), 60, 30)
    love.graphics.print(math.floor(playerA.y),100,30)
    love.graphics.setColor(255, 255, 255)

    playerA:draw()
    hurdle1:draw()
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