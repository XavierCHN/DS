if StaticAbility == nil then StaticAbility = class({}, {__classname__ = "ActiveAbility"}, Ability) end

function StaticAbility:constructor(args, unit)
	self.uid = DoUniqueString('')
	GameRules.AllAbilities[self.uid] = self
	self.args = args

	self.data_for_client = safe_table(args)

	unit:AddNewModifier(self.owner,nil,args.ModifierName,args.ModifierData)
	
	self:UpdateToClient()
	GameRules.AllAbilities[self.uid] = self
end

