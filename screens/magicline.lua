-- 屏幕中有一个两条长线，接触的地方会有两条极光激光碰撞的火花，手按a会增长长线，长线到达对方的分割线就赢了。
local class = require('lib.hump.class')
local keys = require('lib.keys')

local MagicLineScreen =class{} 

a = 1
b = 1
x = 0
y = 0
function MagicLineScreen:init(ScreenManager)
    self.screen = ScreenManager 
end

function MagicLineScreen:activate()
end
function MagicLineScreen:update(dt)
    scale = a/(a+b)
    x = 260*scale+30
    y = 250*scale
end

function MagicLineScreen:draw()
	love.graphics.clear(145,223,126)
    love.graphics.setColor(148,134,168)
    love.graphics.setLineWidth(10)
    love.graphics.line(30,-10,x,y)
    love.graphics.setColor(142,223,239)
    love.graphics.line(x,y,290,250)
    love.graphics.print(a)
end

function MagicLineScreen:keypressed(key)
    if key ==keys.A then
        a= a+1
    elseif key ==keys.B then
        b= b+1
    end
end


return MagicLineScreen