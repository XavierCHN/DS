ds_no_target = class({})


function ds_no_target:OnSpellStart(args)
    if IsServer() then
        print("begin to execute ds_no_target OnSpellStart")
        local caster = self:GetCaster()
        local playerid = caster:GetPlayerID()
        local card = caster:GetCurrentActiveCard()
        
        -- 调用 core/card.lua验证是否满足使用需求
        local success, reason = card:Validate(self, args)
        if not success then
            EmitSoundOnClient("General.CastFail_AbilityNotLearned", PlayerResource:GetPlayer(playerid))
            Notifications:Bottom(playerid,{text= reason, duration=1, style={color="red";["font-size"] = "30px"}})
            return
        end
        
        -- 移除手牌
        caster:RemoveCardAfterUse(card:GetUniqueID())

        -- 调用 core/card.lua执行卡牌的效果代码
        card:OnUseCard(self, args)
    end
end
