local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')
local Camera = require('lib.hump.camera')
local Timer = require('lib.hump.timer')

--[[
    可以滚动的图片
]]
local function ScrollImg(y,img,level,play)
    local object = {
        x = 0, -- 默认x = 0
        y = y,
        w = 320, -- 图片的宽度，这里导出的图片都是320px
        img = img,
        level = level, -- 正整数，表示在第几图层，level越小，滚动速度越快，最小为1
        player = play, -- 角色玩家
        speed = 0.1, -- 移动速度
        oldPlayerX = 0 -- 上一次的玩家x坐标
    }

    function object:update(dt)
        if self.oldPlayerX==0 then
            self.oldPlayerX = self.player.x
        end
        difX = self.player.x- self.oldPlayerX
        self.x = self.x + difX * (self.level-1) * self.speed
        self.oldPlayerX = self.player.x
        if self.player.x - 160 - self.x > 320 then
            -- 说明这个图片已经完全离屏离，需要更新x坐标
            self.x = self.player.x - 160
        end
    end

    function object:draw()
        love.graphics.draw(self.img,self.x,self.y,0,1,1)
        x = self.player.x - 160 - self.x
        if self.player.x-160 > self.x then
            love.graphics.draw(self.img,self.x+320,self.y,0,1,1)
        else
            love.graphics.draw(self.img,self.x-320,self.y,0,1,1)
        end
    end
    return object
end



-- 背景 
local function Background(player)
    local object = {
        -- 玩家
        player = player, 
        -- 跑道
        scrollRunway = ScrollImg(136,love.graphics.newImage("assets/images/runway.png"),1,player),
        -- 围墙
        scrollWall = ScrollImg(94,love.graphics.newImage("assets/images/guzu.png"),2,player),
        -- 天空
        scrollSky = ScrollImg(0,love.graphics.newImage("assets/images/cloud.png"),4,player)
    }

    function object:reset()
        self.scrollRunway = ScrollImg(136,love.graphics.newImage("assets/images/runway.png"),1,player)
        -- 围墙
        self.scrollWall = ScrollImg(94,love.graphics.newImage("assets/images/guzu.png"),2,player)
        -- 天空
        self.scrollSky = ScrollImg(0,love.graphics.newImage("assets/images/cloud.png"),4,player)
    end

    function object:update(dt)
        self.scrollRunway:update(dt)
        self.scrollWall:update(dt)
        self.scrollSky:update(dt)
    end

    function object:draw()
        self.scrollRunway:draw()
        self.scrollWall:draw()
        self.scrollSky:draw()
    end
    return object
end
----------------------------运动员类----------------------
local function Athlete(x, y,img)
    
    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        mine = true, --true：表示这个是玩家本人，false表示这个是对手
        isServer = true, --是否是服务端
        width = 24,
        height = 32,
        yVelocity = 0, -- y方向速度
        jumpHeight = y-50, -- 跳跃高度
        speed = 200, -- 速度
        gravity = -400, -- 重力
        ground = y, -- 地面坐标
        time = 0, -- 时间
        status = "Idle", --状态
        stausTime = 0, -- 切换状态时的时间
        sprite = peachy.new("assets/images/runer2run.json", img, "Ready"),
        -- 每一个状态动画执行的时长
        statusDuration = {
            ready = 0,
            start = 0.3,
            left = 0.2,
            right = 0.2,
            jump = 0.8,
            fall = 1,
            idle = 0
        }
    }

    function object:rest(x,y,mine,isServer)
        self.x = x
        self.y = y
        self.mine = mine --true：表示这个是玩家本人，false表示这个是对手
        self.isServer = isServer --是否是服务端
        self.time = 0
        self.yVelocity = 0 -- y方向速度
        self.status = "Idle"
        self.statusTime = 0
        self.sprite:setTag("Idle")
    end

    function object:jump()
        --[[if self.time - self.statusTime < self.statusDuration.jump then
            return
        end]]--
        if self.status == "Fall" then
            return
        end
        self.statusTime = self.time
        --[[if self.status == "Left" then
            self.status = "Right"
            self.sprite:setTag("Right")
        elseif self.status == "Right" then
            self.status = "Left"    
            self.sprite:setTag("Left")
        else
            self.status = "Left"    
            self.sprite:setTag("Left")
        end]]--
        self.status = "Jump"
        self.sprite:setTag("Jump")

        if self.yVelocity == 0 then
            self.yVelocity = self.jumpHeight
        end

        -- 发生数据到另一台设备
        if self.mine then
            if self.isServer then
                socket:serverSend({key = "j",p = self.x})
            else
                socket:clientSend({key = "j",p = self.x})
            end
        end
    end

    function object:left()
        --[[if self.time - self.statusTime < self.statusDuration.left then
            return
        end]]--
        if self.status == "Fall" then
            return
        end
        self.status = "Left"
        self.sprite:setTag("Left")
        self.statusTime = self.time
        -- 发生数据到另一台设备
        if self.mine then
            if self.isServer then
                socket:serverSend({key = "e",p = self.x})
            else
                socket:clientSend({key = "e",p = self.x})
            end
        end
    end

    function object:right()
        --[[if self.time - self.statusTime < self.statusDuration.right then
            return
        end]]--
        if self.status == "Fall" then
            return
        end
        self.status = "Right"
        self.sprite:setTag("Right")
        self.statusTime = self.time

        -- 发生数据到另一台设备
        if self.mine then
            if self.isServer then
                socket:serverSend({key = "r",p = self.x})
            else
                socket:clientSend({key = "r",p = self.x})
            end
        end
    end

    function object:fall()
        if self.status == "Fall" then
            return
        end
        self.status = "Fall"
        self.sprite:setTag("Fall")
        self.statusTime = self.time

        -- 发生数据到另一台设备
        if self.mine then
            if self.isServer then
                socket:serverSend({key = "f",p = self.x})
            else
                socket:clientSend({key = "f",p = self.x})
            end
        end
    end
 
    function object:update(dt)
        self.time = self.time + dt
        -- 计算现在到切换动画中间间隔了多少时间
        difTime = self.time - self.statusTime

        -- 判断不同的
        if (self.status == "Left" and difTime > self.statusDuration.left) then
            self.sprite:setTag("Idle")
            self.status = "Idle"
        elseif (self.status == "Right" and difTime > self.statusDuration.right) then
            self.sprite:setTag("Idle")
            self.status = "Idle"
        elseif (self.status == "Jump" and difTime > self.statusDuration.jump) then
            self.sprite:setTag("Idle")
            self.status = "Idle"
        elseif (self.status == "Fall" and difTime > self.statusDuration.fall) then
            self.sprite:setTag("Idle")
            self.status = "Idle"
        end

        -- x轴
        if (self.status == "Left" and difTime < self.statusDuration.left) then
            self.x = self.x + self.speed * dt
        elseif (self.status == "Right" and difTime < self.statusDuration.right) then
            self.x = self.x + self.speed * dt
        elseif self.status == "Jump" and difTime < self.statusDuration.jump then
            self.x = self.x + 180 * dt
        elseif self.status == "Fall" and difTime < self.statusDuration.fall then
            self.x = self.x + 30 * dt
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
        self.sprite:draw(self.x, self.y)
    end

    return object
end

----------------------------- 栏杆 ---------------------------------
local function hurdle(x, y)

    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        width = 32,
        height = 42,
        ground = y,
        status = "Good",
        sprite = peachy.new("assets/images/hurdle.json", love.graphics.newImage("assets/images/hurdle.png"), "Good")
    }

    function object:rest()
        self.status = "Good"
        self.sprite:setTag("Good")
    end

    function object:broken()
        self.status = "Bad"
        self.sprite:setTag("Bad")
    end

    function object:activate(x, y)
        self.x = x
        self.y = y
    end

    function object:update(dt)
        self.sprite:update(dt)
    end

    function object:draw()
        love.graphics.setColor(255,255,255)
        self.sprite:draw(self.x - 15, self.y - 15)
    end

    return object
end

-- 倒数器
local function countDownTimer()
    local object = {
        x = 0,
        y = 100,
        time = 3
    }

    function object:count()
        self.time = self.time - 1
        if self.time == 0 then
            Timer.clear()
        end
    end

    function object:setUp()
        self.time = 3
        Timer.every(1, function() self:count() end)
    end

    function object:update(dt)
        Timer.update(dt)
    end

    function object:draw()
        if self.time > 0 then
            love.graphics.setColor(255,255,255)
            drawTextBig(tostring(self.time), self.x, self.y)
        else
            love.graphics.setColor(255,255,255)
            drawTextBig("Go", self.x, self.y)
        end
    end

    return object
end

--------------------------场景class--------------------
local TrackScreen = class {}


-- 矩形碰撞
function testRect(athlete, hurdle)
    if hurdle.status == "Bad" then
        return false
    else
        return athlete.x<hurdle.x+hurdle.width and athlete.y<hurdle.y+hurdle.height and athlete.x+athlete.width>hurdle.x and athlete.y+athlete.height>hurdle.y
    end
end

function TrackScreen:init(ScreenManager)
    self.screen = ScreenManager
    self.camera = Camera(0, 175)
    self.isServer = true -- 当前玩家是否是服务端
    self.playerA = Athlete(0, 175,love.graphics.newImage("assets/images/runer1run.png"))
    self.timer = countDownTimer()
    self.background = Background(self.playerA)
    self.footLeft = peachy.new("assets/images/footleft.json", love.graphics.newImage("assets/images/footleft.png"), "Normal")
    self.footRight = peachy.new("assets/images/footright.json", love.graphics.newImage("assets/images/footright.png"), "Normal")
    self.footJump = peachy.new("assets/images/jump.json", love.graphics.newImage("assets/images/jump.png"), "Normal")
    self.hurdleTable1 = {}
    self.hurdleTable2 = {}
    self.robot = require("lib.robot")
    for i=1,10 do
        table.insert(self.hurdleTable1, i, hurdle(380 * i, 185))
        table.insert(self.hurdleTable2, i, hurdle(380 * i, 155))
    end
end

function TrackScreen:activate(data)
    self.isServer = data.isServer
    if  (data == nil or data.online == false ) then
        if self.playerB == nil then
            self.playerB = Athlete(0, 140,love.graphics.newImage("assets/images/runer2run.png"))
        end
        self.robot:init(true)
    else
        self.robot:init(false)
    end
    self.playerA:rest(0,175,true,data.isServer)
    self.playerB:rest(0,140,false,data.isServer)
    for i=1,10 do
        self.hurdleTable1[i]:rest()
        self.hurdleTable2[i]:rest()
    end
    self.background:reset()
    self.timer:setUp()
end

function TrackScreen:update(dt)
    socket:update(dt)
    self.robot:update(dt)
    self.timer:update(dt)
    self.background:update(dt)
    -- 更新玩家的状态
    self.playerA:update(dt)
    if self.playerB ~=nil then
        self.playerB:update(dt)
    end
    -- 更新按钮
    self.footLeft:update(dt)
    self.footRight:update(dt)
    self.footJump:update(dt)
    -- 更新栏杆
    for i=1,10 do
        if (self.hurdleTable1[i].status == "Good" and testRect(self.playerA, self.hurdleTable1[i]) )then
            self.hurdleTable1[i]:broken()
            self.playerA:fall()
        end
        if self.playerB ~=nil then
            if (self.hurdleTable2[i].status == "Good" and testRect(self.playerB, self.hurdleTable2[i]) )then
                self.hurdleTable2[i]:broken()
                self.playerB:fall()
            end
        end
    end

    -- 移动相机
    self.camera:lookAt(self.playerA.x, 120)
    -- 接收网络数据
    info = nil
    if self.isServer then
        info = love.thread.getChannel("server"):pop()
    else
        info = love.thread.getChannel("client"):pop()
    end
    if info ~= nil then
        if info.key == "j" then
            -- 跳跃
            self.playerB:jump()
        elseif info.key == "f" then
            -- 摔跤
            self.playerB:fall()
        elseif info.key == "e" then
            -- 移动左脚
            self.playerB:left()
        elseif info.key =="r" then
            -- 移动右脚
            self.playerB:right()
        end
    end
    -- 检查是否到达终点
    if self.playerA.x >= 380 * 11 then
        info = {}
        info[0] = true
        info[1] = self.playerA.time
        self.screen:view("game/finish", info)
    end
    if self.playerB.x >= 380 * 11 then
        info = {}
        info[0] = false
        info[1] = self.playerB.time
        self.screen:view("game/finish", info)
    end
end

function TrackScreen:draw()
	love.graphics.clear(31,28,24)
	love.graphics.setColor(255,255,255)
    self.camera:attach()
    -- 绘制场景
    self.background:draw()
    -- 绘制栏杆
    for i=1,10 do
        self.hurdleTable1[i]:draw()
        self.hurdleTable2[i]:draw()
    end

    -- 终点线
    love.graphics.setColor(255,255,255)
    love.graphics.line(380 * 11 + 30, 210, 380 * 11 + 15, 155)
    
    -- 绘制玩家
    self.playerA:draw()
    if self.playerB ~=nil then
        self.playerB:draw()
    end

    -- 绘制按钮
    self.footLeft:draw(self.playerA.x - 160 + 17,216)
    self.footRight:draw(self.playerA.x - 160 +47,216)
    self.footJump:draw(self.playerA.x - 160 +274,216)

    self.timer:draw()

    self.camera:detach()
end

function TrackScreen:keypressed(key)
    if key == keys.LK5 and self.timer.time == 0 then
        self.footLeft:setTag("Tap")
        if self.lastPressed ~= keys.LK5 then
            self.lastPressed = key
            self.playerA:right()
        else
            self.playerA:fall()
        end
    elseif key == keys.LK1 and self.timer.time == 0 then
        self.footRight:setTag("Tap")
        if self.lastPressed ~= keys.LK1 then
            self.lastPressed = key
            self.playerA:left()
        else
            self.playerA:fall()
        end
    elseif key == keys.A then
        self.footJump:setTag("Tap")
        if self.lastPressed ~= nil then
            self.lastPressed = key
            self.playerA:jump()
        end
    elseif key == keys.B then
        self.screen:view('/', 'reset')
    end
end

function TrackScreen:keyreleased(key)
    if key == keys.LK5 then
        self.footLeft:setTag("Normal")
    elseif key == keys.LK1 then
        self.footRight:setTag("Normal")
    elseif key == keys.A then
        self.footJump:setTag("Normal")
    end
end

return TrackScreen