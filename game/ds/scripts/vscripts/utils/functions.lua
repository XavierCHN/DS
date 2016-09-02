function TableCount(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    return c
end

function GetCardByUniqueID(uid)
    return GameRules.AllCreatedCards[uid]
end

function ShowError(playerid, msg)
    EmitSoundOnClient("General.CastFail_AbilityNotLearned", PlayerResource:GetPlayer(playerid))
    Notifications:Bottom(playerid,{text= msg, duration=1, style={color="red";["font-size"] = "30px"}})
end

function GetAbilityByUniqueID(uid)
	return GameRules.AllAbilities[uid]
end