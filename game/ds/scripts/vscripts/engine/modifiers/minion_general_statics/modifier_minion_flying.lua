modifier_minion_flying = class({})

function modifier_minion_flying:CheckState()
	return {
		[MODIFIER_STATE_FLYING] = true
	}
end