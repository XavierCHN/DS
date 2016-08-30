modifier_minion_autoattack = class({})

function modifier_minion_autoattack:DeclareFunctions()
    return { MODIFIER_PROPERTY_DISABLE_AUTOATTACK, }
end

function modifier_minion_autoattack:OnCreated( params )
    if not IsServer() then return end

    local unit = self:GetParent()
    unit.attack_target = nil
    unit.disable_autoattack = 0
    self:StartIntervalThink(0.03)
end

function modifier_minion_autoattack:GetDisableAutoAttack( params )
    local bDisabled = self:GetParent().disable_autoattack

    if bDisabled == 1 then
        if not self.thinking then
            self.thinking = true
            self:StartIntervalThink(0.1)
        end
    elseif self.thinking then
        self.thinking = false
        self:StartIntervalThink(0.03)
    end

    return bDisabled
end

function modifier_minion_autoattack:OnIntervalThink()
    local unit = self:GetParent()
    
    if unit.disable_autoattack == 1 then
        local enemies = FindEnemiesInRadius(unit, unit:GetAcquisitionRange())
        if #enemies > 0 then
            for _,enemy in pairs(enemies) do
                if unit:CanAttack(enemy) then
                    unit:MoveToTargetToAttack(enemy)
                    unit.attack_target = enemy
                    unit.disable_autoattack = 0
                    return
                end
            end
        end
    end
end

function modifier_minion_autoattack:IsHidden()
    return true
end

function modifier_minion_autoattack:IsPurgable()
    return false
end
