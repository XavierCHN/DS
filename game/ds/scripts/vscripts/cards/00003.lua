module(..., package.seeall)

card_type = CARD_TYPE_ATTRIBUTE
main_attr = ATTRIBUTE_INTELLECT
card_behavior = CARD_BEHAVIOR_NO_TARGET
expansion = 0
cost = {}
prefix_type = {"basic"}
sub_type = {"test"}
artist = "Xavier"
cast_time = CARD_CASTTIME_MY_ROUND

on_spell_start = function(card, ability, args)
	local caster = ability:GetCaster()
	caster:SetAttributeIntellect(caster:GetAttributeIntellect() + 1) -- 获得智力+1
	caster:SetMaxManaPool(caster:GetMaxManaPool() + 1) -- 最大法力值+1
	caster:SetManaPool(caster:GetManaPool() + 1) -- 法力值+1
end
