ds_point = class({})

function ds_point:GetCustomCastErrorLocation(vLocation)
    local hero = self:GetCaster()
    local card = hero:GetCurrentActiveCard()
    local validated, reason = card:Validate(self, vLocation)
    if not validated then
        return reason
    end

    return ""
end

function ds_point:CastFilterResultLocation(vLocation)
	local hero = self:GetCaster()
    local card = hero:GetCurrentActiveCard()
    local validated, _ = card:Validate(self, vLocation)
    if not validated then
        return UF_FAIL_CUSTOM
    end
end

function ds_point:GetCooldown( nLevel )
    return 0
end

function ds_point:OnSpellStart(args)
    local caster = self:GetCaster()
    local card = caster:GetCurrentActiveCard()
    

    if card:GetType() == CARD_TYPE_MINION then
        CreateCardMinion(card, args.target_points[1], caster, caster:GetPlayerOwner(), caster:GetTeamNumber(), function(minion)
            local atk = card.data.atk
            local hp  = card.data.hp
            minion:SetBaseDamageMax(atk)
            minion:SetBaseDamageMin(atk)
            minion:SetBaseMaxHealth(hp)
            minion:SetHealth(hp)
            minion.ms = card.data.move_speed
            minion.ar = card.data.attack_range
        end)
    end

    -- 执行卡牌的效果代码
    local card_func = card.data.on_spell_start
    if card_func and type(card_func) == "function" then
        print(string.format("processing card effect CARDID[%s] -> on_spell_start", card:GetID()))
        card_func(args)
    end

    -- 移除手牌
    caster:RemoveCardAfterUse(card:GetUniqueId())
end
