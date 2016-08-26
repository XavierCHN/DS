ds_no_target = class({})

-- function ds_no_target:GetCustomCastError()
--     if IsServer() then
--         local hero = self:GetCaster()
--         local card = hero:GetCurrentActiveCard()
--         local validated, reason = card:Validate(self)
--         if not validated then
--             return reason
--         end
--         return ""
--     end
-- end

-- function ds_no_target:CastFilterResult()
--     if IsServer() then
--         print "server"
--         local hero = self:GetCaster()
--         local card = hero:GetCurrentActiveCard()
--         local validated, _ = card:Validate(self)
--         if not validated then
--             return UF_FAIL_CUSTOM
--         end
--         return UF_FAIL_CUSTOM
--     end
--     if IsClient() then
--         print "client"
--         return UF_SUCCESS
--     end
-- end

-- function ds_no_target:GetCooldown( nLevel )
--     return 0
-- end

function ds_no_target:OnSpellStart(args)
    if IsServer() then
        print("begin to execute ds_no_target OnSpellStart")
        
        local caster = self:GetCaster()

        for k,v in pairs(caster) do
            print("caster",k,v)
        end

        local card = caster:GetCurrentActiveCard()
        -- 移除手牌
        caster:RemoveCardAfterUse(card:GetUniqueID())

        -- 执行卡牌的效果代码
        local card_func = card.data.on_spell_start
        if card_func and type(card_func) == "function" then
            print(string.format("processing card effect CARDID[%s] -> on_spell_start", card:GetID()))
            card_func(self, args)
        end
    end
end
