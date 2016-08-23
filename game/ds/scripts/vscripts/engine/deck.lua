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
function Deck:constructor(card_list, owner)
    self.cards = {}
    self.owner = owner
    for _, card in pairs(card_list) do
        for i =1, card.cc do
            local card = Card(card.id)
            card:SetOwner(owner)
            table.insert(self.cards, card)
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

-- 抽出并返回最上一张卡
function Deck:Pop()
    return table.remove(self.cards, 1)
end
