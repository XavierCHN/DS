if TriggerAbility == nil then TriggerAbility = class({},{__classname__ = "ActiveAbility"}, Ability) end

function TriggerAbility:constructor(args, unit)
	self.owner = unit
	self.event = args.event
	self.on_triggered = args.OnTriggered
	self.uid = DoUniqueString('')
	self.args = args
	self.data_for_client = safe_table(args)
	for k,v in pairs(self.data_for_client) do
		print("Triger ability data for client", k, v)
	end
	self:UpdateToClient()
	GameRules.EventManager:Register(self.event.name, function(args)
		if self.event.condition and self.event.condition(args) then
			self.on_triggered(args)
		end
	end)
	GameRules.AllAbilities[self.uid] = self
end