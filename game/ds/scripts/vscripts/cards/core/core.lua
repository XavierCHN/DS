require 'cards.core.settings'
require 'cards.core.enums'
require 'cards.core.card'

-- 卡牌交互类
if CardCore == nil then
    _G.CardCore = class({})
end

function CardCore:Start()
    CustomGameEventManager:RegisterListener("ds_player_click_card",Dynamic_Wrap(CardCore, "OnPlayerUsedCard"))
    self.activeCardID = {}

    GameRules.CardHighLight = {}
    
end

function CardCore:OnPlayerClickCard(args)
    local playerID = args.PlayerID
    local idx = args.CardIndex
    local player = PlayerResource:GetPlayer(playerID)
    local hero = player:GetAssignedHero()

    -- 设置当前使用的手牌
    hero:SetCurrentActiveCardByIndex(idx)

    local card = hero:GetCurrentActiveCard()
    local ccb = card:GetCardBehavior()

    CustomGameEventManager:Send_ServerToPlayer(player,"ds_execute_card_proxy",{
        behavior = ccb,
    })
end
