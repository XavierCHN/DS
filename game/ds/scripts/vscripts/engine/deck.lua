if Deck == nil then Deck = class({}) end

function Deck:constructor(player)
    self.player = player
    self.cards = List()

    local card_list = self.player:GetCardList()
    for id, count in pairs(card_list) do
        for i =1, count do
            -- 卡牌的创建入口 
            local card = Card(id)
            card:SetOwner(player) -- 初始化设置卡牌的所有者
            -- 将卡牌加入套牌
            self.cards:AddRear(card)
        end
    end
    -- self:DisplayData()
end

function Deck:DisplayData()
    for i = 1, self.cards:Count() do
        local card = self.cards:GetData(i)
        print(string.format("DeckCardList No-[%d] = CardID[%s] - UID[%s]",i, card:GetID(), card:GetUniqueID()))
    end
    print("-------------DECK DISPLAY FINISHED---------------")
end

-- 洗牌 Fisher–Yates shuffle算法
function Deck:Shuffle()
    local i = self.cards:Count()
    local j = 0
    local temp = 0
    if i <= 0 then
        return
    end

    while( i-1 > 0) do
        local j = RandomInt(1, i)
        print("attempt to swap",i,j)
        self.cards:Swap(i, j)
        i = i - 1
    end
    -- self:DisplayData()
end

-- 返回topdeck
function Deck:Pop()
    return self.cards:Remove(1)
end

-- 添加卡牌，放在尾部
function Deck:AddCard(card)
    self.cards:AddRear(card)
end

-- 添加卡牌到牌库顶
function Deck:AddAtHead(card)
    self.cards:AddHead(card)
end

-- 更新套牌数据到客户端
function Deck:UpdateToClient()
    -- 对于套牌，只更新数量到所有客户端
    CustomGameEventManager:Send_ServerToAllClients("ds_deck_card_changed", {
        Player = self.player:GetPlayerID(),
        DeckCount = self.cards:Count(),
    })
end