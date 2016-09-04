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
        print "creating yes no selector for"
        print (self.player:GetPlayerID())
        CustomGameEventManager:Send_ServerToPlayer(self.player, "start_yes_no_selector", {
            title = self.args.title,
            title_args = self.args.title_args
        })
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
            else
                self:OnSelect(arg) -- 选择成功
                self.args = nil
            end
        end
    end
end

function Selector:OnSelect(arg)
    if not self.args then -- 避免因为任何原因的重复发送指令
        return
    end
    CustomGameEventManager:Send_ServerToPlayer(self.player, "ds_clear_selector_message", {})
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

function CreateSummonMinionSelector(card)
    local hero = card.owner
    hero:GetSelector():Create({
        type = SELECTOR_POINT,
        title = "#select_position_to_summon",
        validate = function(pos)
            if not GameRules.BattleField:IsPositionInMyField(hero, pos) then -- 只能在己方半场释放
                return false, "#cannot_summon_here", false
            elseif not GameRules.BattleField:IsLineEmpty(hero, pos) then
                hero:GetSelector():Create({
                    type = SELECTOR_YESNO,
                    title = "#confirm_replace",
                    callback = function(result)
                        if result == "yes" then
                            local old_minions = GameRules.BattleField:GetMinionsOnSameLine(hero, pos)
                            for _, minion in pairs(old_minions) do
                                minion:ForceKill(false)
                            end
                            card:ExecuteEffect({
                                caster = hero,
                                target_points = {pos}
                            })
                        end
                    end,
                })
                return false, "", true -- 最后参数返回true，我们来创建一个新的selector，原来的结果会暂存
            else
                return true
            end
        end,
        callback = function(pos)
            print("summon position select finished")
            card:ExecuteEffect({
                caster = hero,
                target_points = {pos}
            })
        end,
    })
end

