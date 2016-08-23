-- 抽牌
function CDOTAPlayer:DrawCard(numCards)
	self:GetAssignedHero():DrawCard(numCards)
end

function CDOTAPlayer:FillManaPool()
	self:GetAssignedHero():SetManaPool(self:GetAssignedHero():GetMaxManaPool())
end

function CDOTAPlayer:GetManaPool()
	return self:GetAssignedHero():GetManaPool()
end

function CDOTAPlayer:SetManaPool(val)
	self:GetAssignedHero():SetManaPool(val)
end

function CDOTAPlayer:GetMaxManaPool()
	return self:GetAssignedHero():GetMaxManaPool()
end

function CDOTAPlayer:SetMaxManaPool(val)
	self:GetAssignedHero():SetMaxManaPool(val)
end

function CDOTAPlayer:SetHasUsedAttributeCardThisRound(t)
	self:GetAssignedHero():SetHasUsedAttributeCardThisRound(t)
end

function CDOTAPlayer:HasUsedAttributeCardThisRound()
	return self:GetAssignedHero():HasUsedAttributeCardThisRound()
end
