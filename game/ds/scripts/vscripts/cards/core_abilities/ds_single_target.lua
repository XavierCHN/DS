ds_single_target = class({})

function ds_single_target:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local card = caster:GetCurrentActiveCard()
    
    local validated, reason = card:Validate(self, target)
    if not validated then
        EmitSoundOnClient("General.CastFail_AbilityNotLearned", PlayerResource:GetPlayer(playerid))
        Notifications:Bottom(playerid,{text= reason, duration=1, style={color="red";["font-size"] = "30px"}})
        return
    end

    -- 执行卡牌的效果代码
    card:OnUseCard()

    -- 清空状态
    caster:SetCurrentActiveCard(nil)
    
    -- 移除手牌
    caster:GetHand():RemoveCard(card)
end
