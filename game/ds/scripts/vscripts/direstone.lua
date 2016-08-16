if DS == nil then DS = class({}) end

require 'cards._utils'

function DS:Init()
    -- self.vStack = Stack()

    local mode = GameRules:GetGameModeEntity()

    mode:SetFogOfWarDisabled(true)

    self.mode = mode
    GameRules.mode = mode
    GameRules.GameMode = self
end
