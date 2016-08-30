TurnManager = class({})

function TurnManager:Start()
	self.turnCount = 0

	self:SelectFirstActivePlayer()
	self:ShufflePlayerDeckAndDrawInitialCards()
end

function TurnManager:SelectFirstActivePlayer()
	-- 先手玩家，后手玩家：不随回合改变
	-- 主动玩家，被动玩家：每回合改变一次
	if RollPercentage(50) then
		self.fp, self.nfp = GameRules.AllHeroes[1], GameRules.AllHeroes[2] 
	else
		self.fp, self.nfp = GameRules.AllHeroes[2], GameRules.AllHeroes[1]
	end
	self.ActivePlayer, self.NoneActivePlayer = self.fp, self.nfp -- 主动玩家，被动玩家
end

-- 初始化玩家的卡组，并抽取初始手牌
function TurnManager:ShufflePlayerDeckAndDrawInitialCards()
	self.fp:GetDeck():Shuffle()
	self.fp:DrawCard(NUM_INIT_CARD_COUNT)
	self.nfp:GetDeck():Shuffle()
	self.nfp:DrawCard(NUM_INIT_CARD_COUNT + 1)
end

function TurnManager:SetPhase(newPhase)
	self.phase = newPhase

	if newPhase == TURN_PHASE_STRATEGY then
		self.phase_duration = DS_ROUND_TIME_STRATEGY
		self.phase_start_time = GameRules:GetGameTime()

		for k, minion in pairs(GameRules.AllMinions) do
			if IsValidEntity(minion) and minion:IsAlive() then
				minion:RemoveModifierByName("modifier_summon_disorder") -- 在回合开始阶段去掉所有的召唤失调状态
			else
				GameRules.AllMinions[k] = nil
			end
		end

	elseif newPhase == TURN_PHASE_BATTLE then
		self.phase_duration = DS_ROUND_TIME_BATTLE
		self.phase_start_time = GameRules:GetGameTime()

		for k, minion in pairs(GameRules.AllMinions) do
			if IsValidEntity(minion) and minion:IsAlive() then
				if minion:HasModifier("modifier_summon_disorder") then
					minion:RemoveModifierByName("modifier_minion_disable_attack")
				else
					minion:RemoveModifierByName("modifier_minion_disable_attack")
					minion:RemoveModifierByName("modifier_minion_rooted")
				end
			else
				GameRules.AllMinions[k] = nil
			end
		end

	elseif newPhase == TURN_PHASE_POST_BATTLE then
		self.phase_duration = DS_ROUND_TIME_POST_BATTLE
		self.phase_start_time = GameRules:GetGameTime()

		for k, minion in pairs(GameRules.AllMinions) do
			if IsValidEntity(minion) and minion:IsAlive() then
				minion:AddNewModifier(minion, nil, "modifier_minion_disable_attack", {})
				minion:AddNewModifier(minion, nil, "modifier_minion_rooted", {})
			else
				GameRules.AllMinions[k] = nil
			end
		end
	end
end

function TurnManager:GetPhase()
	return self.phase
end

function TurnManager:Run()

	self.game_started = true

	-- 启动第一个回合
	self:StartNewRound()

	-- 启动主循环计时器
	Timers:CreateTimer(function()

		local t = GameRules:GetGameTime()
		if t - self.phase_start_time > self.phase_duration then
			if self.phase == TURN_PHASE_POST_BATTLE then
				-- 切换主动玩家并开始新回合
				self:ToggleActivePlayer()
				self:StartNewRound()
			end
			if self.phase == TURN_PHASE_BATTLE then
				self:SetPhase(TURN_PHASE_POST_BATTLE)
			end
			if self.phase == TURN_PHASE_STRATEGY then
				self:SetPhase(TURN_PHASE_BATTLE)
			end
		end
		return 0.03
	end)

	-- 启动倒计时计时器（加大间隔避免发送太多指令到客户端）
	Timers:CreateTimer(function()
		local t = GameRules:GetGameTime()
		local time_remaining = self.phase_duration - (t - self.phase_start_time)
		CustomGameEventManager:Send_ServerToAllClients("drt", { -- round time remaining timer!
			p = self.phase,
			t = time_remaining
		})
		return 0.3
	end)
end

function TurnManager:StartNewRound()
	local ap = self:GetActivePlayer()
	local nap = self:GetNoneActivePlayer()
	ap:DrawCard(1)
	ap:FillManaPool()
	ap:SetHasUsedAttributeCardThisRound(false)

	self:SetPhase(TURN_PHASE_STRATEGY)

	CustomGameEventManager:Send_ServerToAllClients("ds_turn_start", {
		PlayerID = ap:GetPlayerID(),
	})
	Notifications:Top(ap:GetPlayerID(),{text="your_round_start", duration=2, style={color="white",["font-size"] = "100px"}})
	Notifications:Top(nap:GetPlayerID(),{text="enemy_round_start", duration=2, style={color="white",["font-size"] = "100px"}})

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

function TurnManager:HasGameStarted()
	return self.game_started
end