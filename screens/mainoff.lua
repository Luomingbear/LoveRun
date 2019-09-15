-- 单机版游戏的首页 选择加入房间还是创建房间，屏幕上有两个选择框

local class = require('lib.hump.class')
local keys = require('lib.keys')


local MainScreen = class {}

-- 首页的场景
function MainScreen:init(ScreenManager)
	logoImg = love.graphics.newImage("assets/images/logo.png")
	arrowImg = love.graphics.newImage("assets/images/arrow.png")
	self.screen = ScreenManager
end

function MainScreen:activate()
	self.select = 0 -- 0表示创建，1表示加入,2表示退出
end

function MainScreen:update(dt)
	socket:update(dt)
end

function MainScreen:draw()
	love.graphics.clear(31,28,24)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(logoImg,26,21,0,1,1)
	-- 绘制文本
	love.graphics.setColor(255,255,255)
	drawText("开始游戏",128,131,16)
	drawText("退出游戏",128,171,16)
	love.graphics.setColor(255,255,255)
    if self.select==0 then
		love.graphics.draw(arrowImg,105,131,0,1,1)
    elseif self.select==1 then
		love.graphics.draw(arrowImg,105,171,0,1,1)
	end
end

function MainScreen:keypressed(key)
	if key == keys.DPad_down then
		self.select = self.select + 1
		if self.select >1 then
			self.select = 1
		end
	elseif key == keys.DPad_up then
		self.select = self.select - 1
		if self.select < 0 then
			self.select = 0
		end
	elseif key == keys.A then
		if self.select == 0 then
			self.screen:view("game/track",{isServer = true,online = false}) 
		elseif self.select == 1 then
			love.event.quit(0)
		end
	end
end

return MainScreen