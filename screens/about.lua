-- 关于页面

local class = require('lib.hump.class')
local keys = require('lib.keys')

local AboutScreen = class{}

function AboutScreen:init(ScreenManager)
   self.screen = ScreenManager
end

function AboutScreen:activate(arg)
    
end

function AboutScreen:update(dt)
	
end

function AboutScreen:draw()
    love.graphics.clear(31,28,24)
    
    love.graphics.setColor(180,170,156)
    drawText("游戏操作：",25,27,14)
    drawText("L键移动左脚，R键移动右脚，A跳跃",25,59,14)
    drawText("连续移动相同的脚或者撞到跨栏会摔跤",25,91,14)
    drawText("用最短的时间冲线吧！",25,123,14)
    love.graphics.setColor(255,255,255)
    drawText("A：知道了",223,176,14)
end

function AboutScreen:keypressed(key)
    if key == keys.A then
        self.screen:view("/")
    end
end


return AboutScreen
