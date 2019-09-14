-- 创建房间的场景
-- todo 创建服务器
local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')

function rect(text,x,y)
    local object = {
        text = text,
        x = x,
        y = y
    }

    function object:update(dt)
    end


    function object:draw()
        love.graphics.setColor(40,40,40)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("fill",140,100,40,40,8,8)
        love.graphics.setColor(80,80,80)
        love.graphics.rectangle("line",140,100,40,40,8,8)
        love.graphics.setColor(181,74,92)
        drawText(self.text,self.x,self.y,14)
    end

    return object
end


local CreateRoomScreen = class{}

function CreateRoomScreen:init(ScreenManager)
    self.screen = ScreenManager  
    self.t = 0
    self.dot = 0
    self.playerIn = false -- 是否有玩家加入
end

function CreateRoomScreen:activate()
    self.t = 0
    self.dot = 0
    self.playerIn = false
    -- todo 先断开所有的链接 
    
end

function CreateRoomScreen:update(dt) 
    self.t = self.t + dt
    time = math.floor( self.t )
    self.dot = time % 4
end

function CreateRoomScreen:draw()
    -- 绘制背景
	love.graphics.clear(95,205,228)
    -- 绘制提示语
    love.graphics.setColor(255,255,255,255)
    if self.dot ==0  then
        drawText("正在等待玩家加入",93,50,14)
        self.oldt =  self.t 
    elseif self.dot == 1  then
        drawText("正在等待玩家加入.",93,50,14)
    elseif self.dot == 2  then
        drawText("正在等待玩家加入. . ",93,50,14)
    elseif self.dot == 3  then
        drawText("正在等待玩家加入. . .",93,50,14)
    end
    -- 绘制灯
    if self.playerIn then
        -- 玩家已加入
        love.graphics.setColor(195,64,80)
        love.graphics.ellipse("fill",160,120,10,10)
    else
        -- 玩家未加入
        love.graphics.setColor(120,120,116)
        love.graphics.ellipse("fill",160,120,10,10)
    end
    love.graphics.setColor(60,21,29)
    love.graphics.setLineWidth(2)
    love.graphics.ellipse("line",160,120,11,11)
    -- 绘制开始按钮
    love.graphics.setColor(255,255,255)
    drawText("A：开始游戏",222,204)
end

function CreateRoomScreen:keypressed(key)
    if key == keys.A then
        self.screen:view("game/track",self.playerIn)
    elseif key == keys.B then
        --back home
        self.screen:view('/', 'reset')
    end
end

return CreateRoomScreen