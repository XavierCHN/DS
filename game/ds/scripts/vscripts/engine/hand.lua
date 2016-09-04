if Hand == nil then Hand = class({}) end

function Hand:constructor(player)
    self.cards = {}
    self.player = player
    self.playerid = self.player:GetPlayerID()

    PlayerTables:CreateTable("hand_cards_" .. self.playerid, {}, {self.playerid})

    -- 启动计时器刷新高亮状态
    Timers:CreateTimer(function()
        if TableCount(self.cards) > 0 then
            for _, card in pairs(self.cards) do
                card:UpdateHighLightState()
            end
        end
        return 0.03
    end)
end

function Hand:AddCard(card)
    if self:GetCardCount() >= 10 then
        print("an hero trying to add card to hand when hand is full")
        CustomGameEventManager:Send_ServerToAllClients("ds_player_hand_full", {
            PlayerID = self.player:GetPlayerID(),
            CardID = card:GetID(),
            CardUniqueID = card:GetUniqueID(),
        })
    else
        table.insert(self.cards, card)
    end
    self:UpdateToClient()
end

function Hand:UpdateToClient()

    for _, card in pairs(self.cards) do
        card:UpdateToClient()
    end

    local serialized_data = {}
    for idx, card in pairs(self.cards) do
        local card_data = {}
        card_data.id = card:GetID()
        card_data.unique_id = card:GetUniqueID()
        serialized_data[idx] = JSON:encode(card_data)
    end

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.playerid), "ds_player_hand_changed", serialized_data)

    CustomGameEventManager:Send_ServerToAllClients("ds_player_hand_count_changed", {
        PlayerID = self.player:GetPlayerID(),
        Count = TableCount(self.cards),
    })
end

function Hand:Clear()
    self.cards = {}
    self:UpdateToClient()
end

function Hand:GetCardByUniqueId(uniqueId)
    return self.cards[uniqueId]
end

function Hand:RemoveCard(card)
    for k, _card in pairs(self.cards) do
        if _card == card then
            table.remove(self.cards, k)
            break 
        end
    end
    self:UpdateToClient()
end

function Hand:GetCardCount()
    return TableCount(self.cards)
end

-- 根据手牌ID弃掉一张手牌
function Hand:RemoveCardByUniqueId(uniqueId)
    GameRules.EventManager:Emit("OnPlayerLoseHandCard", {
        Card = self.cards[uniqueId],
        Player = self.player
    })
    -- self.cards[uniqueId] = nil
    local card_to_drop = self.cards[uniqueId]
    self:RemoveCard(card_to_drop)
    self:UpdateToClient()
end

-- 随机弃掉N张手牌
function Hand:RemoveRandomCard(count)
    count = count or 1
    local random_cards = {}
    for i = 1, count do
        local uniqueIds = {}
        for uniqueId,_ in pairs(self.cards) do
            table.insert(uniqueIds, uniqueId)
        end
        local card_to_drop = self.cards[uniqueIds[RandomInt(1,#uniqueIds)]]
        self:RemoveCard(card_to_drop)
    end
    self:UpdateToClient()
end

-- 手牌调度
function Hand:Mulligan()
    local mulligan_count = self:GetCardCount() - 1
    if mulligan_count > -1 then -- 哪怕只有一张！ 我也不要！
        self.player:GetSelector():Create({
            type = SELECTOR_YESNO,
            title = "#selector_tooltip_confirm_mulligan",
            title_args = {CardCount = mulligan_count},
            callback = function(result)
                if result == "yes" then
                    -- 重新调度手牌
                    local hand = self.player:GetHand()
                    local deck = self.player:GetDeck()
                    for _, card in pairs(hand.cards) do
                        deck:AddCard(card)
                    end
                    hand:Clear()
                    deck:Shuffle()
                    self.player:DrawCard(mulligan_count) -- 少抽一张牌
                    self:Mulligan()
                else
                    GameRules.TurnManager:SetPreparedFinished(self.player)
                end
            end,
        })
    else
        -- 最后一张也丢掉了，没得调度了，设置为准备好了
        GameRules.TurnManager:SetPreparedFinished(self.player)
    end
end