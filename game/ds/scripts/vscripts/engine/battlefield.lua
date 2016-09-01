-- 战场
if BattleField == nil then
    BattleField = class({})
end

function BattleField:constructor()
    self.width = 2560
    self.line_width = 256
    self.line_count = 5
    self.base_area_width = 320
    self.origin = Vector(0, 0, 0)
    
    self.lines = {}
    for i = 1, self.line_count do
        self.lines[i] = BattleLine(self, i)
    end

    self.cards = {}
    self.minx = self:GetBattleLine(1):GetLeft().x - self.base_area_width
    self.maxx = self:GetBattleLine(1):GetRight().x + self.base_area_width
    self.miny = self:GetBattleLine(5):GetLeft().y - self.line_width / 2
    self.maxy = self:GetBattleLine(1):GetLeft().y + self.line_width / 2
end

function BattleField:IsPositionInMyField(hero, vLoc)
    if not self:IsInsideBattleField(vLoc) then
        return false
    end 
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

function BattleField:IsPositionInLine(o)
    return o.x >= self:GetBattleLine(1):GetLeft().x and o.x <= self:GetBattleLine(1):GetRight().x
end

function BattleField:IsMinionInLine(unit)
    local o = unit:GetAbsOrigin()
    return self:IsPositionInLine(o)
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
        if math.abs(pos.y - line:GetOrigin().y) <= self.line_width / 2 then
            return line
        end
    end
end

function BattleField:IsInsideBattleField(pos)
    if pos.x >= self.minx and pos.x <= self.maxx and
       pos.y >= self.miny and pos.y <= self.maxy then
       return true
    end
    return false
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

-- 获取当前线对于玩家是否是空的
function BattleField:IsLineEmpty(hero, pos)
    if not self:IsPositionInLine(pos) then
        return true
    end

    local pn = self:GetPositionBattleLine(pos)
    for _, minion in pairs(GameRules.AllMinions) do
        if minion:GetTeamNumber() == hero:GetTeamNumber() then
            local o = minion:GetAbsOrigin()
            local on = self:GetPositionBattleLine(o)
            if pn == on then
                return false
            end
        end
    end

    return true
end


if BattleLine == nil then
    BattleLine = class({})
end

function BattleLine:constructor(battleField, lineNumber)
    -- 从上到下，1到5
    self.line_number = lineNumber
    self.origin = battleField.origin + Vector(0, (3 - lineNumber) * battleField.line_width, 0)
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

Convars:RegisterCommand("debug_draw_battlefield_bounds", function()
    local ix = GameRules.BattleField.minx
    local mx =  GameRules.BattleField.maxx
    local iy = GameRules.BattleField.miny
    local my = GameRules.BattleField.maxy
    DebugDrawCircle(Vector(ix,iy,128), Vector(255,0,0), 100, 32, true, 5)
    DebugDrawCircle(Vector(ix,my,128), Vector(255,0,0), 100, 32, true, 5)
    DebugDrawCircle(Vector(mx,iy,128), Vector(255,0,0), 100, 32, true, 5)
    DebugDrawCircle(Vector(mx,my,128), Vector(255,0,0), 100, 32, true, 5)
end, "", 0)