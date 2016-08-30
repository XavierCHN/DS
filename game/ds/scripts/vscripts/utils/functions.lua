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