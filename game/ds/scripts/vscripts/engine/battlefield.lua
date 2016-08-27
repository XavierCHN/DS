-- 战场
if BattleField == nil then
    BattleField = class({})
end

function BattleField:constructor()
    self.width = 2560
    self.line_count = 5
    self.line_width = 256
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
end

function BattleField:GetTargetPositionForTeam(team, lineNumber)
    if team == DOTA_TEAM_GOODGUYS then
        return self.line[lineNumber]:GetRight()
    end
    if team == DOTA_TEAM_BADGUYS then
        return self.line[lineNumber]:GetLeft()
    end
end

if BattleLine == nil then
    BattleLine = class({})
end

function BattleLine:constructor(battleField, lineNumber)
    -- 从上到下，1到5
    self.origin = battleField.origin + Vector(0, (3 - lineNumber) * 256, 0)
    self.center = self.origin
    
    self.left_corner = self.origin - Vector(battleField.width / 2, 0, 0)
    self.right_corner = self.origin + Vector(battleField.width / 2, 0, 0)
end

function BattleLine:GetLeft()
    return self.left_corner
end

function BattleLine:GetRight()
    return self.right_corner
end
