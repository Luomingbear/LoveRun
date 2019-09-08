-- 创建房间的场景
local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')

local CreateRoomScreen = class{}

function CreateRoomScreen:init(ScreenManager)
    self.screen = ScreenManager 
    self.pwd=""
end

function CreateRoomScreen:activate()
    -- 先断开所有的链接
    imgRunner2 = love.graphics.newImage("assets/images/runer2run.png")
    runner2Left = peachy.new("assets/images/runer2run.json",imgRunner2,"Left")

end

function CreateRoomScreen:update(dt)
    runner2Left:update(dt) 
end

function CreateRoomScreen:draw()
    -- 绘制背景
    love.graphics.clear(100,100,129)
    -- 绘制提示语
    love.graphics.setColor(50,50,100)
    drawText("请选择↑、↓、←、→作为密码并按下A确定",15,10,16)
    -- 绘制密码
    love.graphics.setColor(40,40,40)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("fill",140,100,40,40,8,8)
    love.graphics.setColor(80,80,80)
    love.graphics.rectangle("line",140,100,40,40,8,8)
    love.graphics.setColor(181,74,92)
    drawText(self.pwd,148,96,46)
    -- 绘制开始按钮
    if self.pwd ~= "" then
        love.graphics.setColor(148,134,168)
        drawText("Start",260,210,16)
    end
    -- 播放动画
    runner2Left:draw(100,100)
end

function CreateRoomScreen:keypressed(key)
    if key == keys.DPad_up then
        self.pwd = "↑"
    elseif key == keys.DPad_down then 
        self.pwd = "↓"
    elseif key == keys.DPad_right then
        self.pwd = "→"
    elseif key == keys.DPad_left then
        self.pwd = "←"
    elseif key == keys.B then
        --back home
        self.screen:view('/', 'reset')
    end
end

return CreateRoomScreen