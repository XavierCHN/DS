module(..., package.seeall)

-- 力量属性卡，使施法者获得一点力量和一点魔法
card_type = CARD_TYPE_ATTRIBUTE
card_behavior = CARD_BEHAVIOR_NO_TARGET
expansion = 0
cost = {}

on_spell_start = function(self)
	local caster = self:GetCaster()
	caster:SetAttributeStrength(caster:GetAttributeStrength() + 1)
	caster:SetMaxManaPool(caster:GetMaxManaPool() + 1)
	caster:SetManaPool(caster:GetManaPool() + 1)
end
