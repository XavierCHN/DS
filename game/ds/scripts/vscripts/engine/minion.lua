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

-- function CNWSpawner:CreateShipAI(ship, pathCornerTable)

-- 	-- 重载IsValidEntity


-- 	local old_Valid = IsValidEntity
-- 	local function IsValidEntity(ent)
-- 		return ent and old_Valid(ent) and ent:IsAlive()
-- 	end

-- 	-- 获取第一个路径点并开始移动


-- 	ship.currentTargetIndex = 2
-- 	ship.currentTarget = pathCornerTable[ship.currentTargetIndex]
-- 	ship:MoveToPositionAggressive(GetGroundPosition(ship.currentTarget:GetAbsOrigin(), ship))

-- 	-- 将船只加入碰撞检测器


-- 	GameRules.ShipCollider:Push(ship)

-- 	-- 启动小船AI循环


-- 	ship:SetContextThink(DoUniqueString("ship_ai"), function()
		
-- 		-- 检测单位是否有效


-- 		if not IsValidEntity(ship) then
-- 			return nil
-- 		end

-- 		-- 获取当前位置


-- 		if ship.currentTarget and ship.currentTarget:IsNull() then return nil end
-- 		local so = ship:GetAbsOrigin()
-- 		local to = ship.currentTarget:GetAbsOrigin()

-- 		-- 如果距离当前目标地点很近，那么向下一个目标地点行进


-- 		-- 如果当前目标已经是基地了，那么不再切换攻击移动目标位置


-- 		-- 暂时改大路径点容差，避免因为某一个怪不动导致堆积


-- 		if (so - to):Length2D() <= 250 and not ship.__bTargetingBase then
-- 			ship.currentTargetIndex = ship.currentTargetIndex + 1
-- 			ship.currentTarget = pathCornerTable[ship.currentTargetIndex]
-- 			-- 如果没有下一个路径点了，将目标指向主基地


-- 			if ship.currentTarget == nil then
-- 				ship.currentTarget = self:GetEnemyBase(ship)
-- 				if ship.currentTarget == nil then
-- 					print("Warning! ship trying to target base which is not existed!")
-- 					return nil
-- 				end
-- 				ship.__bTargetingBase = true
-- 			end
-- 			ship:MoveToPositionAggressive(GetGroundPosition(ship.currentTarget:GetAbsOrigin(), ship))
-- 		end

-- 		-- 如果NPC船只被英雄吸引了仇恨


-- 		if ship:GetAggroTarget() ~= nil then
-- 			if ship:GetAggroTarget().IsHero then
-- 				if ship:GetAggroTarget():IsHero() then
-- 					-- 寻找攻击范围内+buffer（这个常量设置为最多移动100距离）非英雄的单位


-- 					local flAttackRange = ship:GetAttackRange() + 300
-- 					local vCreepEnemies = FindUnitsInRadius(ship:GetTeamNumber(), ship:GetAbsOrigin(), nil, flAttackRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
-- 					-- 选择最近的非英雄单位进行攻击


-- 					if #vCreepEnemies > 0 and vCreepEnemies[1] then
-- 						ship:MoveToTargetToAttack(vCreepEnemies[1])
-- 						ship.__hAttackingTarget = vCreepEnemies[1]
-- 					else
-- 						-- 如果找不到非英雄目标，记录开始追击的位置


-- 						ship.__chasingHeroStartPosition = ship:GetAbsOrigin()
-- 					end
-- 				end
-- 			end
-- 		end

-- 		-- 如果是在追击完英雄回归正轨的状态，那么在遇上一个普通单位之前，不会再进行攻击


-- 		if ship.__movingBackToNormalPath then
-- 			local flAttackRange = ship:GetAttackRange() + 300
-- 			local vCreepEnemies = FindUnitsInRadius(ship:GetTeamNumber(), ship:GetAbsOrigin(), nil, flAttackRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
-- 			if #vCreepEnemies > 0 then
-- 				-- 如果碰上了非英雄单位，那么开始正常攻击移动动作


-- 				ship:MoveToPositionAggressive(GetGroundPosition(ship.currentTarget:GetAbsOrigin(), ship))
-- 				ship.__movingBackToNormalPath = nil -- 清除回归状态

-- 			end
-- 		end

-- 		-- 如果当前攻击目标死亡，那么继续往当前目标地点行进


-- 		if ship.__hAttackingTarget and not IsValidEntity(ship.__hAttackingTarget) then
-- 			ship:MoveToPositionAggressive(GetGroundPosition(ship.currentTarget:GetAbsOrigin(), ship))
-- 			ship.__hAttackingTarget = nil
-- 		end

-- 		-- 最多追击英雄1000距离


-- 		if ship.__chasingHeroStartPosition and (ship:GetAbsOrigin() - ship.__chasingHeroStartPosition):Length2D() > 1000 then
-- 			ship:MoveToPosition(GetGroundPosition(ship.currentTarget:GetAbsOrigin(), ship))
-- 			ship.__movingBackToNormalPath = true
-- 			ship.__chasingHeroStartPosition = nil
-- 		end
-- 		return 0.1
-- 	end, 0.1)
-- end

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
