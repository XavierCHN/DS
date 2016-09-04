if ActiveAbility == nil then ActiveAbility = class({}, {__classname__ = "ActiveAbility"}, Ability) end

function ActiveAbility:constructor(args, unit)
	print("args.OnActive", args.OnActive)
	self.owner = unit
	self.uid = DoUniqueString('')
	GameRules.AllAbilities[self.uid] = self
	self.on_active = args.OnActive
	self.cost = args.cost
	self.timing = args.timing
	self.args = args
	self.data_for_client = safe_table(args)
	GameRules.AllAbilities[self.uid] = self
	self:UpdateToClient()
end	

function ActiveAbility:OnActive()
	local cost = self.cost
	local timing = self.timing

	local hero = self.owner.player or self.owner
	local meet, reason = hero:HasEnough(cost)
	if not meet then
		ShowError(hero:GetPlayerID(), reason)
		return
	end

	meet, reason = GameRules.TurnManager:IsMeetTimingRequirement(hero, timing)
	if not meet then
		ShowError(hero:GetPlayerID(), reason)
		return
	end

	self.on_active(self.owner)
end