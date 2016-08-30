if Turn == nil then Turn = class({}) end

-- 使用主动玩家来初始化一个回合结构
function Turn:constructor(active_player)
    self.player = active_player
    self.current_phase = nil
end

function Turn:Start()
    self.player:DrawCard(1)
    self.player:FillManaPool()
    self.player:SetHasUsedAttributeCardThisRound(false)

    self:EnterNextPhase()

    CustomGameEventManager:Send_ServerToAllClients("ds_turn_start", {
		PlayerID = self.player:GetPlayerID(),
	})

    for _, hero in pairs(GameRules.AllHeroes) do
        if hero == self.player then
            Notifications:Top(hero:GetPlayerID(),{text="your_round_start", duration=2, style={color="white",["font-size"] = "100px"}})
        else
            Notifications:Top(hero:GetPlayerID(),{text="enemy_round_start", duration=2, style={color="white",["font-size"] = "100px"}})
        end
    end

    Timers:CreateTimer(function()
        if self.bTurnEnd then
            return nil
        end

        if self.bPhaseEnd then
            self.bPhaseEnd = nil
            self:EnterNextPhase()
        end

        local t = GameRules:GetGameTime()
        if t - self.phase_start_time > self.phase_duration then
            self:EndPhase()
        end

        return 0.03
    end)
end

function Turn:GetPhase()
    return self.current_phase
end

function Turn:EnterNextPhase()
    local newPhase
    if self.current_phase == nil then
        newPhase = TURN_PHASE_STRATEGY
    elseif self.current_phase == TURN_PHASE_STRATEGY then
        newPhase = TURN_PHASE_BATTLE
    elseif self.current_phase == TURN_PHASE_BATTLE then
        newPhase = TURN_PHASE_POST_BATTLE
    else
        self:EndTurn()
    end
        
    self.flPhaseStartTime = GameRules:GetGameTime()
    self.current_phase = newPhase

	if newPhase == TURN_PHASE_STRATEGY then
		print("entering phase strategy", math.floor(GameRules:GetGameTime()))
		self.phase_duration = DS_ROUND_TIME_STRATEGY
		self.phase_start_time = GameRules:GetGameTime()

		for k, minion in pairs(GameRules.AllMinions) do
			if IsValidAlive(minion) then
				minion:RemoveModifierByName("modifier_minion_summon_disorder") -- 在回合开始阶段去掉所有的召唤失调状态
			else
				GameRules.AllMinions[k] = nil
			end
		end

	elseif newPhase == TURN_PHASE_BATTLE then
		print("entering phase battle", math.floor(GameRules:GetGameTime()))
		self.phase_duration = DS_ROUND_TIME_BATTLE
		self.phase_start_time = GameRules:GetGameTime()

		for k, minion in pairs(GameRules.AllMinions) do
			if IsValidEntity(minion) and minion:IsAlive() then
				if not minion:HasModifier("modifier_minion_summon_disorder") or minion:HasModifier("ds_charge") then
					minion:RemoveModifierByName("modifier_minion_rooted")
					minion:RemoveModifierByName("modifier_minion_disable_attack")
				else
					minion:RemoveModifierByName("modifier_minion_disable_attack")
				end
			else
				GameRules.AllMinions[k] = nil
			end
		end

	elseif newPhase == TURN_PHASE_POST_BATTLE then
		print("entering phase post battle", math.floor(GameRules:GetGameTime()))
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

function Turn:EndPhase()
    self.bPhaseEnd = true
end

function Turn:EndTurn()
    self.bTurnEnd = true
end

function Turn:IsTurnEnd()
    return self.bTurnEnd
end

function Turn:GetPlayer()
    return self.player
end

