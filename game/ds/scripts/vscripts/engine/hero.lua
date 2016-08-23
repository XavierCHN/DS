function CDOTA_BaseNPC_Hero:GetHand()
	return self.hand
end

function CDOTA_BaseNPC_Hero:GetDeck()
	return self.deck
end

function CDOTA_BaseNPC_Hero:SetDeck(deck)
	self.deck = deck
end

function CDOTA_BaseNPC_Hero:DrawCard(numCards)
	print(string.format("hero %s is about to draw %d cards", self:GetUnitName(), numCards))

	self.hand = self.hand or Hand(self)
	for i = 1, numCards do
		local card = self.deck:Pop()
		numCards = numCards - 1
		if card then
			print(string.format("Draw a card with id %s", card.ID ))
			self.hand:AddCard(card)
		else
			print(" a player want to draw "..numCards.." cards when his deck is empty!")
			-- todo end the game!
		end
	end
end

function CDOTA_BaseNPC_Hero:SetHasUsedAttributeCardThisRound(t)
	self.huactr = t
end

function CDOTA_BaseNPC_Hero:HasUsedAttributeCardThisRound()
	return self.huactr
end

-- 设置手上第index张手牌为正在使用的手牌
function CDOTA_BaseNPC_Hero:SetCurrentActiveCardByIndex(idx)
	self.cacidx = idx
end

function CDOTA_BaseNPC_Hero:GetCurrentActiveCard()
	return self:GetHandByIndex(self.cacidx)
end

function CDOTA_BaseNPC_Hero:GetHandByIndex(idx)
	return self.hand:GetCardByIndex(idx)
end

function CDOTA_BaseNPC_Hero:RemoveCardByIndex(idx)
	self.hand:RemoveCardByIndex(idx)
end

function CDOTA_BaseNPC_Hero:RefreshHand_HL()
	self.hand:RefreshHand_HL()
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

function CDOTA_BaseNPC_Hero:InitDSHeroData()
	self.attribute_int = 0
	self.attribute_agi = 0
	self.attribute_str = 0
	self.mp = 0
	self.mmp = 0
end
