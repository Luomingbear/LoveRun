-- 机器人行为生成的类 
Robot = {
    open = open ,-- 是否打开机器人
    t = 0,
    statusTime = 0 ,--切换状态时的时间
    status = "Ready", -- 状态
    code = "" ,-- 随机码
    -- 每一个状态动画执行的时长
    statusDuration = {
        ready = 0,
        start = 0.3,
        left = 0.2,
        right = 0.2,
        jump = 0.2,
        fall = 1,
        idle = 0
    }
}

function Robot:init(open)
    self.open = open -- 是否打开机器人
    self.t = 0
    self.statusTime = 0 --切换状态时的时间
    self.status = "Ready" -- 状态
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


function Robot:update(dt)
    if self.open == false then
        return
    end

    self.t = self.t + dt
    dif = self.t - self.statusTime
    if ( self.status == "Ready" and dif > self.statusDuration.ready )then
        self.status = "Left"
    elseif ( self.status == "Left" and dif > self.statusDuration.left )then
        ran = math.random(1,7)
        print(ran)
        if ran > 2 then
            self.status = "Right"
        else
            self.status = "Left"
        end
    elseif ( self.status == "Right" and dif >self.statusDuration.right )then
        ran = math.random(1,7)
        print(ran)

        if ran > 2 then
            self.status = "Left"
        else
            self.status = "Right"
        end
    elseif ( self.status == "Jump" and dif >self.statusDuration.jump )then
        self.status = "Left"
    elseif ( self.status == "Fall" and dif >self.statusDuration.fall )then
        self.status = "Left"
    else
        return
    end
    print(self.status)

    -- 发送行为
    if self.status == "Left" then 
        love.thread.getChannel("server"):push({key = "e"})
    elseif self.status == "Right" then
        love.thread.getChannel("server"):push({key = "r"})
    elseif self.status ==  "Jump" then
        love.thread.getChannel("server"):push({key = "j"})
    elseif self.status == "Fall" then
        love.thread.getChannel("server"):push({key = "f"})
    end
    self.statusTime = self.t
end

return Robot