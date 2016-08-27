require 'cards.core.settings'
require 'cards.core.enums'

-- 卡牌交互类
if CardCore == nil then
    _G.CardCore = class({})
end

function CardCore:Start()
    CustomGameEventManager:RegisterListener("ds_player_click_card",Dynamic_Wrap(CardCore, "OnPlayerClickCard"))
end

function CardCore:OnPlayerClickCard(args)
    local playerID = args.PlayerID
    local player = PlayerResource:GetPlayer(playerID)
    local hero = player:GetAssignedHero()
    local uniqueId = args.UniqueId

    -- 设置当前使用的手牌
    hero:SetCurrentActivateCardByUniqueId(uniqueId)

    local card = hero:GetCurrentActiveCard()
    local ccb = card:GetCardBehavior()

    CustomGameEventManager:Send_ServerToPlayer(player,"ds_execute_card_proxy",{
        behavior = ccb,
    })
end
