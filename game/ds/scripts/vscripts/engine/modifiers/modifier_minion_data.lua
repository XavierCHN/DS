modifier_minion_data = class({})

function modifier_minion_data:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
end

function modifier_minion_data:OnCreated( params )
    if not IsServer() then return end

    local minion = self:GetParent()
    minion.ms = 300
    minion.ar = 128
    self:StartIntervalThink(0.03)
end


function modifier_minion_data:GetModifierMoveSpeedBonus_Constant()
    if not IsServer() then
        return
    end

    local minion = self:GetParent()
    return minion.ms - 300 -- 所有单位的默认移动速度都是300
end

function modifier_minion_data:GetModifierAttackRangeBonus()
    if not IsServer() then
        return
    end
    local minion = self:GetParent()
    return minion.ar - 128 -- 所有单位的默认移动速度都是300
end

function modifier_minion_data:IsHidden()
    return true
end

function modifier_minion_data:IsPurgable()
    return false
end