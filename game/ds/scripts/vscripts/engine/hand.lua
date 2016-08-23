if Hand == nil then Hand = class({}) end

function Hand:constructor(hero)
    self.cards = {}
    self.owner = hero
    self.player = PlayerResource:GetPlayer(hero:GetPlayerID())
    self.playerid = self.player:GetPlayerID()

    -- 刷新高亮状态
    self.hl_state = {}

    PlayerTables:CreateTable("hand_cards_" .. self.playerid, self.cards, {self.playerid})
end

function Hand:AddCard(card)
    if not card then
        print("Attempt to add a nil card to hand" .. self.playerid)
    end

    print("Adding card to hand!")

    table.insert(self.cards, card)

    PlayerTables:SetTableValues("hand_cards_" .. self.playerid, self:ToIDArray())

    card:SetOwner(self.owner)

    self.hl_state = {}
end

function Hand:ToIDArray()
    local t = {}
    for i = 1, TableCount(self.cards) do
        t[i] = self.cards[i].ID
    end
    return t
end

function Hand:Clear()
    self.cards = {}

    PlayerTables:SetTableValues("hand_cards_" .. self.playerid, self:ToIDArray())
end

function Hand:GetCardByIndex()
    return self.cards[i]
end

function Hand:RemoveCardByIndex(idx)
    table.remove(self.cards, idx)
    PlayerTables:SetTableValues("hand_cards_" .. self.playerid, self:ToIDArray())
    self.hl_state = {}
end

-- 刷新手牌的高亮状态到UI，UI负责更新卡牌的class即可
-- 目前的写法是，只要有一张牌的高亮状态出现改变，全部手牌都刷新一次
function Hand:RefreshHand_HL()
    local c = false
	for idx, card in pairs(self.cards) do
		local hl = card:ShouldHighLight()
        if self.hl_state[idx] ~= hl then
            c = true
            self.hl_state[idx] = hl
        end
	end
    if c then
        CustomGameEventManager:Send_ServerToPlayer(self.player,"ds_hand_hl_state_changed",self.hl_state)
    end
end

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

