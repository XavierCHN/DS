if ActiveAbility == nil then ActiveAbility = class({}, {__classname__ = "ActiveAbility"}, Ability) end

function ActiveAbility:constructor(args, unit)
	self.uid = DoUniqueString('')
	GameRules.AllAbilities[self.uid] = self
	self.owner = unit
	self.on_active = args.OnActive or function() end
	self.cost = args.cost
	self.timing = args.timing
	self:UpdateToClient()
end

function ActiveAbility:OnActive()
	local cost = self.cost
	local timing = self.timing

	local hero = self.owner.player or self.owner
	local meet, reason = hero:HasEnough(cost)
	if not meet then
		ShowError(hero:GetPlayeriD(), reason)
		return
	end

	meet, reason = GameRules.TurnManager:IsMeetTimingRequirement(hero, timing)
	if not meet then
		ShowError(hero:GetPlayerID(), reason)
		return
	end

	self.on_active(self.owner)
end