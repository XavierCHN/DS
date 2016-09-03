module(..., package.seeall)

card_type = CARD_TYPE_MINION
main_attr = ATTRIBUTE_NONE
timing = TIMING_NORMAL

expansion = 0
cost = {mana = 20, str = 5, agi = 5, int = 5}
sub_type = {"god"}
prefix_type ={"ultimate"}
artist = "Valve"

atk = 99
hp = 99

abilities = {}

Effect = function(args)
    local caster = args.caster
    local pos = args.target_points[1]
    local card = args.card
    caster:CreateMinion(card, "icefrog", pos, function()
        GameRules:SetGameWinner(caster:GetPlayerID())
    end)
end

OnExecute = function(card) CreateSummonMinionSelector(card) end
