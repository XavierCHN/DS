TurnManager = class({})

function TurnManager:Init()
	self.turnCount = 0
end

function TurnManager:Run()

	-- 回合结构不会因为任何原因而更改

	-- 先手玩家，跳过第一次抽牌，可以出属性牌
	-- 第一次回合开始
	self.fp:SetHasUsedAttributeCardThisRound(false)

	-- 后手玩家等待对方回合时间结束后可以出属性牌+抽牌
	-- 第二次回合开始
	Timers:CreateTimer(DS_TURN_TIME, function()
		self:ToggleActivePlayer()
		self.nfp:DrawCard(1) -- 抽一张牌
		self.nfp:FillManaPool() -- 回满魔法池
		self.nfp:SetHasUsedAttributeCardThisRound(false) -- 可以出属性牌
		return DS_TURN_TIME * 2
	end)


	-- 在第三个回合开始的时候，开始进入正常的回合循环
	Timers:CreateTimer(DS_TURN_TIME * 2, function()
		self:ToggleActivePlayer()
		self.fp:DrawCard(1) -- 抽一张牌
		self.fp:FillManaPool() -- 回满魔法池
		self.fp:SetHasUsedAttributeCardThisRound(false) -- 可以出属性牌
		return DS_TURN_TIME * 2
	end)

end

function TurnManager:ToggleActivePlayer()
	-- 交换主动玩家和被动玩家
	self.ActivePlayer, self.NoneActivePlayer = self.NoneActivePlayer, self.ActivePlayer

	CustomGameEventManager:Send_ServerToAllClients("ds_active_player_changed",{
		ap = self.ActivePlayer:GetPlayerID(),
		nap = self:NoneActivePlayer:GetPlayerID(),
	})
end

function TurnManager:GetActivePlayer()
	return self.ActivePlayer
end

function TurnManager:GetNoneActivePlayer()
	return self.NoneActivePlayer
end

-- 设置双方玩家先后手， p1为先手玩家，p2为后手玩家
function TurnManager:SetPlayerPriority(p1, p2)
	self.fp = p1
	self.nfp = p2

	self.ActivePlayer = p1
	self.NoneActivePlayer = p2
end