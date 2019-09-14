local class = require('lib.hump.class')
local keys = require('lib.keys')
local peachy  = require('lib.peachy')
local Camera = require('lib.hump.camera')


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
        speed = 0.05, -- 移动速度
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
        scrollWall = ScrollImg(94,love.graphics.newImage("assets/images/wall2.png"),2,player),
        -- 天空
        scrollSky = ScrollImg(0,love.graphics.newImage("assets/images/cloud.png"),4,player),
    }

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
        width = 40,
        height = 30,
        xVelocity = 0, -- x方向速度
        yVelocity = 0, -- y方向速度
        jumpHeight = -130, -- 跳跃高度
        force = 30, -- 前进动力
        maxSpeed = 200, -- 最大速度
        gravity = -240, -- 重力
        ground = y, -- 地面坐标
        t = 0, -- 时间
        fallDuration = 0,
        status = '', --状态
        stausTime = 0, -- 切换状态时的时间
        sprite = peachy.new("assets/images/runer2run.json", img, "Ready"),
        -- 每一个状态动画执行的时长
        statusDuration = {
            ready = 0,
            start = 0.3,
            left = 0.2,
            right = 0.2,
            fall = 1,
            idle = 0
        }
    }

    function object:rest(x,y)
        self.x = x
        self.y = y
        self.time = 0
        self.xVelocity = 0 -- x方向速度
        self.yVelocity = 0 -- y方向速度
        self.jumpHeight = -130 -- 跳跃高度
        self.force = 2 -- 前进动力
        self.maxSpeed = 10 -- 最大速度
        self.gravity = -240 -- 重力
        self.ground = y -- 地面坐标
        self.status = ''
        self.statusTime = 0
        self.sprite:setTag("Idle")
    end

    function object:jump()
        if self.status == keys.DPad_left then
            self.status = "Right"
            self.sprite:setTag("Right")
        elseif self.status == keys.DPad_right then
            self.status = "Left"    
            self.sprite:setTag("Left")
        end

        if self.yVelocity == 0 then
            self.yVelocity = self.jumpHeight
        end
        self.statusTime = self.time
    end

    function object:left()
        self.status = "Left"
        self.sprite:setTag("Left")
        self.sprite:play()
        self.xVelocity = self.force
        self.statusTime = self.time
    end

    function object:right()
        self.status = "Right"
        self.sprite:setTag("Right")
        self.sprite:play()
        self.xVelocity = self.force
        self.statusTime = self.time
    end

    function object:fall()
        self.status = "Fall"
        self.sprite:setTag("Fall")
        self.sprite:play()
        self.stausTime = self.time
    end
 
    function object:update(dt)
        self.time = self.time + dt
        -- 计算现在到切换动画中间间隔了多少时间
        difTime = self.time - self.statusTime

        -- 判断不同的
        if (self.status == "Start" and difTime > self.statusDuration.start ) then
            self.sprite:stop()
        elseif (self.status == "Left" and difTime > self.statusDuration.left ) then
            self.sprite:stop()
            self.xVelocity = 0
        elseif (self.status == "Right" and difTime > self.statusDuration.right ) then
            self.sprite:stop()
            self.xVelocity = 0
        elseif (self.status == "Fall" and difTime > self.statusDuration.fall ) then
            self.sprite:stop()
            self.xVelocity = 0
        end

        -- x轴
        if self.xVelocity ~= 0 then
            self.xVelocity = self.xVelocity + self.force
        end
        self.x = self.x + self.xVelocity * 10 * dt

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
        love.graphics.setColor(148,134,168)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height) -- 碰撞盒
        self.sprite:draw(self.x, self.y)
    end

    return object
end

----------------------------- 栏杆 ---------------------------------
local function hurdle(x, y)

    local object = {
        x = x, -- x坐标
        y = y, -- y坐标
        width = 5,
        height = 25,
        ground = y,
        status = "Good",
        sprite = peachy.new("assets/images/hurdle.json", love.graphics.newImage("assets/images/hurdle.png"), "Good")
    }

    function object:broken()
        status = "Bad"
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


--------------------------场景class--------------------
local TrackScreen = class {}


-- 矩形碰撞
function testRect(athlete, hurdle)
    return athlete.x<hurdle.x+hurdle.width and athlete.y<hurdle.y+hurdle.height and athlete.x+athlete.width>hurdle.x and athlete.y+athlete.height>hurdle.y
end

function TrackScreen:init(ScreenManager)
    self.screen = ScreenManager
    self.camera = Camera(0, 180)
    self.playerA = Athlete(0, 180,love.graphics.newImage("assets/images/runer1run.png"))
    self.playerB = Athlete(0, 140,love.graphics.newImage("assets/images/runer2run.png"))
    self.background = Background(self.playerA)
    self.footLeft = peachy.new("assets/images/footleft.json", love.graphics.newImage("assets/images/footleft.png"), "Normal")
    self.footRight = peachy.new("assets/images/footright.json", love.graphics.newImage("assets/images/footright.png"), "Normal")
    self.footJump = peachy.new("assets/images/jump.json", love.graphics.newImage("assets/images/jump.png"), "Normal")
    self.hurdleTable = {}
    for i=1,10 do
        table.insert(self.hurdleTable, i, hurdle(500 * i, 185))
    end
end

function TrackScreen:activate()
    self.playerA:rest(0,180)
    self.playerB:rest(0,140)
end

function TrackScreen:update(dt)
    self.background:update(dt)
    -- 更新玩家的状态
    self.playerA:update(dt)
    self.playerB:update(dt)
    -- 更新按钮
    self.footLeft:update(dt)
    self.footRight:update(dt)
    self.footJump:update(dt)

    -- 移动相机
    self.camera:lookAt(self.playerA.x, 120)
end

function TrackScreen:draw()
	love.graphics.clear(31,28,24)
	love.graphics.setColor(255,255,255)
    self.camera:attach()
    -- 绘制场景
    self.background:draw()
    --

    self.playerA:draw()
    self.playerB:draw()

    -- 绘制栏杆
    for i=1,10 do
        self.hurdleTable[i]:draw()
        if testRect(self.playerA, self.hurdleTable[i]) then
            self.hurdleTable[i]:broken()
        end
    end
    -- 绘制按钮
    self.footLeft:draw(self.playerA.x - 160 + 17,216)
    self.footRight:draw(self.playerA.x - 160 +47,216)
    self.footJump:draw(self.playerA.x - 160 +274,216)

    self.camera:detach()
end

function TrackScreen:keypressed(key)
    if key == keys.DPad_right then
        if self.lastPressed ~= keys.DPad_right then
            self.lastPressed = key
            self.playerA:right()
        else
            self.playerA:fall()
        end
    end
    if key == keys.DPad_left then
        if self.lastPressed ~= keys.DPad_left then
            self.lastPressed = key
            self.playerA:left()
        else
            self.playerA:fall()
        end
    end
    if key == keys.A then
        if self.lastPressed ~= nil then
            self.lastPressed = key
            self.playerA:jump()
        end
    end
    if key == keys.B then
        self.screen:view('/', 'reset')
    end
end

return TrackScreen