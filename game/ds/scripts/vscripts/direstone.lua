if DS == nil then DS = class({}) end

require 'utility_functions'
require 'utils.json'

require 'settings'

require 'libraries.timers'
require 'libraries.playertables'

require 'engine.turn_manager'
require 'engine.player'
require 'engine.player_resource'
require 'engine.hero'
require 'engine.deck'
require 'engine.hand'
require 'engine.gamerules'

require 'cards.core.core'

function DS:Init()
    local mode = GameRules:GetGameModeEntity()

    mode:SetFogOfWarDisabled(true)
    mode:SetCustomGameForceHero("npc_dota_hero_invoker")

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,1)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS ,1)
    GameRules:SetPreGameTime(DS_TURN_TIME)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(0)
    GameRules:SetCustomGameSetupTimeout(3)

    self.mode = mode
    GameRules.mode = mode
    GameRules.GameMode = self

    -- 初始化各种数据结构
    GameRules.TurnManager = TurnManager()
    GameRules.CardCore = CardCore()


    GameRules.CardCore:Start()
    ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(DS, "OnGameRulesStateChanged"),self)
end

function DS:OnGameRulesStateChanged()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		print("now entering pregame")
		-- 储存所有玩家和英雄
		Timers:CreateTimer(2, function()
			GameRules.AllHeroes = {}
			GameRules.AllPlayers = {}
			for playerID = -1, DOTA_MAX_PLAYERS do
				local player = PlayerResource:GetPlayer(playerID)
				if player then
					table.insert(GameRules.AllPlayers, player)
					local hero = player:GetAssignedHero()
					if hero then
						table.insert(GameRules.AllHeroes, hero)
						hero:InitDSHeroData()
					end
				end
			end

			-- 如果是我自己一个人加入了游戏
			-- 那么随便创建一个电脑
			if TableCount(GameRules.AllHeroes) == 1 then
				Say(nil,"Why I'm always lonely?" .. GameRules.AllHeroes[1]:GetPlayerID(),false)
				SendToServerConsole('dota_create_fake_clients')
				Timers:CreateTimer(function()
					local set = false
					for i = 1, DOTA_MAX_PLAYERS do
						if not set then
							local p = PlayerResource:GetPlayer(i)
							if p then
								Say(nil, "Found " .. i , false)
								local h = CreateHeroForPlayer("npc_dota_hero_invoker",p)
								table.insert(GameRules.AllHeroes, h)
								table.insert(GameRules.AllPlayers, p)
								p:SetTeam(DOTA_TEAM_BADGUYS)
								h:SetTeam(DOTA_TEAM_BADGUYS)
								h:InitDSHeroData()

								GameRules.TurnManager:Init()
								GameRules.TurnManager:SelectFirstActivePlayer()
								GameRules.TurnManager:ShuffleAndDrawInitialCards()
								
								set = true
							end
						end
					end
					
				end)
			else
				GameRules.TurnManager:Init()
				GameRules.TurnManager:SelectFirstActivePlayer()
				GameRules.TurnManager:ShuffleAndDrawInitialCards()
			end
		end)
	end

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print("now game in progress")
		GameRules.TurnManager:Run()
	end
end
