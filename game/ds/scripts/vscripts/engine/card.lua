--[[
卡牌Lua的语法规则
文件的命名必须为独立的五位数字（卡牌ID前面补0），如00103.lua

文件内容
module(..., package.seeall) -- 第一行，必须照抄

card_type = CARD_TYPE_ATTRIBUTE -- 默认为 CARD_TYPE_SPELL
card_behavior = CARD_BEHAVIOR_NO_TARGET -- 默认为 CARD_BEHAVIOR_NO_TARGET
expansion = 0 -- 版本号，默认为0，初始包
high_light = function(card) return "HighLightGolden" end -- 高亮，返回高亮的css类
cost = {str=0,agi=0,int=0,mana=0} -- 所需资源，mana为魔法，其余为需要满足的属性需求
validate = function(card, ability, args ) end -- 特殊的使用需求，根据不同的类型，可能会传入不同的参数,返回 true 或者 false, "失败原因"
on_spell_start = function(card, ability, args) end -- 卡牌使用的效果，和正常的 Lua Ability写法一样
artist = "Xavier" -- 卡牌插画的作者
cast_time = CARD_CASTTIME_MY_ROUND -- 释放时机，只能在本方回合使用，还包括 CARD_CASTTIME_ENEMY_ROUND, CARD_CASTTIME_BOTH
cast_position = CARD_CAST_POSITION_ENEMY_FIELD -- 释放地点 CARD_CAST_POSITION_MY_FIELD CARD_CAST_POSITION_ENEMY_FIELD CARD_CAST_POSITION_BOTH

-- 不重要的可选
prefix_type = {"ultimate"} --前缀类别，如 无双，会显示在名字中，在交互中有用，默认为空
sub_type = { "beast" } -- 副类别，如野兽
-- 主类别，前缀类别和后缀类别构成一张卡牌的类别，如
-- 无双生物 ~ 野兽/精怪
-- 基本属性
-- 无双属性
-- 生物 ~ 半人马/领袖，这些属性在交互之中是有用的

-- minion类型卡牌的特殊key，如果卡牌类型不是 CARD_TYPE_MINION 的话，以下这些key将会无效
minion_name = "special_minon_name" -- 所要召唤的单位的名称，默认为 minion_{卡牌ID}
atk = 2 -- 攻击力，默认为0
hp = 3 -- 生命值，默认为1
move_speed = 300 -- 移动速度，默认为300
attack_range = 600 -- 攻击距离，如果是远程，默认为600，如果是近战，默认为128
abilities = { -- 技能列表，之后将会进一步补充可以使用的默认技能名称
    "cannot_attack", -- 禁止攻击
    "blink", -- 闪烁
}
special_effects = function(minion)
    minion:一切可以执行给 CDOTA_BaseNPC 的API都可以在这里执行给minion
    -- 这里面的内容将会在单位被召唤出来之后使用一个Timer来执行
    -- 但是还是尽量使用技能来保持系统的一致性
end
]]
local path_prefix = "cards."
local max_card_number = 10 -- 当前最大的卡牌数量

-- 储存游戏中的全部卡牌
GameRules.AllCards = {}

local function registerCard(data, id)
    -- 因为所有卡牌都在同一个文件夹，因此不可能出现有卡牌ID重复的问题
    -- 直接注册
    GameRules.AllCards[tonumber(id)] = data
end

print 'NOW RELOADING CARD DATA'
local rcc = 0
for id = 1, max_card_number do
    local f_name = path_prefix .. string.format("%05d", id)
    local data = pcall(require, f_name)
    if data then
        registerCard(require(f_name), id)
        rcc = rcc + 1
    end
end

if IsInToolsMode() then
    -- 输出所有卡牌的数据到all_card_data.js文件中
    print("writting card data to js file")
    local all_lines = '$.Msg("Card data has refreshed in all_card_data.js;");\nGameUI.CustomUIConfig().AllCards = {\n'
    for id, data in pairs(GameRules.AllCards) do
        local line = tonumber(id) .. ":"
        local d = {}
        for k, v in pairs(data) do
            if type(v) ~= "function" and k ~= "_NAME" and k ~= '_PACKAGE' and k ~= '_M' then
                d[k] = v
            end
        end
        local dd = JSON:encode(d)
        all_lines = all_lines .. '\t' .. id .. ':' .. dd .. ',\n'
    end
    all_lines = all_lines .. '}'
    local f = io.open('../../../content/dota_addons/ds/panorama/scripts/all_card_data.js', 'w')
    f:write(all_lines)
    f:close()
end

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
    data.cost = data.cost or {}
    data.cost.str = data.cost.str or 0
    data.cost.agi = data.cost.agi or 0
    data.cost.int = data.cost.int or 0
    data.cost.mana = data.cost.mana or 0
    data.high_light = data.high_light or function() return false end
    data.validate = data.validate or function() return true end
    data.on_spell_start = data.on_spell_start or function() end
    data.can_cast_anytime = data.can_cast_anytime or false
    
    if self.card_behavior == CARD_BEHAVIOR_POINT then
        if data.card_type == CARD_TYPE_MINION then -- 随从类默认只能在己方半场使用
            data.can_cast_anywhere = data.can_cast_anywhere or CARD_CAST_POSITION_MY_FIELD
        end
        if data.card_type == CARD_TYPE_SPELL then -- 法术类默认在全场使用，除非有特殊规定
            data.can_cast_anywhere = data.can_cast_anywhere or CARD_CAST_POSITION_BOTH
        end
    end
    
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

-- 验证一张牌是否可以使用
function Card:Validate(ability, args)
    local hero = ability:GetCaster()
    
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
    
    -- 通用规则，是否能在我方或者敌方回合使用
    if not self:CanCastInEnemyRound() and GameRules.TurnManager:GetActivePlayer() ~= hero then
        print(self:CanCastInEnemyRound() , GameRules.TurnManager:GetActivePlayer() ~= hero)
        return false, "cant_use_at_enemy_round"
    end
    
    if not self:CanCastInMyRound() and GameRules.TurnManager:GetActivePlayer() == hero then
        return false, "cant_use_at_my_round"
    end
    
    -- 通用规则，释放位置需求
    if ability:GetAbilityName() == "ds_point" then
        if not self:CanCastAtEnemyField() and not GameRules.BattleField:IsMyField(hero, args.target_points[1]) then
            return false, "cant_cast_at_enemy_field"
        end
        if not self:CanCastAtMyField() and GameRules.BattleField:IsMyField(hero, args.target_points[1]) then
            return false, "cant_cast_at_my_field"
        end
    end
    
    if self.data.validate and type(self.data.validate) == "function" then
        self.data.validate(self, ability, args)
    end
    
    return true, ""
end

-- 刷新卡牌状态
function Card:UpdateHighLightState()
    
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
    end
end

-- 是否满足费用的使用需求
function Card:MeetCostRequirement()
    local str = self.data.cost.str
    local agi = self.data.cost.agi
    local int = self.data.cost.int
    local mana = self.data.cost.mana
    
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