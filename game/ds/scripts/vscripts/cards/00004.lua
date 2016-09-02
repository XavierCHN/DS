module(..., package.seeall)

card_type = CARD_TYPE_MINION
main_attr = ATTRIBUTE_STRENGTH
timing = TIMGING_NORMAL

expansion = 0
cost = {mana = 1, str = 1, agi = 0, int = 0}
sub_type = {"creep"}
artist = "Xavier"

atk = 5
hp = 5

abilities = {
    flying = {
    	type = "static",
    	ModifierName = "modifier_minion_flying",
        ModifierData = {} -- 可以为空
    },
    a4_1 = {
        type = "active",
		cost = {mana = 2},
		timing = TIMING_NORMAL,
        OnActive = function(minion)
            hero:GetSelector():Create({
            	type = SELECTOR_UNIT,
            	title = "select_friendly_minion",
            	validate = function(target)
            		if target:GetTeamNumber() ~= hero:GetTeamNumber() then
            			return false, "must_target_friendly"
            		end
            		if target:IsRealHero() then
            			return false, "must_target_minion"
            		end
            		return true
	            end,
	            callback = function(target)
	            	hero:SpendManaCost(cost.mana);
	            	local bonus = {atk = 1, hp=5}
	            	target:AddNewModifier(hero,nil,"modifier_atk_hp_bonus",bonus)
		        end
            })
        end
    },
    a4_2 = {
    	type = "trigger",
    	event = {
    		name = "OnPlayerDrawCard",
    		condition = function(args)
				return true
    		end,
	    },
	    OnTriggered = function(minion)
	    	local bonus = {atk = 1, hp = 1}
	    	minion:AddNewModifier( minion.player, nil, "modifier_atk_hp_bonus", bonus)
	    end,
	}
}

Effect = function(args)
    local caster = args.caster
    local pos = args.target_points[1]
    local card = args.card
    caster:CreateMinion(card, "minion_4", pos)
end

OnExecute = function(card) CreateSummonMinionSelector(card) end
