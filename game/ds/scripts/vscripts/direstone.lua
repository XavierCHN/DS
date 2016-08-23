if DS == nil then DS = class({}) end

require 'utility_functions'
require 'settings'

require 'libraries.timers'

require 'engine.turn_manager'
require 'engine.player'

require 'cards.core.core'

function DS:Init()
    -- self.vStack = Stack()

    local mode = GameRules:GetGameModeEntity()

    mode:SetFogOfWarDisabled(true)
    mode:SetCustomGameForceHero("npc_dota_hero_invoker")

    self.mode = mode
    GameRules.mode = mode
    GameRules.GameMode = self

    -- 初始化各种数据结构
    GameRules.TurnManager = TurnManager()
    GameRules.CardInterface = CardInterface()


    GameRules.CardInterface:Start()
    ListenToGameEvent("gamerules_state_change",Dynamic_Wrap(DS, "OnGameRulesStateChanged"),self)

end

function DS:OnGameRulesStateChanged()
	local newState = GameRules:State_Get()

	if newState = DOTA_GAMERULES_STATE_PRE_GAME then
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
					end
				end
			end

			-- 随机选择一名玩家获得先手
			GameRules.TurnManager:Init()
			if RollPercentage(50) then
				GameRules.TurnManager:SetPlayerPriority(GameRules.AllPlayers[1], GameRules.AllPlayers[2])
			else
				GameRules.TurnManager:SetPlayerPriority(GameRules.AllPlayers[2], GameRules.AllPlayers[1])
			end
		end)
	end

	if newState = DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules.TurnManager:Run()
	end
end
