local class = require('lib.hump.class')
local keys = require('lib.keys')
local Camera = require('lib.hump.camera')

local RunScreen = class{}
-- 平台对象
platform = {} 

function RunScreen:init(ScreenManager)
    self.screen = ScreenManager
    self.camera = Camera(0,0)
end

function RunScreen:activate()
    platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
 
	platform.x = 0
	platform.y = platform.height / 2
 
	love.graphics.clear(1,1,1) 
end

local function player(x, y)

    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        x_v = 0, -- x加速度
        y_v = 0, -- y加速度
        jumpHeight = -50, --跳跃高度
        gravity = -100, -- 重力
        ground = y, -- 地面的高度
        force = 20, -- x推力
        maxSpeed = 25 --x最大的速度
    }

    function object:jump()
        if self.y_v ==0 then
            self.y_v = self.jumpHeight
        end
    end

    function object:move(dt)
        if self.x_v == 0 then
            self.x_v = self.force
        end
    end
 
    function object:update(dt)
        -- y轴
        if self.y_v~=0 then
            self.y = self.y + self.y_v * dt
            self.y_v = self.y_v-self.gravity * dt
        end

        if self.y > self.ground then
            self.y_v = 0
            self.y = self.ground
        end

        -- x轴
        if self.x_v ~= 0 then
            self.x_v = self.x_v + self.force * dt
        end
        self.x = self.x + self.x_v * dt

        if self.x_v >= self.maxSpeed then
            self.x_v = 0
        end
    end

    function object:draw()
        love.graphics.setColor(148,134,168)
        love.graphics.circle("fill", self.x, self.y, 15)
        love.graphics.print(self.y,100,30)
    end
    return object
end

local playerA = player(30, 200)
local lastPressed

function RunScreen:update(dt)
    -- 移动相机
    local dx,dy = playerA.x - self.camera.x, 200-self.camera.y
    self.camera:move(dx/2, dy/2)
    -- 
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
            --vy = jumpSpeed 
            lastPressed = keys.A
            playerA:jump()
        end
    end

    playerA:update(dt)

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
    self.camera:attach() 
    playerA:draw()
    self.camera:detach()
end

return RunScreen