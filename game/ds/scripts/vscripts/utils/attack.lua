function UnitCanAttackTarget(unit, target)
    if unit:IsRangedAttacker() and unit:IsTargetOnNeighborLine(target) then
        return true
    end
    if not unit:IsRangedAttacker() and (not target:HasFlyMovementCapability()) and unit:IsTargetOnSameLine(target) then
        return true
    end
end

function AggroFilter( unit )
    local target = unit:GetAttackTarget() or unit:GetAggroTarget()
    if target then
        local bCanAttackTarget = UnitCanAttackTarget(unit, target)
        if target ~= unit.attack_target then
            if bCanAttackTarget then
                unit.attack_target = target
                return true
            else
                local enemies = FindEnemiesInRadius(unit, unit:GetAcquisitionRange())
                if #enemies > 0 then
                    for _,enemy in pairs(enemies) do
                        if UnitCanAttackTarget(unit, enemy) then
                            Attack(unit, enemy)
                            return true
                        end
                    end
                end

                if #enemies <= 0 then
                    unit:DisableAutoAttack()
                    return false
                end
            end
            return true
        end
    end
    return false
end

function Attack( unit, target )
    unit:MoveToTargetToAttack(target)
    unit.attack_target = target
    unit:EnableAutoAttack()
end