-- 游戏的结果页面,路由过来的时候传递一个table格式如下
--[[
    info = {}
    info[0] = false
    info[1] = 33.44
]]

local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')

local FinishScreen = class{}

function FinishScreen:init(ScreenManager)
    self.screen = ScreenManager
    self.winImg = love.graphics.newImage("assets/images/cup_win.png")
    -- 烟花的粒子系统
    local psImg = love.graphics.newImage("assets/images/single_pixel.png")
    self.pSystem = love.graphics.newParticleSystem(psImg,64)
    self.pSystem:setLinearAcceleration(-1,20,1,30)
    self.pSystem:setColors(255,0,255,255,0,255,255,255,255,0,0,255)
    self.pSystem:setEmissionArea("normal",32,32)
    self.pSystem:setSizes(2, 4, 0)
    self.t = 0
end

function FinishScreen:activate(arg)
    self.info = arg
    self.t = 0
    if self.info[0] then
        self.pSystem:setParticleLifetime(4)
        self.pSystem:setEmissionRate(16)
        self.pSystem:start()
    end
end

function FinishScreen:update(dt)
	socket:update(dt)
    if self.info[0] then
        self.pSystem:update(dt)
    end

    self.t = self.t + dt
    if self.t >1.5 then
        self.pSystem:stop()
    end
    
end

function FinishScreen:draw()
	love.graphics.clear(31,28,24)
    love.graphics.setColor(255,255,255)

    if self.info[0] then
        -- 胜利
        love.graphics.draw(self.winImg,144,45,0,1,1)
        love.graphics.setColor(217,160,112)
        drawText("胜利",146,84,14)
        --绘制烟花
        love.graphics.setColor(255,255,255)
        love.graphics.draw(self.pSystem,160,0)
    else
        -- 失败
        love.graphics.setColor(203,219,252)
        drawText("失败",146,84,14)
    end

    --绘制时间
    love.graphics.setColor(255,255,255)
    drawText("总计耗时：",104,120,14)
    drawText(string.format("%2ss",self.info[1]),176,120,14)
    --绘制右下角的按钮
    -- love.graphics.setColor(180,170,156)
    drawText("A：知道了",223,176,14)
end

function FinishScreen:keypressed(key)
    if key == keys.A then
        -- 再来一次
        self.screen:view("/")
    end
end


return FinishScreen
