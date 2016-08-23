-- 卡牌类型枚举
CARD_TYPE_ATTRIBUTE = 0  -- 属性卡
CARD_TYPE_SPELL = 1      -- 魔法卡
CARD_TYPE_MINION = 2     -- 单位卡
CARD_TYPE_WEAPON = 4     -- 武器卡

-- 卡牌施法类型枚举
CARD_BEHAVIOR_NO_TARGET = 0       -- 无目标
CARD_BEHAVIOR_SINGLE_TARGET = 1   -- 单体目标
CARD_BEHAVIOR_POINT = 2           -- 点目标，所有的召唤单位的卡牌都是点目标卡牌
CARD_BEHAVIOR_MULTIPLE_TARGET = 3 -- 多目标，暂时不用

HIGH_LIGHT_GREEN = 1 -- 变绿，可以使用
HIGH_LIGHT_YELLOW = 2 -- 变黄，推荐使用
