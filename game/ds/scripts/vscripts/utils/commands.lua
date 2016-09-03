if GameRules.CommandRegistered then return end
GameRules.CommandRegistered = true

Convars:RegisterCommand("debug_force_phase_end", function()
	GameRules.TurnManager.current_turn:EndPhase()
end, "" , FCVAR_CHEAT)

Convars:RegisterCommand("debug_add_card",function(_, id)

	local client = Convars:GetCommandClient()
	local hero = client:GetAssignedHero()
    print("trying to add card to player", id, hero:GetPlayerID())
	local hand = hero:GetHand()
	local card = Card(tonumber(id))
	card:SetOwner(hero)
	hand:AddCard(card)
end,"debug add a card to a player's hand",FCVAR_CHEAT)

Convars:RegisterCommand("debug_clear_hand",function(_, id)
    local client = Convars:GetCommandClient()
    local hero = client:GetAssignedHero()
    local hand = hero:GetHand()
    hand:Clear()
end,"debug add a card to a player's hand",FCVAR_CHEAT)

Convars:RegisterCommand("debug_force_card_validate", function()
    GameRules.FORCE_VALIDATE = true
end, "  ", FCVAR_CHEAT)

Convars:RegisterCommand("debug_disable_card_validate", function()
    GameRules.FORCE_VALIDATE = false
end, "  ", FCVAR_CHEAT)