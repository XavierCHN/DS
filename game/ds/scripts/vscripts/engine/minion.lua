

function CDOTA_BaseNPC:InitDSMinion()
    self.hero = nil
    self.line = nil
end

function CDOTA_BaseNPC:SetPlayer(hero)
    self.hero = hero
end

function CDOTA_BaseNPC:GetPlayer()
    return self.hero
end

function CDOTA_BaseNPC:StartMinionAIThink()
    self.ent:SetContextThink(DoUniqueString("mb"), function()
        if not (IsValidEntity(self) and self:IsAlive()) then
            return nil
        end

        -- 根据当前的位置刷新单位所属的战场行
        local o = self:GetAbsOrigin()
        local battle_line = GameRules.BattleField:GetPositionBattleLine(o)
        if self.battle_line and self.battle_line ~= battle_line then
            self.battle_line:RemoveMinion(self)
            self.battle_line = battle_line
        end
        self.battle_line:AddMinion(self)

        if GameRules.TurnManager:GetPhase() == TURN_PHASE_BATTLE then
            local target_pos = self:GetCurrentGoalTargetPos()
            if not AggroFilter(self) and target_pos ~= self.target_pos then
                self.target_pos = target_pos
                self:MoveToPositionAggressive(target_pos)
            else
                self.target_pos = nil
            end
        else
            self:Stop()
        end

        return 0.03
    end, 0)
end

function CDOTA_BaseNPC:SetGoalPosition(pos)
    self.g_pos = pos
end

function CDOTA_BaseNPC:GetGoalPosition()
    return self.g_pos
end

function CDOTA_BaseNPC:GetBattleLine()
    return self.battle_line
end

function CDOTA_BaseNPC:IsTargetOnNeighborLine(target)
    if not target:GetBattleLine() then return false end
    return math.abs(self:GetBattleLine() - target:GetBattleLine()) == 1
end

function CDOTA_BaseNPC:IsTargetOnSameLine(target)
    if not target:GetBattleLine() then return false end
    return self:GetBattleLine() == target:GetBattleLine()
end

function CDOTA_BaseNPC:EnableAutoAttack()
    self.enable_auto_attack = true
end

function CDOTA_BaseNPC:DisableAutoAttack()
    self.enable_auto_attack = false
end

function CDOTA_BaseNPC:GetCurrentGoalTargetPos()
    -- 如果尚在基地内，选择随机目标
    if not self.has_selected_target_random_line then
        self.target_battleLine = GameRules.BattleField:GetBattleLine(RandomInt(1, 5))
        self.has_selected_target_random_line = true
    end

    -- 如果尚在基地内，向随机目标点移动
    if GameRules.BattleField:IsMinionInMyBaseArea(self) then
        if self:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            return self.target_battleLine:GetLeft() + Vector(50,0,0)
        elseif self:GetTeamNumber() == DOTA_TEAM_BADGUYS then
            return self.target_battleLine:GetRight() - Vector(50,0,0)
        end
    end

    -- 如果在线上，往另一侧移动
    if GameRules.BattleField:IsMinionInLine(self) then
        if self:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            return self:GetBattleLine():GetRight()
        elseif self:GetTeamNumber() == DOTA_TEAM_BADGUYS then
            return self:GetBattleLine():GetLeft()
        end
    end

    -- 如果在外面，往敌方英雄处移动
    if GameRules.BattleField:IsMinionInEnemyBaseArea(self) then
        for _, hero in pairs(GameRules.AllHeroes) do
            if hero:GetTeamNumber() ~= self:GetTeamNumber() then
                return hero:GetAbsOrigin()
            end
        end
    end
end
