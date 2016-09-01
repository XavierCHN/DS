-- 每个玩家都拥有自己的一个selector实体

if Selector == nil then Selector = class({}) end

function Selector:constructor(player)
    self.player = player
    self.state = nil
end

function Selector:Create(args)

    if args then -- 如果不提供参数，则原样再来一次
        self.type = args.type
        self.callback = args.callback
        self.validate = args.validate
    end

    if self.type == SELECTOR_POINT then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_point_selector", {})
    elseif type == SELECTOR_UNIT then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_unit_selector", {})
    elseif type == SELECTOR_NUMBER then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_number_selector", {
            Numbers = JSON:encode(args.values),
        })
    elseif type == SELECTOR_YESNO then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_yes_no_selector", {})
    end
end

function Selector:Validate(arg)
    if self.validate then
        local success, reason = self.validate(arg)
        if not success then
            ShowError(self.player:GetPlayerID(), reason)
            self:Create()
            return false
        else
            self:OnSelect(arg) -- 选择成功
        end
    end
    return true
end

function Selector:OnSelect(arg)
    if self.callback then
        self.callback(arg)
    end
end


function OnSelectTarget(args)
    local caster = args.caster
    local target = args.target
    local selector = caster:GetSelector()
    if selector then
        selector:Validate()
    end
end

function OnSelectPoint(args)
    local caster = args.caster
    local target = keys.target_points[1]
    local selector = caster:GetSelector()
    if selector then
        selector:Validate()
    end
end