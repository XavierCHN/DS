module(..., package.seeall)

card_type = CARD_TYPE_MINION
main_attr = ATTRIBUTE_STRENGTH
timing = TIMING_INSTANT

expansion = 0
cost = {mana = 1, str = 1, agi = 0, int = 0}
sub_type = {"creep"}
artist = "Xavier"

atk = 1
hp = 5

Effect = function(args)
    local caster = args.caster
    local pos = args.target_points[1]
    local card = args.card
	
    caster:CreateMinion(card, "minion_4", pos)
end

OnExecute = function(card) CreateSummonMinionSelector(card) end
