if TriggerAbility == nil then TriggerAbility = class({},{__classname__ = "ActiveAbility"}, Ability) end

function TriggerAbility:constructor(args, unit)
	self.event = args.event
	self.on_triggered = args.OnTriggered
	self.owner = unit
	self.uid = DoUniqueString()
	GameRules.AllAbilities[self.uid] = self

	self:UpdateToClient()

	GameRules.EventManager:Register(self.event.name, function(args)
		if self.event.condition and self.event.condition(args) then
			self.on_triggered(args)
		end
	end)
end