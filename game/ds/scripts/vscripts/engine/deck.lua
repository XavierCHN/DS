if Deck == nil then Deck = class({}) end

function Deck:constructor(player)
    self.cards = {}
    self.player = player
    local card_list = self.player:GetCardList()
    for _, card in pairs(card_list) do
        for i =1, card.cc do
            -- 卡牌的创建入口 
            local card = Card(card.id)
            card:SetOwner(player) -- 初始化设置卡牌的所有者
            card:SetPosition(self) -- 初始化设置卡牌的位置为玩家的套牌
            self:AddCard(card)
        end
    end
end

-- 洗牌
function Deck:Shuffle()
    local cc = #self.cards
    for i = 1, cc do
        local r = RandomInt(1,cc)
        if self.cards[i] and self.cards[r] then
            self.cards[i] = self.cards[r]
        else
            print("something wrong happened while shuffling deck", i, r)
        end
    end
end

-- 抽出最上一张卡并返回他，把他从套牌中移除
function Deck:GetFirstCard()
    return self.cards[1]
end

function Deck:AddCard(card)
    table.insert(self.cards, card)

    self:UpdateToClient()
end

-- 更新套牌数据到客户端
function Deck:UpdateToClient()
    -- 对于套牌，只更新数量到所有客户端
    CustomGameEventManager:Send_ServerToAllClients("ds_card_changed", {
        Player = self.player:GetPlayerID(),
        DeckCount = TableCount(self.cards),
    })
end

function Deck:RemoveCard(card)
    for k, _card in pairs(self.cards) do
        if _card == card then self.cards[k] = nil break end
    end
end