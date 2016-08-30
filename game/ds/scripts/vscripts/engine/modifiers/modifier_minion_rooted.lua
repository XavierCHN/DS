modifier_minion_rooted = class({})

function modifier_minion_rooted:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_minion_rooted:IsHidden()
    return true
end

function modifier_minion_rooted:IsPurgable()
    return false
end