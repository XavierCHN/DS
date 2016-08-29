-- 卡牌类型枚举
CARD_TYPE_ATTRIBUTE = 0  -- 属性卡
CARD_TYPE_SPELL = 1      -- 魔法卡
CARD_TYPE_MINION = 2     -- 单位卡
CARD_TYPE_EQUIPMENT = 4     -- 装备卡

-- 卡牌施法类型枚举
CARD_BEHAVIOR_NO_TARGET = 0       -- 无目标
CARD_BEHAVIOR_SINGLE_TARGET = 1   -- 单体目标
CARD_BEHAVIOR_POINT = 2           -- 点目标，所有的召唤单位的卡牌都是点目标卡牌
CARD_BEHAVIOR_MULTIPLE_TARGET = 3 -- 多目标，暂时不用

-- 卡牌的释放时机
CARD_CASTTIME_MY_ROUND = 0 -- 只能在本方回合使用
CARD_CASTTIME_ENEMY_ROUND = 1 -- 只能在敌方回合使用
CARD_CASTTIME_BOTH = 2 -- 双方回合（任意时间都可以使用）

-- 卡牌的释放位置
CARD_CAST_POSITION_MY_FIELD = 0 -- 只能在本方半场使用
CARD_CAST_POSITION_ENEMY_FIELD = 1 -- 只能在敌方半场使用
CARD_CAST_POSITION_BOTH = 2 -- 可以在场地的任意位置使用

-- 卡牌的主属性
ATTRIBUTE_NONE = 0 -- 无属性
ATTRIBUTE_STRENGTH = 1 -- 力量
ATTRIBUTE_AGILITY = 2 -- 敏捷
ATTRIBUTE_INTELLECT = 3 -- 智力