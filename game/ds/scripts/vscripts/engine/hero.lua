-- 抽牌
function CDOTA_BaseNPC_Hero:DrawCard(numCards)
	print(string.format("hero %s is about to draw %d cards", self:GetUnitName(), numCards))

	self.hand = self.hand or {}
	local card = self.deck:Pop()
	print(string.format("Draw a card with id %s", card.ID ))
	table.insert(self.hand, card)
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

function CDOTA_BaseNPC_Hero:SetHasUsedAttributeCardThisRound(t)
	self.huactr = t
end

function CDOTA_BaseNPC_Hero:HasUsedAttributeCardThisRound()
	return self.huactr
end

-- 设置手上第index张手牌为正在使用的手牌
function CDOTA_BaseNPC_Hero:SetCurrentActiveCard(idx)
	self.cacidx = idx
end

function CDOTA_BaseNPC_Hero:GetCurrentActiveCard()
	return self:GetHandByIndex(self.cacidx)
end

function CDOTA_BaseNPC_Hero:GetHandByIndex(idx)
	return self.hand[idx]
end