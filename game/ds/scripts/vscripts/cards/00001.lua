module(..., package.seeall)

-- 力量属性卡，使施法者获得一点力量和一点魔法
card_type = CARD_TYPE_ATTRIBUTE
card_behavior = CARD_BEHAVIOR_NO_TARGET
expansion = 0
cost = {}
prefix_type = {"basic"}
sub_type = {"test"}
artist = "Xavier"
abilities = {
	"ds_flying",
	"ds_lifesteal",
}
on_spell_start = function(self, args)
	local caster = self:GetCaster()
	print("caster:GetAttributeStrength()0",caster:GetAttributeStrength())
	caster:SetAttributeStrength(caster:GetAttributeStrength() + 1)
	caster:SetMaxManaPool(caster:GetMaxManaPool() + 1)
	caster:SetManaPool(caster:GetManaPool() + 1)
end
