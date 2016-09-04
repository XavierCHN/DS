if Ability == nil then Ability = class({}) end

function Ability:UpdateToClient()
    CustomNetTables:SetTableValue("ability_data", self:GetUniqueID(), self.data_for_client)
end

function Ability:SetAssociatedEntityIndex(ent)
    self.ent = ent
end

function Ability:GetUniqueID()
    return self.uid
end