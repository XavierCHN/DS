-- 卡牌核心类
if Card == nil then Card = class({}) end

-- 使用ID初始化一张卡牌
-- 这张卡牌在游戏开始时进入deck的时候，或者被“凭空创造”出来的时候执行构造函数
function Card:constructor(id)
    local data = GameRules.AllCards[id]
    if not data then print("invalid id", id) end
    -- 初始化各种卡牌数据
    self.ID = id
    self.UniqueID = DoUniqueString("") -- 卡牌的唯一标识，不允许改变
    self.HighLightState = ""

    -- 所有创建的卡牌都储存在GameRules.AllCreatedCards中，用以在特殊的卡牌中使用
    GameRules.AllCreatedCards[self.UniqueID] = self
    
    data.id = id
    data.card_type = data.card_type or CARD_TYPE_MINION
    data.main_attr = data.main_attr or ATTRIBUTE_STRENGTH
    data.str_cost = data.cost.str or 0
    data.agi_cost = data.cost.agi or 0
    data.int_cost = data.cost.int or 0
    data.mana_cost = data.cost.mana or 0
    data.timing = data.timing or TIMING_NORMAL
    data.HighLight = data.HighLight
    data.Effect = data.Effect -- 执行的效果
    data.OnExecute = data.OnExecute -- 使用后到执行前需要进行的验证啦 选择目标之类的操作

    -- 给minion类卡牌的特殊数值
    if data.card_type == CARD_TYPE_MINION then
        data.atk = data.atk or 0
        data.hp = data.hp or 1
        data.move_speed = data.move_speed or 300
        data.attack_range = data.attack_range or 600
        data.abilities = data.abilities or {}
        for name, ability_data in pairs(data.abilities) do
            ability_data.name = name
        end
    end
    
    self.data = data

    self:UpdateToClient()
end

function Card:GetAbilities()
    return self.data.abilities
end

-- 验证一张牌是否能使用（执行技能之前）
function Card:Validate_BeforeExecute()

    local hero = self.owner

    if not GameRules.TurnManager:HasGameStarted() then
        return false, "game_havent_started_yet"
    end


    -- 强制游戏开始之后才能使用卡牌
    if GameRules.FORCE_VALIDATE then return true end

    meet, reason = GameRules.TurnManager:IsMeetTimingRequirement(hero, self.data.timing)
    if not meet then return meet, reason end

    -- 必须满足费用需求
    local meet, reason = hero:HasEnough({str = self.data.str_cost, agi = self.data.agi_cost, int = self.data.int_cost, mana = self.data.mana_cost})
    if not meet then return meet, reason end

    -- 通用规则，一回合只能使用一张属性牌
    if self:GetType() == CARD_TYPE_ATTRIBUTE then
        if hero:HasUsedAttributeCardThisRound() then
            return false, "one_attribute_card_one_round"
        end
    end
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

    CustomGameEventManager:Send_ServerToAllClients('ds_show_card', {
        UniqueID = self:GetUniqueID(),
    })

    GameRules.UsedCards:AddHead(self:GetUniqueID())
    if GameRules.UsedCards:Count() > 10 then
        GameRules.UsedCards:RemoveRear()
    end

    CustomNetTables:SetTableValue("card_history", "card_history", GameRules.UsedCards:ToArray())

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
    self.data.playerid = owner:GetPlayerID()
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

-- 必须使用这个API来改变某张卡牌的数值，这样才会更新到UI中
function Card:ChangeData(key, value)
    self.data[key] = value

    self:UpdateToClient()
    
    CustomGameEventManager:Send_ServerToAllClients("ds_card_data_changed", {
        UniqueID = self:GetUniqueID(),
    })
end

function Card:UpdateToClient()
    local d = {}
    local ab_index = 1
    for k,v in pairs(self.data) do
        if k == "abilities" then
            d.abilities = {}
            for name, ability_data in pairs(v) do
                local safe_table = safe_table(ability_data)
                safe_table.name = name
                table.insert(d.abilities, JSON:encode(safe_table))
            end
        elseif type(v) ~= "function" and k ~= "_NAME" and k ~= '_PACKAGE' and k ~= '_M' then
            d[k] = v
        end
    end
    CustomNetTables:SetTableValue("card_data", self:GetUniqueID(), d)
end

-- 执行卡牌的技能
function Card:ExecuteMinionAbility(minion, ability_name)
    local ability = self.data.abilities[ability_name]
    local cost = ability.cost
	local timing = ability.timing
	local hero = self.owner
	local meet, reason = hero:HasEnough(cost)
	if not meet then
		ShowError(hero:GetPlayerID(), reason)
		return
	end
	meet, reason = GameRules.TurnManager:IsMeetTimingRequirement(hero, timing)
	if not meet then
		ShowError(hero:GetPlayerID(), reason)
		return
	end
	ability.OnActive(minion)
end