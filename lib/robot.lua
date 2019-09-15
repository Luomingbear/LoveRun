-- 机器人行为生成的类 
local Robot = {}

function Robot:init()
    self.t = 0
    self.statusTime = 0 --切换状态时的时间
    self.status = "Ready" -- 状态
    self.code = 0 -- 随机码
    -- 每一个状态动画执行的时长
    self.statusDuration = {
        ready = 0,
        start = 0.3,
        left = 0.2,
        right = 0.2,
        jump = 0.2,
        fall = 1,
        idle = 0
    }
end

-- 发送通知
function Robot:send(code)
    if code ==0 then 
        self.status = "Left"
        love.thread.getChannel("client"):push({key = "e"})
    elseif code == 1 then
        self.status = "Right"
        love.thread.getChannel("client"):push({key = "r"})
    elseif code == 2 then
        self.status = "Jump"
        love.thread.getChannel("client"):push({key = "j"})
    elseif code == 3 then
        self.status = "Fall"
        love.thread.getChannel("client"):push({key = "f"})
    end
end

function Robot:update(dt)
    self.t = self.t + dt
    local dif = self.t - self.statusTime
    local ran = math.random(1,10)
    if ( self.status == "Left" and dif >self.statusDuration.left )then

    elseif ( self.status == "Left" and dif >self.statusDuration.left )then

    elseif ( self.status == "Left" and dif >self.statusDuration.left )then

    end
end

return Robot