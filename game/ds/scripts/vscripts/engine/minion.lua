function AggroFilter( unit )
    local target = unit:GetAttackTarget() or unit:GetAggroTarget()
    if target then
        local bCanAttackTarget = unit:CanAttackTarget(target)
        if unit.disable_autoattack == 0 then
            if target ~= unit.attack_target then
                if bCanAttackTarget then
                    unit.attack_target = target
                    return
                else
                    local enemies = FindEnemiesInRadius(unit, unit:GetAcquisitionRange())
                    local target
                    if #enemies > 0 then
                        for _,enemy in pairs(enemies) do
                            if unit:CanAttackTarget(enemy) then
                                if target and target:IsRealHero() then -- 不优先攻击英雄，todo除非！
                                    target = enemy
                                end
                            end
                        end
                        unit:Attack(target)
                    end
                end
            end
        end

        if not bCanAttackTarget then
            unit.attack_target = nil
            unit.disable_autoattack = 1
            unit:Stop()
        end
    end

    -- 如果找不到目标，清空单位的目标
    unit.attack_target = nil
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
    self:RemoveModifierByName("modifier_phased")
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
            return target
        end
    end
    return nil
end

function CDOTA_BaseNPC:InitDSMinion()
    self.has_ordered = nil
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
        if not IsValidAlive(self) then
            return nil 
        end

        if GameRules.TurnManager.current_turn:GetPhase() ~= TURN_PHASE_BATTLE then 
            self.has_ordered = nil
            return 0.1 
        end

        local so = self:GetAbsOrigin()
        local area = GameRules.BattleField:GetMinionArea(self)

        if not self.path then
            self:BuildPath(area)
        end

        if area == BATTLEFIELD_AREA_LINE then 
            if not self.battle_line then
                self.battle_line = GameRules.BattleField:GetPositionBattleLine(so)
            else
                local bn = GameRules.BattleField:GetPositionBattleLine(so)
                if bn ~= self.battle_line then
                    self.battle_line:RemoveMinion(self)
                    bn:AddMinion(self)
                    self.battle_line = bn
                    -- 改变当前线路之后需要重新规划线路
                    self:BuildPath(area)
                end
            end
        end

        -- 如果发生了回退，那么需要重新规划线路
        if self.area and area < self.area then self:BuildPath() end
        
        -- 记录当前已经行进到的区域
        self.area = area
        
        -- 判断当前目标能否攻击
        AggroFilter(self)

        local target_pos = self.path:GetData(1)
        if self.attack_target == nil and not self.has_ordered then
            self.has_ordered = true
            if target_pos then
                DebugDrawCircle(target_pos, Vector(255,0,0), 100, 50, true, 5)
                print "sending order into unit"
                local order = {
                    OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                    UnitIndex = self:entindex(),
                    Position = target_pos
                }
                ExecuteOrderFromTable(order)
                self:AddNewModifier(self, nil, "modifier_phased", {})
                return 0.03
            end
        end
        if self.attack_target ~= nil or (target_pos and (so - target_pos):Length2D() <= 30 ) then
            self.path:Remove(1)
            self.has_ordered = nil
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

function CDOTA_BaseNPC:BuildPath(area)

    local team = self:GetTeamNumber()
    local path = List()

    local random_line
    if area == BATTLEFIELD_AREA_MY_BASE then
        random_line = GameRules.BattleField:GetBattleLine(RandomInt(1, 5))
        self.battle_line = random_line
        if team == DOTA_TEAM_GOODGUYS then
            path:AddRear(GetGroundPosition(self.battle_line:GetLeft(), self))
        else
            path:AddRear(GetGroundPosition(self.battle_line:GetRight(), self))
        end
        
    end

    -- 如果是直接召唤在线上的，那么在召唤的时候就已经拥有battle_line属性了
    if area <= BATTLEFIELD_AREA_LINE then
        if not self.battle_line then 
            self.battle_line = GameRules.BattleField:GetPositionBattleLine(self:GetAbsOrigin()) 
        end
        if team == DOTA_TEAM_GOODGUYS then
            path:AddRear(GetGroundPosition(self.battle_line:GetRight(), self))
        else
            path:AddRear(GetGroundPosition(self.battle_line:GetLeft(), self))
        end
    end

    for _, hero in pairs(GameRules.AllHeroes) do
        if hero:GetTeamNumber() ~= self:GetTeamNumber() then
            path:AddRear(GetGroundPosition(hero:GetAbsOrigin(),self))
        end
    end

    local i = 1
    for i = 1, 3 do
        local node = path:GetData(i)
        if not node then break end
        DebugDrawCircle(GetGroundPosition(node, self), Vector(0,255,0), 100, 64, true, 5)
    end

    self.path = path

    return path
end
