-- 堆叠文件
-- 在游戏中的所有卡牌、异能的效果，都会先进入堆叠，在一定的延迟之后进行结算
-- 如果在这段时间内有玩家请求暂停堆叠结算，那么则会进入暂停状态
-- 所有进入堆叠的效果，将会以后发先至的顺序进行结算
-- 所有的触发式异能，将会以先发先触发的顺序进行结算
-- 在玩家点击回合结束之后，只有当堆叠清空后回合才会真正结束
-- 在这段时间内，敌方玩家依然可以将卡牌和效果进入堆叠
-- 

if CStack == nil then CStack = class({}) end

function CStack:constructor()
	print "-- Initing game stack --"

	self.vStack = {}
	self:StartProcTimer()
	
end

-- 将一个东西加入堆叠，可能是卡牌或者异能
function CStack:AddToStack(e)
	table.insert(self.vStack, e)
end

function CStack:StartProcTimer()
	self.vProcTimer = Timers:CreateTimer(0, function()
		
	end)
end

