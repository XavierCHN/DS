module(..., package.seeall)

card_type = CARD_TYPE_ATTRIBUTE
main_attr = ATTRIBUTE_STRENGTH
expansion = 2
cost = {}
prefix_type = {"basic"}
artist = "Xavier"

-- 卡牌执行的效果
Effect = function(args)
	local caster = args.caster
	caster:SetAttributeStrength(caster:GetAttributeStrength() + 1) -- 获得力量+1
	caster:SetMaxManaPool(caster:GetMaxManaPool() + 1) -- 最大法力值+1
	caster:SetManaPool(caster:GetManaPool() + 1) -- 法力值+1
end