module(..., package.seeall)

card_behavior = CARD_BEHAVIOR_NO_TARGET
cast_time = CARD_CASTTIME_MY_ROUND

card_type = CARD_TYPE_ATTRIBUTE
main_attr = ATTRIBUTE_STRENGTH
expansion = 0
cost = {}
prefix_type = {"basic"}
artist = "Xavier"

-- 卡牌执行的效果
effect = function(card, ability, args)
	local caster = ability:GetCaster()
	caster:SetAttributeStrength(caster:GetAttributeStrength() + 1) -- 获得力量+1
	caster:SetMaxManaPool(caster:GetMaxManaPool() + 1) -- 最大法力值+1
	caster:SetManaPool(caster:GetManaPool() + 1) -- 法力值+1
end
