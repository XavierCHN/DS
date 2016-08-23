local max_card_number = 10 -- 当前最大的卡牌数量

-- 卡牌的定义的结构
--[[
	module(..., package.seeall) -- 必须照抄
	card_type = CARD_TYPE_ATTRIBUTE -- 默认为 CARD_TYPE_SPELL
	card_behavior = CARD_BEHAVIOR_NO_TARGET -- 默认为 CARD_BEHAVIOR_NO_TARGET
	expansion = 0 -- 版本号，默认为0，初始包
	high_light = function(card) end -- 高亮条件
	cost = {str=0,agi=0,int=0,mana=0} -- 所需资源，mana为魔法，其余为需要满足的属性需求
	validate = function(self) end -- 特殊的使用需求
	on_spell_start = function(self) end -- 卡牌使用的效果

	-- minion类型卡牌的特殊key

]]

-- 储存游戏中的全部卡牌
GameRules.AllCards = {}

local function registerCard(data)
	-- 因为所有卡牌都在同一个文件夹，因此不可能出现有卡牌ID重复的问题
	-- 直接注册
	GameRules.AllCards[data._NAME] = data
end

local registed_card_count = 0
for id = 1, max_card_number do
	local f_name = string.format("%05d", id)
	local data = pcall(require, f_name)
	if data then
		registerCard(require(f_name))
		registed_card_count = registed_card_count + 1
	end
end

-- 卡牌核心类
if Card == nil then Card = class({}) end

-- 使用ID初始化一张卡牌
-- 这张卡牌在游戏开始时进入deck的时候，或者被“凭空创造”出来的时候执行构造函数
function Card:constructor(id)
	local formated_id = string.format("%05d", tonumber(id))
	local data = GameRules.AllCards[formated_id]

	if data == nil then
		error(string.format("Invalid card id detected %s", formated_id))
	end

	-- 初始化各种卡牌数据
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

end

-- 验证一张牌是否可以使用
function Card:Validate(ability)
	local hero = ability:GetCaster()
	if self:GetType == CARD_TYPE_ATTRIBUTE then
		if :HasUsedAttributeCardThisRound() then
			return false, "one_attribute_card_one_round" -- 通用规则，一回合只能使用一张属性牌
		end
	end
end

function Card:GetCardBehavior()
	return self.data.card_behavior
end