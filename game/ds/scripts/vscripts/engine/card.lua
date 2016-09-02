-- 卡牌核心类
if Card == nil then Card = class({}) end

-- 使用ID初始化一张卡牌
-- 这张卡牌在游戏开始时进入deck的时候，或者被“凭空创造”出来的时候执行构造函数
function Card:constructor(id)
    local data = GameRules.AllCards[id]
    if not data then print("invalid id", id) end
    -- 初始化各种卡牌数据
    self.ID = id
    self.UniqueID = DoUniqueString("")
    self.HighLightState = ""
    self.draw_index = -1

    -- 所有创建的卡牌都储存在GameRules.AllCreatedCards中，用以在特殊的卡牌中使用
    GameRules.AllCreatedCards[self.UniqueID] = self
    
    -- 这里读取的信息只限于显示在卡牌上的信息
    -- 不显示在卡牌的信息，不读取到卡牌类中
    data.str_cost = data.cost.str or 0
    data.agi_cost = data.cost.agi or 0
    data.int_cost = data.cost.int or 0
    data.mana_cost = data.cost.mana or 0
    data.timing = data.timing or TIMING_NORMAL
    data.HighLight = data.HighLight
    data.Effect = data.Effect
    data.OnExecute = data.OnExecute


    -- 给minion类卡牌的特殊数值
    if data.card_type == CARD_TYPE_MINION then
        data.atk = data.atk or 0
        data.hp = data.hp or 1
        data.move_speed = data.move_speed or 300
        data.attack_range = data.attack_range or 600
        data.abilities = data.abilities or {}
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
    
    -- 必须满足费用需求
    local meet, reason = hero:HasEnough({str = self.data.str_cost, agi = self.data.agi_cost, int = self.data.int_cost, mana = self.data.mana_cost})
    if not meet then return meet, reason end

    -- 通用规则，一回合只能使用一张属性牌
    if self:GetType() == CARD_TYPE_ATTRIBUTE then
        if hero:HasUsedAttributeCardThisRound() then
            return false, "one_attribute_card_one_round"
        end
    end

    meet, reason = GameRules.TurnManager:IsMeetTimingRequirement(hero, timing)
    if not meet then return meet, reason end

    return true
end

-- 如果卡牌有需要做验证的，做目标选择的，做位置选择的，那么做选择，否则直接运行效果
-- 如果有需要做选择的，那么，需要在做出选择之后执行RunEffect
function Card:OnExecute()
    if self.data.OnExecute then
        self.data.OnExecute(self)
    else
        self:ExecuteEffect({caster = self.owner})
    end
end

-- 执行卡牌的效果
function Card:ExecuteEffect(args)

    if not self.data.Effect then
        print("card has no effect defined! cardid =>", self:GetID())
        return;
    end

    -- 因为经常会默认return nil，如果这里返回了一个非nil的值，那么就会触发对应的效果
    args.card = self
    local ss = self.data.Effect(args)

    local no_cost
    local no_discard

    if ss and type(ss) == "number" then
        no_cost = bit.band(ss, EFFECT_RESULT_DONT_DISCARD_CARD) == EFFECT_RESULT_DONT_DISCARD_CARD
        no_discard = bit.band(ssm, EFFECT_RESULT_DONT_SPEND_MANA) == EFFECT_RESULT_DONT_SPEND_MANA
    end

    if not no_cost then
        self.owner:SpendManaCost(self.data.mana_cost);
    end
    if not no_discard then
        self.owner:GetHand():RemoveCard(self)
    end 

    -- 如果是属性卡，设置为已经使用过属性卡
    if self:IsAttributeCard() then
        self.owner:SetHasUsedAttributeCardThisRound(true)
    end
end

-- 刷新卡牌状态
-- 这个函数需要重写
function Card:UpdateHighLightState()
    if not GameRules.TurnManager:HasGameStarted() then return nil end
end

function Card:GetCardBehavior()
    return self.data.card_behavior
end

function Card:IsAttributeCard()
    return self:GetType() == CARD_TYPE_ATTRIBUTE
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

Convars:RegisterCommand("debug_force_card_validate", function()
    GameRules.FORCE_VALIDATE = true
end, "  ", FCVAR_CHEAT)

Convars:RegisterCommand("debug_disable_card_validate", function()
    GameRules.FORCE_VALIDATE = false
end, "  ", FCVAR_CHEAT)