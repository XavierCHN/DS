--
TIME_WAIT_INTERVAL = 3

if CStack == nil then CStack = class({}) end

if GameRules.CStack == nil then
    GameRules.CStack = CStack()
end

function CStack:constructor()
    self.vProcTimer = Timers:CreateTimer(function()
        local t = GameRules:GetGameTime()
        if t >= self.flProcTime then
            self:ProcNext()
        end

        return 0.03
    end)
end

-- 将某个函数加入到堆叠，这个函数将会在堆叠结算的时候再执行
-- swapPriority: 是否让出优先权，如果让出优先权
--               则需要发送指令，将优先权给对方
function CStack:AddToStack(func, swapPriority)

    if self.vStack == nil then self.vStack = {} end

    table.insert(self.vStack, func)

    self.flProcTime = GameRules:GetGameTime() + TIME_WAIT_INTERVAL

    if swapPriority then
        print " TODO : tell how to swap priority!"
        -- GameRules.CGameInfo.vActivePlayer:GivePriority()
    end
end

-- 执行下一个堆叠，把最顶上一个元素pop出来，然后执行
function CStack:ProcNext()
    if #self.vStack > 0 then
        local next = table.remove(self.vStack, #self.vStack)
        next()
    end
end