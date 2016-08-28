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
    table.insert(self.cards, card)
    self:UpdateToClient()
end

function Hand:UpdateToClient()
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

function Hand:OnRequestHand(args)
    local playerid = args.PlayerID
    local hero = PlayerResource:GetPlayer(playerid):GetAssignedHero()
    if not hero then return end
    hero:GetHand():UpdateToClient()
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