function AggroFilter( unit )
    local target = unit:GetAttackTarget() or unit:GetAggroTarget()
    local enemies = FindEnemiesInRadius(unit, unit:GetAcquisitionRange())
    if #enemies > 0 then
        for _,enemy in pairs(enemies) do
            if unit:CanAttackTarget(enemy) then
                target = enemy
                unit:Attack(enemy)
                return
            end
        end
    end
    if target and not unit:CanAttackTarget(target) then
        unit.attack_target = nil
        unit.disable_autoattack = 1
        unit:Stop()
    end
end


function CDOTA_BaseNPC:CanAttackTarget( target )
    local attacks_enabled = self:HasAttackCapability()
    if not self:HasAttackCapability() or self:IsDisarmed() or target:IsInvulnerable() or target:IsAttackImmune() then
        return false
    end

    if self:IsRangedAttacker() and self:IsTargetOnNeighborLine(target) then
        return true
    end
    if not self:IsRangedAttacker() and (not target:HasFlyMovementCapability()) and self:IsTargetOnSameLine(target) then
        return true
    end
    if not GameRules.BattleField:IsMinionInEnemyBaseArea(self) and target:IsRealHero() then
        return false
    end
    return true

end

function CDOTA_BaseNPC:Attack(target)
    self:MoveToTargetToAttack(target)
    self.target_pos = nil
    self.attack_target = target
    self.disable_autoattack = 0
end

function FindAttackableEnemies( unit )
    local radius = unit:GetAcquisitionRange()
    if not radius then return end
    local enemies = FindEnemiesInRadius( unit, radius )
    for _,target in pairs(enemies) do
        if unit:CanAttackTarget(target) and not target:HasModifier("modifier_invisible") then
            if bIncludeNeutrals then
                return target
            elseif target:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
                return target
            end
        end
    end
    return nil
end

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
    self:AddNewModifier(self, nil, "modifier_minion_autoattack", {})
    self:SetContextThink(DoUniqueString("mb"), function()
        
        if not IsValidAlive(self) then return nil end

        -- 根据当前的位置刷新单位所属的战场行
        local o = self:GetAbsOrigin()
        local battle_line = GameRules.BattleField:GetPositionBattleLine(o)
        if not self.battle_line then
            self.battle_line = battle_line
        elseif self.battle_line ~= battle_line then
            self.battle_line:RemoveMinion(self)
            if battle_line then
                self.battle_line = battle_line
                self.battle_line:AddMinion(self)
            end
        end

        if GameRules.TurnManager:GetPhase() == TURN_PHASE_BATTLE then
            AggroFilter( self )

            self.target_pos = self:GetCurrentGoalTargetPos()

            if (self.target_pos and (self.target_pos - self:GetAbsOrigin()):Length2D() < 20 ) then
                self:Stop()
            end
     
            if self.attack_target == nil and self.target_pos then
                DebugDrawCircle(GetGroundPosition(self.target_pos, self), Vector(0, 255, 0), 100, 32, true, 0.2)
                self:MoveToPosition(self.target_pos)
            else
                if not IsValidAlive(self.attack_target) then
                    self.attack_target = nil
                end
            end

            return 0.03
        else
            -- self:Stop()
        end

        return 0.03
    end, 0)
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
            return self:GetBattleLine():GetRight() + Vector(50,0,0)
        elseif self:GetTeamNumber() == DOTA_TEAM_BADGUYS then
            return self:GetBattleLine():GetLeft() - Vector(50,0,0)
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
