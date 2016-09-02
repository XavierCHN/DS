if StaticAbility == nil then StaticAbility = class({}, {__classname__ = "ActiveAbility"}, Ability) end

function StaticAbility:constructor(args, unit)
	self.owner = unit
	self.uid = DoUniqueString('')
	GameRules.AllAbilities[self.uid] = self

	unit:AddNewModifier(self.owner,nil,args.ModifierName,args.ModifierData)

	self:UpdateToClient()
end

