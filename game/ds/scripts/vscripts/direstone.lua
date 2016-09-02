if DS == nil then DS = class({}) end

require 'enums'
require 'const'

require 'utils.functions'
require 'utils.json'
require 'utils.debug_card_list'
require 'utils.list'
require 'utils.units'
require 'utils.card_loader'

require 'libraries.timers'
require 'libraries.playertables'
require 'libraries.notifications'
require 'libraries.worldpanels'

require 'engine.turn'
require 'engine.turn_manager'
require 'engine.player_resource'
require 'engine.card'
require 'engine.minion'
require 'engine.hero'
require 'engine.deck'
require 'engine.hand'
require 'engine.battlefield'
require 'engine.selector'
require 'engine.event_manager'

require 'engine.ability.ability'
require 'engine.ability.trigger_ability'
require 'engine.ability.static_ability'
require 'engine.ability.active_ability'

-- GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
-- GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
-- GameRules.ItemsKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")

function DS:Init()

    GameRules.AllCreatedCards = {}
    GameRules.AllAbilities = {}

    local mode = GameRules:GetGameModeEntity()
    
    mode:SetFogOfWarDisabled(true)
    mode:SetCustomGameForceHero("npc_dota_hero_invoker")
    
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 1)
    GameRules:SetPreGameTime(DS_TURN_TIME)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(0)
    GameRules:SetCustomGameSetupTimeout(3)
    
    self.mode = mode
    GameRules.mode = mode
    GameRules.GameMode = self
    
    GameRules.TurnManager = TurnManager()
    GameRules.BattleField = BattleField() -- todo 重新考虑战场的逻辑
    GameRules.EventManager = EventManager()

    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(DS, "OnGameRulesStateChanged"), self)

    CustomGameEventManager:RegisterListener("ds_player_click_card",Dynamic_Wrap(DS, "OnPlayerClickCard"))
    CustomGameEventManager:RegisterListener('ds_player_active_ability' ,Dynamic_Wrap(DS, "OnPlayerActiveAbility"))

    LinkLuaModifier("modifier_minion_rooted", "engine/modifiers/modifier_minion_rooted", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_minion_disable_attack", "engine/modifiers/modifier_minion_disable_attack", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_minion_data", "engine/modifiers/modifier_minion_data", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_minion_summon_disorder", "engine/modifiers/modifier_minion_summon_disorder", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_minion_autoattack", "engine/modifiers/modifier_minion_autoattack", LUA_MODIFIER_MOTION_NONE)
end

function DS:OnPlayerActiveAbility(args)
    local player = PlayerResource:GetPlayer(args.PlayerID)
    local hero = player:GetAssignedHero()
    local uid = args.UniqueId
    local ability = GetAbilityByUniqueID(uid)

    local canuse, reason = ability:Validate_BeforeExecute()
    if not canuse then
        ShowError(args.PlayerID, reason)
        return
    end

    ability:OnActive()
end

function DS:OnPlayerClickCard(args)
    local playerid = args.PlayerID
    local player = PlayerResource:GetPlayer(playerid)
    local hero = player:GetAssignedHero()
    local uid = args.UniqueId
    local card = GetCardByUniqueID(uid)

    -- 是否允许释放
    local canuse, reason = card:Validate_BeforeExecute()
    if not canuse then
        ShowError(playerid, reason) 
        return 
    end

    card:OnExecute()
end

function DS:OnGameRulesStateChanged()
    local newState = GameRules:State_Get()
    
    if newState == DOTA_GAMERULES_STATE_PRE_GAME then
        -- 储存所有玩家和英雄
        Timers:CreateTimer(2, function()
            GameRules.AllHeroes = {}
            for playerID = -1, DOTA_MAX_PLAYERS do
                local player = PlayerResource:GetPlayer(playerID)
                if player then
                    local hero = player:GetAssignedHero()
                    if hero then
                        table.insert(GameRules.AllHeroes, hero)
                    end
                end
            end
            
            -- 如果是我自己一个人加入了游戏
            -- 那么随便创建一个电脑
            if TableCount(GameRules.AllHeroes) == 1 then
                SendToServerConsole('dota_create_fake_clients')
                Timers:CreateTimer(2, function()
                    local set = false
                    for i = 1, DOTA_MAX_PLAYERS do
                        if not set then
                            local p = PlayerResource:GetPlayer(i)
                            if p then
                                Say(nil, "Found " .. i, false)
                                local h = CreateHeroForPlayer("npc_dota_hero_invoker", p)
                                table.insert(GameRules.AllHeroes, h)
                                p:SetTeam(DOTA_TEAM_BADGUYS)
                                h:SetTeam(DOTA_TEAM_BADGUYS)
                                set = true
                            end
                        end
                    end
                    
                    for _, hero in pairs(GameRules.AllHeroes) do
                        hero:InitDSHero()
                    end
                    GameRules.TurnManager:Start()
                end)
            else
                for _, hero in pairs(GameRules.AllHeroes) do
                    hero:InitDSHero()
                end
                GameRules.TurnManager:Start()
            end
        end)
    end
    
    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        GameRules.TurnManager:Run()
    end
end

function DS:GetOpponent(hero)
    for _, h in pairs(GameRules.AllHeroes) do
        if h ~= hero then
            return h
        end
    end
end

function DS:EndGameWithLoser(loser)
    local winner = self:GetOpponent(loser)
    GameRules:SetGameWinner(winner:GetTeamNumber())
    
    CustomGameEventManager:Send_ServerToAllClients("game_end", {
        winner = winner:GetPlayerID(),
        loser = loser:GetPlayerID(),
    })
end
