ds_point = class({})

function ds_point:GetCooldown( nLevel )
    return 0
end

function ds_point:OnSpellStart()
    local caster = self:GetCaster()
    local card = caster:GetCurrentActiveCard()
    local point = self:GetCursorPosition()
    local playerid = caster:GetPlayerID()

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

            minion:StartMinionAIThink()

            local abilities = card.data.abilities
            if abilities and TableCount(abilities) > 0 then
                for _, ability in pairs(abilities) do
                    minion:AddAbility(ability)
                    local ab = minion:FindAbilityByName(ability)
                    if not ab then
                        Warning("FATAL: minion ability is not found, ability name =>" .. ability)
                    else
                        ab:SetLevel(1)
                    end
                end
            end

            -- 创建单位的状态面板
            WorldPanels:CreateWorldPanelForAll({
                layout = "file://{resources}/layout/custom_game/worldpanels/minion_state.xml",
                entity = minion,
            })
        end)
    end

    -- 移除手牌
    caster:GetHand():RemoveCard(card)

    -- 清空状态
    caster:SetCurrentActiveCard(nil)

    -- 执行卡牌的效果代码
    card:OnUseCard()

end
