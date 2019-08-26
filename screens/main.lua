-- 游戏的首页 选择加入房间还是创建房间，屏幕上有两个选择框

local class = require('lib.hump.class')
local keys = require('lib.keys') 

local MainScreen = class {}

-- 首页的场景
function MainScreen:init(ScreenManager)
	self.screen = ScreenManager 
	self.select = 0 -- 0表示创建，1表示加入
	self.scale = 1
	self.t = 0
end


function MainScreen:activate()
	love.graphics.clear(1,1,1) 
end

function MainScreen:update(dt)
	self.t = self.t+dt
	self.scale = 1+ math.cos(self.t*3)*0.05
end
 

function MainScreen:draw()
	love.graphics.clear(100,100,129)
	image1 = love.graphics.newImage("assets/images/createroom.png")
	image2 = love.graphics.newImage("assets/images/joinroom.png")
	if self.select==0 then
		love.graphics.draw(image1,10,10,0,self.scale,self.scale)
		love.graphics.draw(image2,10,100,0,0.9,0.9)
	elseif self.select==1 then
		love.graphics.draw(image1,10,10,0,0.9,0.9)
		love.graphics.draw(image2,10,100,0,self.scale,self.scale)
	end
end

function MainScreen:keypressed(key)
	if key == keys.DPad_down then
		self.select = 1
	elseif key == keys.DPad_up then
		self.select = 0
	elseif key == keys.A then
		if self.select == 0 then
			-- 进入加入房间的场景
			self.screen:view("room/create") 
		elseif self.select == 1 then
			self.screen:view("room/join")
		end
	end
end

return MainScreen