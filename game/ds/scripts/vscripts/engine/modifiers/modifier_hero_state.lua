modifier_hero_state = class({})

-- 无法移动
function modifier_hero_state:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_hero_state:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
    }
end

-- 忽视施法角度
function modifier_hero_state:GetModifierIgnoreCastAngle()
    return true
end

function modifier_hero_state:IsHidden()
    return false
end

function modifier_hero_state:IsPurgable()
    return false
end