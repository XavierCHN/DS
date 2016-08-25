LinkLuaModifier("ds_flying", "cards/card_effects/general/ds_flying.lua", LUA_MODIFIER_MOTION_NONE)

ds_flying = class({})

function ds_flying:GetIntrinsicModifierName()
    return "ds_flying_modifier"
end