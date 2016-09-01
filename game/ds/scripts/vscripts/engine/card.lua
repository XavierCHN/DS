-- 卡牌核心类
if Card == nil then Card = class({}) end

-- 使用ID初始化一张卡牌
-- 这张卡牌在游戏开始时进入deck的时候，或者被“凭空创造”出来的时候执行构造函数
function Card:constructor(id)
    local data = GameRules.AllCards[id]
    
    -- 初始化各种卡牌数据
    self.ID = id
    self.UniqueID = DoUniqueString("")
    self.HighLightState = ""
    self.draw_index = -1

    -- 所有创建的卡牌都储存在GameRules.AllCreatedCards中，用以在特殊的卡牌中使用
    GameRules.AllCreatedCards[self.UniqueID] = self
    
    data.card_type = data.card_type or CARD_TYPE_SPELL
    data.card_behavior = data.card_behavior or CARD_BEHAVIOR_NO_TARGET
    data.expansion = data.expansion or 1
    data.str_cost = data.cost.str or 0
    data.agi_cost = data.cost.agi or 0
    data.int_cost = data.cost.int or 0
    data.mana_cost = data.cost.mana or 0
    data.high_light = data.high_light or function() return false end
    data.validate = data.validate or function() return true end
    data.effect = data.effect or function() end

    -- 给minion类卡牌的特殊数值
    if data.card_type == CARD_TYPE_MINION then
        data.minion_name = data.minion_name ~= "" and data.minion_name or "minion_" .. id -- 默认召唤单位为minion_{id}
        data.atk = data.atk or 0
        data.hp = data.hp or 1
        data.move_speed = data.move_speed or 300
        data.attack_range = data.attack_range or 600
        data.abilities = data.abilities or {}
        data.special_effects = data.special_effects or function(minion) end
    end
    
    self.data = data
end

-- 验证一张牌是否能使用（执行技能之前）
function Card:Validate_BeforeExecute()

    if GameRules.FORCE_VALIDATE then
        return true
    end

    local hero = self.owner

    if not GameRules.TurnManager:HasGameStarted() then
        return false, "game_havent_started_yet"
    end
    
    -- 通用规则，一回合只能使用一张属性牌
    if self:GetType() == CARD_TYPE_ATTRIBUTE then
        if hero:HasUsedAttributeCardThisRound() then
            return false, "one_attribute_card_one_round"
        end
    end
    
    -- 通用规则，必须满足费用需求，告知具体是什么费用不足
    local meet, reason = self:MeetCostRequirement()
    if not meet then
        return false, reason
    end

    return true
end

function Card:GetOnUseValidator()
    return function(arg)
        return self.data.validate(arg)
    end
end

-- 刷新卡牌状态
function Card:UpdateHighLightState()
    
    if not GameRules.TurnManager:HasGameStarted() then return nil end

    local state = ""
    local hero = self:GetOwner()
    local special_high_light = self.data.high_light(self)
    if not self:CanCastInEnemyRound() then
        if GameRules.TurnManager:GetActivePlayer() ~= self.owner then
            state = "State_Greyout"
        end
    elseif special_high_light then
        state = special_high_light
    elseif self:GetType() == CARD_TYPE_ATTRIBUTE and not hero:HasUsedAttributeCardThisRound() then
        state = "HighLightAttributeCard"
    elseif self:MeetCostRequirement() then
        state = "HighLightGreen"
    end
    if state ~= self.HighLightState then
        CustomGameEventManager:Send_ServerToPlayer(self:GetOwner():GetPlayerOwner(), "ds_highlight_state_changed", {
            CardID = self.UniqueID,
            NewState = state,
        })
        self.HighLightState = state
    end
end

-- 是否满足费用的使用需求
function Card:MeetCostRequirement()
    local str = self.data.str_cost
    local agi = self.data.agi_cost
    local int = self.data.int_cost
    local mana = self.data.mana_cost

    if self.owner:GetAttributeStrength() < str then
        return false, "str_not_enough"
    end
    if self.owner:GetAttributeAgility() < agi then
        return false, "agi_not_enough"
    end
    if self.owner:GetAttributeIntellect() < int then
        return false, "int_not_enough"
    end
    if self.owner:GetManaPool() < mana then
        return false, "mana_not_enough"
    end
    return true
end

function Card:OnUseCard(ability, args)
    local card_func = self.data.on_spell_start
    if card_func and type(card_func) == "function" then
        card_func(self, ability, args)
    end
    
    -- 如果是属性卡，设置为已经使用过属性卡
    if self:IsAttributeCard() then
        self.owner:SetHasUsedAttributeCardThisRound(true)
    end

    -- 支付费用
    local hero = self.owner
    hero:SpendManaCost(self.data.mana_cost)
end

function Card:GetCardBehavior()
    return self.data.card_behavior
end

function Card:SetOwner(owner)
    self.owner = owner
end

function Card:GetOwner()
    return self.owner
end

function Card:GetType()
    return self.data.card_type
end

function Card:GetID()
    return self.ID
end

function Card:GetUniqueID()
    return self.UniqueID
end

-- 进入手牌的顺序
function Card:SetDrawIndex(idx)
    self.draw_index = idx
end

function Card:GetDrawIndex()
    return self.draw_index
end

function Card:IsAttributeCard()
    return self:GetType() == CARD_TYPE_ATTRIBUTE
end

function Card:CanCastInEnemyRound()
    return (self.data.cast_time == CARD_CASTTIME_ENEMY_ROUND or self.data.cast_time == CARD_CASTTIME_BOTH)
end

function Card:CanCastInMyRound()
    return (self.data.cast_time == CARD_CASTTIME_MY_ROUND or self.data.cast_time == CARD_CASTTIME_BOTH)
end

function Card:CanCastAtMyField()
    return (self.data.cast_position == CARD_CAST_POSITION_MY_FIELD or self.data.cast_position == CARD_CAST_POSITION_BOTH)
end

function Card:CanCastAtEnemyField()
    return (self.data.cast_position == CARD_CAST_POSITION_ENEMY_FIELD or self.data.cast_position == CARD_CAST_POSITION_BOTH)
end

function Card:SetPosition(pos)
    self.position = pos
end

function Card:GetMinionName()
    return self.data.minion_name
end

Convars:RegisterCommand("debug_force_card_validate", function()
    GameRules.FORCE_VALIDATE = true
end, "  ", FCVAR_CHEAT)

Convars:RegisterCommand("debug_disable_card_validate", function()
    GameRules.FORCE_VALIDATE = false
end, "  ", FCVAR_CHEAT)