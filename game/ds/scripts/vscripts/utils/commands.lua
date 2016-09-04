-- if GameRules.CommandRegistered or not IsInToolsMode() then return end
-- GameRules.CommandRegistered = true

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

Convars:RegisterCommand("debug_set_hero_attribute", function(_, str, agi, int, mana)
	local client = Convars:GetCommandClient()
	local hero = PlayerResource:GetPlayer(client:GetPlayerID()):GetAssignedHero()

	hero:SetAttributeStrength(tonumber(str))
	hero:SetAttributeAgility(tonumber(agi))
	hero:SetAttributeIntellect(tonumber(int))
	hero:SetMaxManaPool(tonumber(mana))
	hero:FillManaPool()
end, "debug set hero attribute", FCVAR_CHEAT);

Convars:RegisterCommand("debug_refresh_hand_data", function()
	local client = Convars:GetCommandClient()
	local hero = PlayerResource:GetPlayer(client:GetPlayerID()):GetAssignedHero()

	local hand = hero:GetHand()
	for _, card in pairs(hand.cards) do
		card:UpdateToClient()
	end
end, "", FCVAR_CHEAT)