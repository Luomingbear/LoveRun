-- 创建房间的场景
--[[
    同步的数据
{
	k = “” ， //命令 s:开始游戏，l:退出房间，j:跳跃，f:摔跤，i:加入房间,e:移动左脚，r:移动右脚
	p = 0 	//x位置
}
]]
local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')

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
    socket:on()
end

function CreateRoomScreen:update(dt) 
    self.t = self.t + dt
    if self.playerIn then
        time = math.floor( self.t )
        self.dot = time % 4
    end

    -- 打印 线程收到的数据
    info = love.thread.getChannel("server"):pop()
    if info ~= nil then
        print("----------------------------start-------------------------")
        print(string.format("key:%s,data:%s",info.key,info.data))
        print("------------------------------end-----------------------")

    end
end

function CreateRoomScreen:draw()
    -- 绘制背景
    love.graphics.clear(95,205,228)
    -- 绘制提示语 
    love.graphics.setColor(255,255,255,255)
    if self.playerIn then
        drawText("玩家已加入",120,50,14)
    else
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
    end
    -- 绘制灯
    if self.playerIn then
        -- 玩家已加入
        love.graphics.setColor(0,200,0)
        love.graphics.ellipse("fill",160,120,10,10)
    end
    love.graphics.setColor(80,163,0)
    love.graphics.setLineWidth(2)
    love.graphics.ellipse("line",160,120,11,11)
    -- 绘制开始按钮
    love.graphics.setColor(255,255,255)
    drawText("A：开始游戏",222,204)
end

function CreateRoomScreen:keypressed(key)
    if (key == keys.A) then
        socket:serverSend({k = "s"})
        self.screen:view("game/track",{online = self.playerIn,isServer = true})
    elseif key == keys.B then
        --back home
        self.screen:view('/', 'reset')
        socket:destroy()
    end
end

return CreateRoomScreen