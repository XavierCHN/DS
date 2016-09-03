-- Thanks MNoya for this, credits to https://github.com/MNoya

-- Shortcut for a very common check
function IsValidAlive( unit )
    return (IsValidEntity(unit) and unit:IsAlive())
end

-- Auxiliar function that goes through every ability and item, checking for any ability being channelled
function IsChanneling ( unit )
    
    for abilitySlot=0,15 do
        local ability = unit:GetAbilityByIndex(abilitySlot)
        if ability and ability:IsChanneling() then 
            return ability
        end
    end

    for itemSlot=0,5 do
        local item = unit:GetItemInSlot(itemSlot)
        if item and item:IsChanneling() then
            return ability
        end
    end

    return false
end

-- Returns all visible enemies in radius of the unit/point
function FindEnemiesInRadius( unit, radius, point )
    local team = unit:GetTeamNumber()
    local position = point or unit:GetAbsOrigin()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
    return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, target_type, flags, FIND_CLOSEST, false)
end

-- Returns all units (friendly and enemy) in radius of the unit/point
function FindAllUnitsInRadius( unit, radius, point )
    local team = unit:GetTeamNumber()
    local position = point or unit:GetAbsOrigin()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, target_type, flags, FIND_ANY_ORDER, false)
end

-- Returns all units in radius of a point
function FindAllUnitsAroundPoint( unit, point, radius )
    local team = unit:GetTeamNumber()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    return FindUnitsInRadius(team, point, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, target_type, flags, FIND_ANY_ORDER, false)
end

function FindAlliesInRadius( unit, radius, point )
    local team = unit:GetTeamNumber()
    local position = point or unit:GetAbsOrigin()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, target_type, flags, FIND_CLOSEST, false)
end

-- Filters buildings and mechanical units
function FindOrganicAlliesInRadius( unit, radius, point )
    local team = unit:GetTeamNumber()
    local position = point or unit:GetAbsOrigin()
    local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    local allies = FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, target_type, flags, FIND_CLOSEST, false)
    local organic_allies = {}
    for _,ally in pairs(allies) do
        if not IsCustomBuilding(ally) and not ally:IsWard() and not ally:IsMechanical() then
            table.insert(organic_allies, ally)
        end
    end
    return organic_allies
end

-- Returns the first unit that passes the filter
function FindFirstUnit(list, filter)
    for _,unit in ipairs(list) do
        if filter(unit) then
            return unit
        end
    end
end

function ReplaceUnit( unit, new_unit_name )
    --print("Replacing "..unit:GetUnitName().." with "..new_unit_name)

    local hero = unit:GetOwner()
    local playerID = hero:GetPlayerOwnerID()

    local position = unit:GetAbsOrigin()
    local relative_health = unit:GetHealthPercent() * 0.01
    local fv = unit:GetForwardVector()
    local new_unit = CreateUnitByName(new_unit_name, position, true, hero, hero, hero:GetTeamNumber())
    new_unit:SetOwner(hero)
    new_unit:SetControllableByPlayer(playerID, true)
    new_unit:SetHealth(new_unit:GetMaxHealth() * relative_health)
    new_unit:SetForwardVector(fv)
    FindClearSpaceForUnit(new_unit, position, true)

    if PlayerResource:IsUnitSelected(playerID, unit) then
        PlayerResource:AddToSelection(playerID, new_unit)
    end

    -- Add the new unit to the player units
    Players:AddUnit(playerID, new_unit)

    -- Remove replaced unit from the game
    Players:RemoveUnit(playerID, unit)
    unit:RemoveSelf()

    return new_unit
end

function FindAttackableEnemies( unit )
    local radius = unit:GetAcquisitionRange()
    if not radius then return end
    local enemies = FindEnemiesInRadius( unit, radius )
    for _,target in pairs(enemies) do
        if unit:CanAttackTarget(target) and not target:HasModifier("modifier_invisible") then
            return target
        end
    end
    return nil
end
