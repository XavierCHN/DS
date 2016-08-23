-- 抽牌
function CDOTA_Player:DrawCard(numCards)
	print(string.format("player %d is about to draw %d cards", self:GetPlayerID(), numCards))
end

function CDOTA_Player:FillManaPool()
	self:GetAssignedHero():SetManaPool(self:GetAssignedHero():GetMaxManaPool())
end

function CDOTA_Player:GetManaPool()
	return self:GetAssignedHero():GetManaPool()
end

function CDOTA_Player:SetManaPool(val)
	self:GetAssignedHero():SetManaPool(val)
end

function CDOTA_Player:GetMaxManaPool()
	return self:GetAssignedHero():GetMaxManaPool()
end

function CDOTA_Player:SetMaxManaPool(val)
	self:GetAssignedHero():SetMaxManaPool(val)
end

function CDOTA_Player:SetHasUsedAttributeCardThisRound(t)
	self:GetAssignedHero():SetHasUsedAttributeCardThisRound(t)
end

function CDOTA_Player:HasUsedAttributeCardThisRound()
	return self:GetAssignedHero():HasUsedAttributeCardThisRound()
end