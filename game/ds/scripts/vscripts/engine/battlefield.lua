-- 战场
if BattleField == nil then
    BattleField = class({})
end

function BattleField:constructor()
    self.width = 2560
    self.line_count = 5
    self.origin = Vector(0, 0, 0)
    
    self.lines = {}
    for i = 1, self.line_count do
        self.lines[i] = BattleLine(self, i)
    end

    self.cards = {}
end

function BattleField:IsMyField(hero, vLoc)
    if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS and vLoc.x < self.origin.x then
        return true
    end
    if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS and vLoc.x > self.origin.x then
        return true
    end
    return false
end

function BattleField:IsMinionInMyBaseArea(unit)
    local o = unit:GetAbsOrigin()
    local t = unit:GetTeamNumber()
    if t == DOTA_TEAM_GOODGUYS and o.x < self:GetBattleLine(1):GetLeft().x then
        return true
    end
    if t == DOTA_TEAM_BADGUYS and o.x > self:GetBattleLine(1):GetRight().x then
        return true
    end

    return false
end

function BattleField:IsMinionInEnemyBaseArea(unit)
    local o = unit:GetAbsOrigin()
    local t = unit:GetTeamNumber()
    if t == DOTA_TEAM_GOODGUYS and o.x > self:GetBattleLine(1):GetRight().x then
        return true
    end
    if t == DOTA_TEAM_BADGUYS and o.x < self:GetBattleLine(1):GetLeft().x then
        return true
    end

    return false
end

function BattleField:IsMinionInLine(unit)
    local o = unit:GetAbsOrigin()
    local t = unit:GetTeamNumber()
    return o.x >= self:GetBattleLine(1):GetLeft().x and o.x <= self:GetBattleLine(1):GetRight().x
end


function BattleField:GetTargetPositionForTeam(team, lineNumber)
    if team == DOTA_TEAM_GOODGUYS then
        return self.line[lineNumber]:GetRight()
    end
    if team == DOTA_TEAM_BADGUYS then
        return self.line[lineNumber]:GetLeft()
    end
end

function BattleField:GetBattleLine(i)
    return self.lines[i]
end

function BattleField:GetPositionBattleLine(pos)
    for _, line in pairs(self.lines) do
        if math.abs(pos.y - line:GetOrigin().y) <= BATTLE_FIELD_LINE_WIDTH / 2 then
            return line
        end
    end
end

-- 获取单位当前所在的战场区域
function BattleField:GetMinionArea(minion)
    local pos = minion:GetAbsOrigin()
    local team = minion:GetTeamNumber()
    local x = pos.x
    local left = self:GetBattleLine(1):GetLeft().x
    local right = self:GetBattleLine(1):GetRight().x
    if x < left then
        if team == DOTA_TEAM_GOODGUYS then
            return BATTLEFIELD_AREA_MY_BASE
        else
            return BATTLEFIELD_AREA_ENEMY_BASE
        end
    elseif x > right then
        if team == DOTA_TEAM_GOODGUYS then
            return BATTLEFIELD_AREA_ENEMY_BASE
        else
            return BATTLEFIELD_AREA_MY_BASE
        end
    elseif x >= left and x <= right then
        return BATTLEFIELD_AREA_LINE
    end
end



if BattleLine == nil then
    BattleLine = class({})
end

function BattleLine:constructor(battleField, lineNumber)
    -- 从上到下，1到5
    self.line_number = lineNumber
    self.origin = battleField.origin + Vector(0, (3 - lineNumber) * BATTLE_FIELD_LINE_WIDTH, 0)
    self.center = self.origin
    
    self.left_corner = self.origin - Vector(battleField.width / 2, 0, 0)
    self.right_corner = self.origin + Vector(battleField.width / 2, 0, 0)

    self.minions = {}
end

function BattleLine:GetLeft()
    return self.left_corner
end

function BattleLine:GetRight()
    return self.right_corner
end

function BattleLine:GetLineNumber()
    return self.line_number
end

function BattleLine:GetOrigin()
    return self.origin
end

function BattleLine:GetNearestCornerForMyTeam(team)
    if team == DOTA_TEAM_GOODGUYS then
        return self:GetLeft()
    elseif team == DOTA_TEAM_BADGUYS then
        return self:GetRight()
    end
end

function BattleLine:AddMinion(minion)
    self.minions[minion] = true
end

function BattleLine:RemoveMinion(minion)
    self.minions[minion] = nil
end

function BattleLine:IsLineEmptyForPlayer(hero)
    for minion, _ in pairs(self.minions) do
        if IsValidEntity(minion) and minion:IsAlive() then
            if minion:GetPlayer() == hero then
                return false
            end
        else
            self.minions[minion] = nil
        end
    end

    return true
end