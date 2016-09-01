-- 每个玩家都拥有自己的一个selector实体

if Selector == nil then Selector = class({}) end

function Selector:constructor(player)
    self.player = PlayerResource:GetPlayer(player:GetPlayerID())
end

function Selector:Create(args)

    if args then -- 如果不提供参数，则原样再来一次
        self.args = args
    end

    local type = self.args.type
    local callback = self.args.callback
    local validate = self.args.validate
    local title = self.args.title

    if type == SELECTOR_POINT then
    -- print("sending point request to client")
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_point_selector", {title = self.args.title})
    elseif type == SELECTOR_UNIT then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_unit_selector", {title = self.args.title})
    elseif type == SELECTOR_NUMBER then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_number_selector", {
            Numbers = JSON:encode(self.args.values),
        })
    elseif type == SELECTOR_YESNO then
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_yes_no_selector", {})
    end
end

function Selector:Validate(arg)

    if not self.args then return end -- 避免有人按Q之后直接再执行一遍操作

    if self.args.validate then
        -- print("sending validate request")
        local success, reason, cancel = self.args.validate(arg)
        if not cancel then
            if not success then
                ShowError(self.player:GetPlayerID(), reason)
                self:Create()
            end
            self:OnSelect(arg) -- 选择成功
            self.args = nil
        end
    end
end

function Selector:OnSelect(arg)
    if self.args.callback then
        self.args.callback(arg)
    end
end


function OnSelectTarget(args)
    local caster = args.caster
    local target = args.target
    local selector = caster:GetSelector()
    if selector then
        selector:Validate(target)
    end
end

function OnSelectPoint(args)
    local caster = args.caster
    local point = args.target_points[1]
    local selector = caster:GetSelector()
    if selector then
        selector:Validate(point)
    end
end