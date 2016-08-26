if Hand == nil then Hand = class({}) end

function Hand:constructor(hero)
    self.cards = {}
    self.owner = hero
    self.player = PlayerResource:GetPlayer(hero:GetPlayerID())
    self.playerid = self.player:GetPlayerID()
    self.draw_card_index = 0

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
    if not card then
        print("Attempt to add a nil card to hand" .. self.playerid)
    end

    print(string.format("Adding card to hand! CardID[%s], CardUniqueID[%s]",card:GetID(), card:GetUniqueID()))
    
    self.draw_card_index = self.draw_card_index or 0
    self.draw_card_index = self.draw_card_index + 1

    card:SetDrawIndex(self.draw_card_index)

    print("draw card index = ", self.draw_card_index)

    self.cards[card:GetUniqueID()] = card

    card:SetOwner(self.owner)

    self:UpdateToClient()

    GameRules.EventManager:Emit("OnAddCardToHand", {
        Card = card,
        CardID = card:GetID(),
        Player = self.player
    })
end

function Hand:UpdateToClient()

    local serialized_data = {}

    for idx, card in pairs(self.cards) do
        local card_data = {}
        -- 将所有需要发送到客户端的参数装入
        card_data.id = card:GetID()
        card_data.unique_id = card:GetUniqueID()
        card_data.draw_index = card:GetDrawIndex()

        -- 使用json序列化之后发送
        serialized_data[idx] = JSON:encode(card_data)
    end

    CustomGameEventManager:Send_ServerToPlayer(self.player, "ds_player_hand_changed", serialized_data)
end

function Hand:Clear()
    self.cards = {}
    self:UpdateToClient()
end

function Hand:GetCardByUniqueId(uniqueId)
    return self.cards[uniqueId]
end

-- 根据手牌ID弃掉一张手牌
function Hand:RemoveCardByUniqueId(uniqueId)
    GameRules.EventManager:Emit("OnPlayerLoseHandCard", {
        Card = self.cards[uniqueId],
        Player = self.player
    })
    self.cards[uniqueId] = nil
    self:UpdateToClient()
end

-- 随机弃掉N张手牌
function Hand:RemoveRandomCard(count)
    count = count or 1
    for i = 1, count do
        local uniqueIds = {}
        for uniqueId,_ in pairs(self.cards) do
            table.insert(uniqueIds, uniqueId)
        end
        self.cards[uniqueIds[RandomInt(1,#uniqueIds)]] = nil
    end
    self:UpdateToClient()
end

function Hand:OnRequestHand(args)
    local playerid = args.PlayerID
    local hero = PlayerResource:GetPlayer(playerid):GetAssignedHero()
    if not hero then return end
    hero:GetHand():UpdateToClient()
end

function Hand:GetCardByDrawIndex(idx)
    for _, card in pairs(self.cards) do
        if card:GetDrawIndex() == idx then
            return card
        end
    end
end

-- 客户端请求发送手牌数据
CustomGameEventManager:RegisterListener("ds_request_hand", Dynamic_Wrap(Hand, "OnRequestHand"))

Convars:RegisterCommand("debug_add_card",function(_, id)

	local client = Convars:GetCommandClient()
	local hero = client:GetAssignedHero()
    print("trying to add card to player", id, hero:GetPlayerID())
	local hand = hero:GetHand()
	local card = Card(tonumber(id))
	card:SetOwner(hero)
	hand:AddCard(card)
end,"debug add a card to a player's hand",FCVAR_CHEAT)

Convars:RegisterCommand("debug_clear_hand",function(_, id)
    local client = Convars:GetCommandClient()
    local hero = client:GetAssignedHero()
    local hand = hero:GetHand()
    hand:Clear()
end,"debug add a card to a player's hand",FCVAR_CHEAT)

Convars:RegisterCommand("debug_remove_card", function(_, index)
    local client = Convars:GetCommandClient()
    local hero = client:GetAssignedHero()
    local hand = hero:GetHand()

    local card = hand:GetCardByDrawIndex(tonumber(index))
    hand:RemoveCardByUniqueId(card:GetUniqueID())
end,"", FCVAR_CHEAT)

