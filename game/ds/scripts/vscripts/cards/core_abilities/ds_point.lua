ds_point = class({})

function ds_point:GetCooldown( nLevel )
    return 0
end

function ds_point:OnSpellStart(args)
    local caster = self:GetCaster()
    local card = caster:GetCurrentActiveCard()
    local point = args.target_points[1]

    local validated, reason = card:Validate(self, point)
    if not validated then
        EmitSoundOnClient("General.CastFail_AbilityNotLearned", PlayerResource:GetPlayer(playerid))
        Notifications:Bottom(playerid,{text= reason, duration=1, style={color="red";["font-size"] = "30px"}})
        return
    end

    if card:GetType() == CARD_TYPE_MINION then
        caster:CreateCardMinion(card, point, function(minion)
            local atk = card.data.atk
            local hp  = card.data.hp
            minion:SetBaseDamageMax(atk)
            minion:SetBaseDamageMin(atk)
            minion:SetBaseMaxHealth(hp)
            minion:SetHealth(hp)
            minion.ms = card.data.move_speed
            minion.ar = card.data.attack_range

            local abilities = card.data.abilities
            if abilities and TableCount(abilities) > 0 then
                for _, ability in pairs(abilities) do
                    minion:AddAbility(ability):SetLevel(1)
                end
            end

            -- 创建单位的状态面板
            WorldPanels:CreateWorldPanelForAll({
                layout = "file://{resources}/layout/custom_game/worldpanels/minion_state.xml",
                entity = minion,
            })
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
