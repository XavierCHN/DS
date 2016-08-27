if Deck == nil then Deck = class({}) end

-- 使用卡表和拥有卡组的英雄来初始化一个牌组
-- 卡表使用如下结构
--[[
    {
        id="00001",
        cc=3, -- 数量
    },
    {
        id="00002",
        cc=1,
    },
    -- ...
]]
function Deck:constructor(player)
    self.cards = {}
    self.player = player
    for _, card in pairs(card_list) do
        for i =1, card.cc do
            -- 卡牌的创建入口 
            local card = Card(card.id)
            card:SetOwner(player)
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
    CustomGameEventManager:Send_ServerToAllClients("ds_card_changed", {
        Player = self.player:GetPlayerID(),
        DeckCount = TableCount(self.cards),
    })
end