module(..., package.seeall)

card_type = CARD_TYPE_MINION
main_attr = ATTRIBUTE_STRENGTH
expansion = 0
cost = {mana = 1, str = 1, agi = 0, int = 0}
sub_type = {"creep"}
artist = "Xavier"

abilities = {
    "tuxi",
}

atk = 5
hp = 5

Effect = function(args)
    local caster = args.caster
    local pos = args.target_points[1]
    local card = args.card
    caster:CreateMinion(card, "minion_4", pos)
end

OnExecute = function(card)
    local hero = card.owner
    hero:GetSelector():Create({
        type = SELECTOR_POINT,
        title = "#select_position_to_summon",
        validate = function(pos)
            if not GameRules.BattleField:IsPositionInMyField(hero, pos) then
                return false, "cannot_summon_here", false
            elseif not GameRules.BattleField:GetPositionBattleLine(pos):IsLineEmptyForPlayer(hero) then
                hero:GetSelector():Create({
                    type = SELECTOR_YESNO,
                    title = "#confirm_replace",
                    callback = function(result)
                        if result == "yes" then
                            local old_minions = GameRules.BattleField:GetMinionsOnSameLine(hero, pos)
                            for _, minion in pairs(old_minions) do
                                minion:ForceKill(false)
                            end
                            card:ExecuteEffect({
                                caster = hero,
                                target_points = {pos}
                            })
                        end
                    end,
                })
                return false, "", true -- 最后参数返回true，我们来创建一个新的selector，原来的结果会暂存
            else
                return true
            end
        end,
        callback = function(pos)
            card:ExecuteEffect({
                caster = hero,
                target_points = {pos}
            })
        end,
    })
end
