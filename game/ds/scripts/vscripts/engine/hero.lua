function CDOTA_BaseNPC_Hero:InitDSHero()
	self.attribute_int = 0
	self.attribute_agi = 0
	self.attribute_str = 0
	self.mp = 0
	self.mmp = 0

	self:FindAbilityByName('ds_no_target'):SetLevel(1)
	self:FindAbilityByName('ds_point'):SetLevel(1)
	self:FindAbilityByName('ds_single_target'):SetLevel(1)

	self.hand = Hand(self)
	self.deck = Deck(self)
	self.graveyard = GraveYard(self)
end

function CDOTA_BaseNPC_Hero:DrawCard(numCards)
	for i = 1, numCards do
		local card = self.deck:Pop()
		numCards = numCards - 1
		if card then
			self:MoveCardInto(card, self.hand)
			GameRules.EventManager:Emit("OnPlayerDrawCard", {
				Player = self,
				CardID = card:GetID(),
				Card = card,
			})
		else
			-- 在测试阶段，不因为想要抽牌的时候抽不到牌的规则而输掉比赛
			if not IsInToolsMode() then
				GameRules.DS:EndGameWithLoser(self)
			end
		end
	end
end

function CDOTA_BaseNPC_Hero:MoveCardInto(card, destination)
	destination:AddCard(card)
end

function CDOTA_BaseNPC_Hero:SetHasUsedAttributeCardThisRound(t)
	self.has_used_attribute_card = t
end

function CDOTA_BaseNPC_Hero:HasUsedAttributeCardThisRound()
	return self.has_used_attribute_card
end

function CDOTA_BaseNPC_Hero:SetCurrentActivateCardByUniqueId(uniqueId)
	self.hdi = uniqueId
end

function CDOTA_BaseNPC_Hero:GetCurrentActiveCard()
	return self:GetHandByUniqueId(self.hdi)
end

function CDOTA_BaseNPC_Hero:GetHandByUniqueId( uniqueId )
	return self.hand:GetCardByUniqueId(uniqueId)
end

function CDOTA_BaseNPC_Hero:RemoveCardByUniqueId( uniqueId )
	self.hand:RemoveCardByUniqueId(uniqueId)
end

-- 使用牌后移除
function CDOTA_BaseNPC_Hero:RemoveCardAfterUse( uniqueId )
	
	--====================================================
	-- todo 更新卡牌进入战场的逻辑
	--====================================================
	
	local card = self.hand:GetCardByUniqueId(uniqueId)
	GameRules.EventManager:Emit("OnPlayerUsedCard",{
		Player = self,
		CardID = card:GetID(),
		Index = idx,
		Card = card,
	})
	self:RemoveCardByUniqueId( uniqueId )
end

-- 弃牌
function CDOTA_BaseNPC_Hero:DiscardCard(uniqueId)
	
	local card = self.hand:GetCardByUniqueId(uniqueId)

	GameRules.EventManager:Emit("OnPlayerDiscardCard",{
		Player = self,
		CardID = card:GetID(),
		Index = idx,
		Card = card,
	})

	self:RemoveCardByUniqueId( uniqueId )
end

function CDOTA_BaseNPC_Hero:FillManaPool()
	self.mp = self.mmp
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
end

function CDOTA_BaseNPC_Hero:GetMaxManaPool()
	return self.mmp
end

function CDOTA_BaseNPC_Hero:SetMaxManaPool(val)
	self.mmp = val
end

function CDOTA_BaseNPC_Hero:SetAttributeStrength(val)
	self.attribute_str = val
end

function CDOTA_BaseNPC_Hero:GetAttributeStrength()
	return self.attribute_str or 0
end

function CDOTA_BaseNPC_Hero:SetAttributeAgility(val)
	self.attribute_agi = val
end

function CDOTA_BaseNPC_Hero:GetAttributeAgility()
	return self.attribute_agi or 0
end

function CDOTA_BaseNPC_Hero:SetAttributeIntellect(val)
	self.attribute_int = val
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