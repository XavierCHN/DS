if Deck == nil then Deck = class({}) end

function Deck:constructor(player)
    self.cards = {}
    self.player = player
    local card_list = self.player:GetCardList()
    for id, count in pairs(card_list) do
        for i =1, count do
            -- 卡牌的创建入口 
            local card = Card(id)
            card:SetOwner(player) -- 初始化设置卡牌的所有者
            card:SetPosition(self) -- 初始化设置卡牌的位置为玩家的套牌
            self:AddCard(card)
            print("Card added to deck", card:GetUniqueID())
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

-- 返回topdeck
function Deck:Pop()
    return table.remove(self.cards, 1)
end

function Deck:AddCard(card)
    table.insert(self.cards, card)
    self:UpdateToClient()
end

-- 更新套牌数据到客户端
function Deck:UpdateToClient()
    -- 对于套牌，只更新数量到所有客户端
    CustomGameEventManager:Send_ServerToAllClients("ds_deck_card_changed", {
        Player = self.player:GetPlayerID(),
        DeckCount = TableCount(self.cards),
    })
end