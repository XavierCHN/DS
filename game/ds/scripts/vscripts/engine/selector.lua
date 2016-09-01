-- 每个玩家都拥有自己的一个selector实体

if Selector == nil then Selector = class({}) end

function Selector:constructor(player)
    self.player = player
end

function Selector:Create(args)

    selftype = args.type
    self.callback = args.callback
    self.validate = args.validate

    if self.type == SELECTOR_POINT then
        CustomGameEventManager:Send_ServerToPlayer(player, "start_point_selector", {})
    elseif type == SELECTOR_UNIT then
        CustomGameEventManager:Send_ServerToPlayer(player, "start_unit_selector", {})
    end

end

function Selector:Validate(arg)
    if self.validate then
        return self.validate(self, arg)
    end
    return true
end

function Selector:OnSelect(arg)
    if self.callback then
        self.callback(self, arg)
    end
end