if GraveYard == nil then 
    GraveYard = class({}) 
end

function GraveYard:constructor(player)
    self.cards = {}

    self.player = player
end

function GraveYard:AddCard(card)
    self.card_index = self.card_index or 0
    self.card_index = self.card_index + 1

    self.cards[card:GetUniqueId()] = card

    self:UpdateToClient()
end

function GraveYard:UpdateToClient()
    local serialized_data = {}
    for uid, card in pairs(self.cards) do
        local card_data = {}
        card_data.id = card:GetID()
        -- card_data.graveyard_index = card:GetGraveYardIndex()
        card_data.unique_id = uid

        serialized_data[uid] = card_data
    end

    CustomGameEventManager:Send_ServerToAllClients(self.player, "ds_update_grave_yard", {})
end

function GraveYard:RemoveCard(card)
    for k, _card in pairs(self.cards) do
        if _card == card then 
            table.remove(self.cards, k)
            break 
        end
    end
end