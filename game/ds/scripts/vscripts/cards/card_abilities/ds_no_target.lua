ds_no_target = class({})

function ds_no_target:GetCustomCastError()
    local hero = self:GetCaster()
    local card = hero:GetCurrentActiveCard()
    local validated, reason = card:Validate(self)
    if not validated then
        return reason
    end

    return ""
end

function ds_no_target:CastFilterResult()
	local hero = self:GetCaster()
    local card = hero:GetCurrentActiveCard()
    local validated, _ = card:Validate(self)
    if not validated then
        return UF_FAIL_CUSTOM
    end
end
