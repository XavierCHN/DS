function CDOTA_BaseNPC_Hero:InitDSHero()
	self.attribute_int = 0
	self.attribute_agi = 0
	self.attribute_str = 0
	self.mp = 0
	self.mmp = 0

	self:FindAbilityByName('ds_no_target'):SetLevel(1)
	self:FindAbilityByName('ds_point'):SetLevel(1)
	self:FindAbilityByName('ds_single_target'):SetLevel(1)

	self.deck = Deck(self)
	self.hand = Hand(self)
end

function CDOTA_BaseNPC_Hero:GetCardList()
	if IsInToolsMode() then
		return DEBUG_CARD_LIST
	else
		return self.card_list
	end
end

-- 抽指定数量的牌
function CDOTA_BaseNPC_Hero:DrawCard(numCards)
	for i = 1, numCards do
		
		local card = self.deck:Pop()
		if card then
			self.hand:AddCard(card)
		else
			-- 在测试阶段，不因为想要抽牌的时候抽不到牌的规则而输掉比赛
			-- 
			print("todo, no card damage")
		end
	end
end

-- 弃牌
function CDOTA_BaseNPC_Hero:DiscardCard(card)
	self.hand:RemoveCard(card)
end

function CDOTA_BaseNPC_Hero:SetCurrentActivateCard(card)
	self.current_active_card = card
end

function CDOTA_BaseNPC_Hero:GetCurrentActiveCard()
	return self.current_active_card
end

function CDOTA_BaseNPC_Hero:SetHasUsedAttributeCardThisRound(t)
	self.has_used_attribute_card = t
end

function CDOTA_BaseNPC_Hero:HasUsedAttributeCardThisRound()
	return self.has_used_attribute_card
end

function CDOTA_BaseNPC_Hero:FillManaPool()
	self.mp = self.mmp
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetManaPool()
	return self.mp
end

function CDOTA_BaseNPC_Hero:SetManaPool(val)
	if val >= self.mmp then
		self.mp = self.mmp
	else
		self.mp = val
	end
	self:SendDataToAllClients()
	return self.mp
end

function CDOTA_BaseNPC_Hero:GetMaxManaPool()
	return self.mmp
end

function CDOTA_BaseNPC_Hero:SetMaxManaPool(val)
	self:SendDataToAllClients()
	self.mmp = val
end

function CDOTA_BaseNPC_Hero:SetAttributeStrength(val)
	self:SendDataToAllClients()
	self.attribute_str = val
end

function CDOTA_BaseNPC_Hero:GetAttributeStrength()
	return self.attribute_str or 0
end

function CDOTA_BaseNPC_Hero:SetAttributeAgility(val)
	self.attribute_agi = val
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetAttributeAgility()
	return self.attribute_agi or 0
end

function CDOTA_BaseNPC_Hero:SetAttributeIntellect(val)
	self.attribute_int = val
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetAttributeIntellect()
	return self.attribute_int or 0
end

function CDOTA_BaseNPC_Hero:GetHand()
	return self.hand
end

function CDOTA_BaseNPC_Hero:GetDeck()
	return self.deck
end

function CDOTA_BaseNPC_Hero:SetCardList(card_list)
	self.card_list = card_list or {}
end

function CDOTA_BaseNPC_Hero:SendDataToAllClients()
	CustomGameEventManager:Send_ServerToAllClients("ds_hero_data_changed", {
		PlayerID = hero:GetPlayerID(),
		Str = self.attribute_str,
		Agi = self.attribute_agi,
		Int = self.attribute_int,
		Mana = self.mp,
		MaxMana = self.mmp
	})
end

CustomGameEventManager:RegisterListener("ds_client_request_hero_data", function(args)
	local heroes = GameRules.AllHeroes
	for _, hero in pairs(heroes) do
		hero:SendDataToAllClients()
	end
end)