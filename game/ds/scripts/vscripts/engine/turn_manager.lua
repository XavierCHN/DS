TurnManager = class({})

function TurnManager:Init()
	self.turnCount = 0
end

function TurnManager:SelectFirstActivePlayer()
	-- 先手玩家，后手玩家：不随回合改变
	-- 主动玩家，被动玩家：每回合改变一次
	if RollPercentage(50) then
		self.fp, self.nfp = GameRules.AllPlayers[1], GameRules.AllPlayers[2] 
	else
		self.fp, self.nfp = GameRules.AllPlayers[2], GameRules.AllPlayers[1]
	end
	self.ActivePlayer, self.NoneActivePlayer = self.fp, self.nfp -- 主动玩家，被动玩家
end

function TurnManager:ShuffleAndDrawInitialCards()
	-- 初始化玩家的卡组，并抽取初始手牌
	for _, hero in pairs(GameRules.AllHeroes) do
		local player_id = hero:GetPlayerID()
		local card_list = PlayerResource:GetPlayerCardList(player_id)
		local deck = Deck(card_list, hero)
		deck:Shuffle()
		hero:SetDeck(deck)
		hero:DrawCard(NUM_INIT_CARD_COUNT)
	end
end

function TurnManager:Run()

	-- 回合结构不会因为任何原因而更改，必定使用这样的循环，能更改的也就只有回合的持续时间了

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

	-- 循环两个玩家的手牌，如果需要高亮则高亮之
	Timers:CreateTimer(function()
		if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			for _, hero in pairs(GameRules.AllHeroes) do
				hero:RefreshHand_HL()
			end
		end
		return 0.05
	end)

end

function TurnManager:ToggleActivePlayer()
	-- 交换主动玩家和被动玩家
	self.ActivePlayer, self.NoneActivePlayer = self.NoneActivePlayer, self.ActivePlayer

	CustomGameEventManager:Send_ServerToAllClients("ds_active_player_changed",{
		ap = self.ActivePlayer:GetPlayerID(),
		nap = self.NoneActivePlayer:GetPlayerID(),
	})
end

function TurnManager:GetActivePlayer()
	return self.ActivePlayer
end

function TurnManager:GetNoneActivePlayer()
	return self.NoneActivePlayer
end
