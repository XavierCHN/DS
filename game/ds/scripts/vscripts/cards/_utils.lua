-- 初始化所有召唤位置
local radiant_left_bottom = Vector(-512, -200, 150)
local dire_left_bottom = Vector(-512,200,150)
local gap_distance_between_summon_locations = 256
local loc_count = 5 -- 默认双方各五个召唤位置
GameRules.vAllSummonLocations = {}
GameRules.vAllSummonLocations[DOTA_TEAM_GOODGUYS] = {}
GameRules.vAllSummonLocations[DOTA_TEAM_BADGUYS ] = {}
for i = 0, loc_count - 1 do
    table.insert(GameRules.vAllSummonLocations[DOTA_TEAM_GOODGUYS], radiant_left_bottom + Vector(gap_distance_between_summon_locations * i,0,0))
    table.insert(GameRules.vAllSummonLocations[DOTA_TEAM_BADGUYS ], dire_left_bottom + Vector(gap_distance_between_summon_locations * i, 0, 0 ))
end


function GetNearestSummonIndex(team, vLoc)
    local min = 9999
    local idx
    for i = 1, loc_count do
        local len = (vLoc - GameRules.vAllSummonLocations[team][i]):Length2D()
        if len < min then
            min = len
            idx = i
        end
    end
    return idx
end

Convars:RegisterCommand("debug_show_summon_locations",function()
    for i = 1, loc_count do
        for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
            DebugDrawCircle(GameRules.vAllSummonLocations[team][i],Vector(255,123,160),255,120,false,10)
        end
    end
end,"show all summon locations",FCVAR_CHEAT)
