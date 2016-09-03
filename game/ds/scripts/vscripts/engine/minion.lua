function CDOTA_BaseNPC:AggroFilter()
    local target = self:GetAttackTarget() or self:GetAggroTarget()
    if target then
        local bCanAttackTarget = self:CanAttackTarget(target)
        if self.disable_autoattack == 0 then
            if target ~= self.attack_target then
                if bCanAttackTarget then
                    self.attack_target = target
                    return
                else
                    local enemies = FindEnemiesInRadius(self, self:GetAcquisitionRange())
                    local target
                    if #enemies > 0 then
                        for _,enemy in pairs(enemies) do
                            if self:CanAttackTarget(enemy) then
                                target = enemy
                                if not enemy:IsRealHero() then -- 找到了非英雄单位，则不再寻找，默认不直接攻击英雄
                                    break;
                                end
                            end
                        end
                        self:Attack(target)
                    end
                end
            end
        end
    end
    if target and not self:CanAttackTarget(target) then
        self.attack_target = nil
        self.disable_autoattack = 1
        -- 重新发送指令
        self:AttackMoveToNextTarget()
    end

    -- 如果找不到目标，清空单位的目标
    self.attack_target = nil
end

function CDOTA_BaseNPC:AttackMoveToNextTarget()
    local target_pos = self.path:GetData(1)
    if self.attack_target == nil and not self.has_ordered then
        self.has_ordered = true
        if target_pos then
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

function CDOTA_BaseNPC:InitDSMinion(card)
    self.has_ordered = nil

    self.card = card

    -- 设置血量等各种信息
    self:SetBaseDamageMax(card.data.atk)
    self:SetBaseDamageMin(card.data.atk)
    self:SetBaseMaxHealth(card.data.hp)
    self:SetHealth(card.data.hp)
    self.ms = card.data.move_speed
    self.ar = card.data.attack_range

    self:AddNewModifier(self, nil, "modifier_minion_rooted", {})
    self:AddNewModifier(self, nil, "modifier_minion_disable_attack", {})
    self:AddNewModifier(self, nil, "modifier_minion_data", {})
    self:AddNewModifier(self, nil, "modifier_minion_summon_disorder", {})
    self:AddNewModifier(self, nil, "modifier_phased", {})

    local abilities = self.card.abilities or {}
    for _, ability_data in pairs(abilities) do
        if ability_data.type == "static" then
            self:AddAbility(StaticAbility(ability_data, self))
        end
        if ability_data.type == "trigger" then
            self:AddAbility(TriggerAbility(ability_data, self))
        end
        if ability_data.type == "active" then
            self:AddAbility(ActiveAbility(ability_data, self))
        end
    end

    self:StartMinionAIThink()

    self:SetCardID(card:GetID())

    table.insert(GameRules.AllMinions, self)
end

function CDOTA_BaseNPC:SetPlayer(player)
    self.player = player
end

function CDOTA_BaseNPC:SetCardID(id)
    self.cardid = id
    CustomGameEventManager:Send_ServerToAllClients("ds_minion_card", {
        CardID = id,
    })
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

        if area and area == BATTLEFIELD_AREA_MY_BASE then
            -- 如果在己方基地，发现目标位置的线上已经有单位，那么需要
            -- 重新选择目标线路？
            -- 这个规则还是可以todo一下，看看实际的运用效果看看是利大于弊还是弊大于利
        end

        if area and area == BATTLEFIELD_AREA_LINE then 
            if not self.battle_line then
                self.battle_line = GameRules.BattleField:GetPositionBattleLine(so)
            else
                local bn = GameRules.BattleField:GetPositionBattleLine(so)
                if bn ~= self.battle_line then
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
        self:AggroFilter()

        self:AttackMoveToNextTarget()

        local target_pos = self.path:GetData(1)
        if self.attack_target ~= nil or (target_pos and (so - target_pos):Length2D() <= 30 ) then
            self.path:Remove(1)
            self.has_ordered = nil
            self:AttackMoveToNextTarget()
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
        -- DebugDrawCircle(GetGroundPosition(node, self), Vector(0,255,0), 100, 64, true, 5)
    end

    self.path = path

    return path
end
