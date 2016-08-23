local max_card_number = 10 -- 当前最大的卡牌数量

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
	validate = function(self) end -- 特殊的使用需求
	on_spell_start = function(self) end -- 卡牌使用的效果，和正常的 Lua Ability写法一样

	-- minion类型卡牌的特殊key，如果卡牌类型不是 CARD_TYPE_MINION 的话，以下这些key将会无效
	atk = 2 -- 攻击力，默认为0
	hp = 3 -- 生命值，默认为1
	move_speed = 300 -- 移动速度，默认为300
	attack_range = 600 -- 攻击距离，如果是远程，默认为600，如果是近战，默认为128
	ranged = true -- 远程，默认为 false 近战
	model = "" -- 模型
	comestics = { -- 饰品
		"",
		"",
		"",
	}
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

-- 储存游戏中的全部卡牌
GameRules.AllCards = {}

local function registerCard(data, id)
	-- 因为所有卡牌都在同一个文件夹，因此不可能出现有卡牌ID重复的问题
	-- 直接注册
	GameRules.AllCards[id] = data
end

local registed_card_count = 0
for id = 1, max_card_number do
	local f_name = "cards." .. string.format("%05d", id)
	local data = pcall(require, f_name)
	if data then
		registerCard(require(f_name), id)
		registed_card_count = registed_card_count + 1
	end
end
print("number all cards = ", TableCount(GameRules.AllCards))



-- 卡牌核心类
if Card == nil then Card = class({}) end

-- 使用ID初始化一张卡牌
-- 这张卡牌在游戏开始时进入deck的时候，或者被“凭空创造”出来的时候执行构造函数
function Card:constructor(id)
	local data = GameRules.AllCards[id]

	if data == nil then
		error(string.format("Invalid card id detected %s", id))
	end

	-- 初始化各种卡牌数据
	self.ID = id

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

	-- 给minion类卡牌的特殊数值
	if data.card_type == CARD_TYPE_MINION then
		data.atk = data.atk or 0
		data.hp = data.hp or 1
		data.move_speed = data.move_speed or 300
		data.attack_range = data.attack_range or 600
		data.model = data.model or ""
		data.comestics = data.comestics or {}
		data.abilities = data.abilities or {}
		data.special_effects = data.special_effects or function(minion) end
	end

	self.data = data
end

-- 验证一张牌是否可以使用
function Card:Validate(ability)
	local hero = ability:GetCaster()
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
end

function Card:ShouldHighLight()
	-- 特殊的高亮效果
	local special_high_light = self.data.high_light(self)
	if special_high_light then
		return special_high_light
	end

	if self:GetType() == CARD_TYPE_ATTRIBUTE and not hero:HasUsedAttributeCardThisRound() then
		return "HighLightAttributeCard"
	end

	-- 费用足够的高亮效果
	if self:MeetCostRequirement() then
		return "HighLightGreen"
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
