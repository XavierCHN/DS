module(..., package.seeall)

card_type = CARD_TYPE_ATTRIBUTE
main_attr = ATTRIBUTE_AGILITY
card_behavior = CARD_BEHAVIOR_NO_TARGET

expansion = 0
cost = {}
prefix_type = {"basic"}
artist = "Xavier"

Effect = function(args)
	local caster = args.caster
	caster:SetAttributeAgility(caster:GetAttributeAgility() + 1) -- 获得敏捷+1
	caster:SetMaxManaPool(caster:GetMaxManaPool() + 1) -- 最大法力值+1
	caster:SetManaPool(caster:GetManaPool() + 1) -- 法力值+1
end
