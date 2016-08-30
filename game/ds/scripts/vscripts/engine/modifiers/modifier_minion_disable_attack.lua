modifier_minion_disable_attack = class({})

function modifier_minion_disable_attack:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_minion_disable_attack:IsHidden()
    return true
end

function modifier_minion_disable_attack:IsPurgable()
    return false
end