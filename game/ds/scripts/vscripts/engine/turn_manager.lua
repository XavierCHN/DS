if TurnManager == nil then TurnManager = class({}) end

function TurnManager:Start()
	self.turnCount = 0
	self:SelectFirstActivePlayer()
	self:ShufflePlayerDeckAndDrawInitialCards()
	GameRules.AllMinions = GameRules.AllMinions or {}
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

function TurnManager:GetPhase()
	return self.current_turn:GetPhase()
end

function TurnManager:Run()

	-- 启动第一个回合
	self.ap = self.fp
	self.current_turn = Turn(self.ap)
	self.current_turn:Start()
	self.game_started = true

	-- 启动主循环计时器
	Timers:CreateTimer(function()
		if self.current_turn:IsTurnEnd() then
			if self.ap == self.fp then
				self.ap = self.nfp
				self.nap = self.fp
			else
				self.ap = self.fp
				self.nap = self.nfp
			end
			self.current_turn = Turn(self.ap)
			self.current_turn:Start()
		end
		return 0.03
	end)
end

function TurnManager:GetActivePlayer()
	return self.ap
end

function TurnManager:GetNoneActivePlayer()
	return self.nap
end

function TurnManager:HasGameStarted()
	return self.game_started
end

function TurnManager:IsMeetTimingRequirement(hero, timing)
	if timing ~= TIMING_INSTANT then
        if self:GetActivePlayer():GetTeamNumber() ~= hero:GetTeamNumber() then
            return false, "cannot_cast_in_enemy_turn"
        end
        if self:GetPhase() ~= TURN_PHASE_STRATEGY then
            return false, "cannot_cast_outside_strategy_phase"
        end
    end
    return true,""
end
