function CDOTA_BaseNPC_Hero:InitDSHero()
	self.attribute_int = 0
	self.attribute_agi = 0
	self.attribute_str = 0
	self.mp = 0
	self.mmp = 0

	self:SetAbilityPoints(0)

	self:FindAbilityByName('ds_point'):SetLevel(1)
	self:FindAbilityByName('ds_single_target'):SetLevel(1)

	self:AddNewModifier(self, nil, "modifier_hero_state", {})

	self.deck = Deck(self)
	self.hand = Hand(self)
	self.selector = Selector(self)

	self:AddNewModifier(self,nil,"modifier_minion_autoattack",{})

	Timers:CreateTimer(function()
		self:SetAbsOrigin(GetGroundPosition(GameRules.BattleField:GetHeroPos(self),self))
		if self:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			self:SetForwardVector(Vector(1,0,0))
		else
			self:SetForwardVector(Vector(-1,0,0))
		end
	end)
end

function CDOTA_BaseNPC_Hero:GetCardList()
	if IsInToolsMode() then
		return DEBUG_CARD_LIST
	else
		return self.card_list
	end
end

-- 抽指定数量的牌
function CDOTA_BaseNPC_Hero:DrawCard(numCards)
	for i = 1, numCards do
		
		local card = self.deck:Pop()
		if card then
			self.hand:AddCard(card)
			card:SetOwner(self)
		else
			print("todo, no card damage")
		end
	end
end

-- 弃牌
function CDOTA_BaseNPC_Hero:DiscardCard(card)
	self.hand:RemoveCard(card)
end

function CDOTA_BaseNPC_Hero:SetCurrentActiveCard(card)
	self.current_active_card = card
end

function CDOTA_BaseNPC_Hero:GetCurrentActiveCard()
	return self.current_active_card
end

function CDOTA_BaseNPC_Hero:SetHasUsedAttributeCardThisRound(t)
	self.has_used_attribute_card = t
end

function CDOTA_BaseNPC_Hero:HasUsedAttributeCardThisRound()
	return self.has_used_attribute_card
end

-- 是否拥有足够的资源以满足使用需求
function CDOTA_BaseNPC_Hero:HasEnough(cost)
	cost.str = cost.str or 0
	cost.agi = cost.agi or 0
	cost.int = cost.int or 0
	cost.mana = cost.mana or 0
	if self.mp < cost.mana then
		return false, "not_enough_mana"
	end

	if self.attribute_str < cost.str then
		return false, "not_enough_str"
	end
	if self.attribute_agi < cost.agi then 
		return false, "not_enough_agi"
	end
	if self.attribute_int < cost.int then
		return false, "not_enough_int"
	end

	return true, ""
end

function CDOTA_BaseNPC_Hero:FillManaPool()
	self.mp = self.mmp
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetManaPool()
	return self.mp
end

function CDOTA_BaseNPC_Hero:SetManaPool(val)
	if val >= self.mmp then
		self.mp = self.mmp
	else
		self.mp = val
	end
	self:SendDataToAllClients()
	return self.mp
end

function CDOTA_BaseNPC_Hero:SpendManaCost(val)
	self.mp = self.mp - val
	if self.mp < 0 then
		print(self.mmp)
		print(debug.traceback("something must be wrong, negative value is not okay"))
		return
	end
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetMaxManaPool()
	return self.mmp
end

function CDOTA_BaseNPC_Hero:SetMaxManaPool(val)
	self:SendDataToAllClients()
	self.mmp = val
end

function CDOTA_BaseNPC_Hero:SetAttributeStrength(val)
	self:SendDataToAllClients()
	self.attribute_str = val
end

function CDOTA_BaseNPC_Hero:GetAttributeStrength()
	return self.attribute_str or 0
end

function CDOTA_BaseNPC_Hero:SetAttributeAgility(val)
	self.attribute_agi = val
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetAttributeAgility()
	return self.attribute_agi or 0
end

function CDOTA_BaseNPC_Hero:SetAttributeIntellect(val)
	self.attribute_int = val
	self:SendDataToAllClients()
end

function CDOTA_BaseNPC_Hero:GetAttributeIntellect()
	return self.attribute_int or 0
end

function CDOTA_BaseNPC_Hero:GetHand()
	return self.hand
end

function CDOTA_BaseNPC_Hero:GetDeck()
	return self.deck
end

function CDOTA_BaseNPC_Hero:GetSelector()
	return self.selector
end

function CDOTA_BaseNPC_Hero:SetCardList(card_list)
	self.card_list = card_list or {}
end

function CDOTA_BaseNPC_Hero:SendDataToAllClients()
	CustomGameEventManager:Send_ServerToAllClients("ds_hero_data_changed", {
		PlayerID = self:GetPlayerID(),
		Str = self.attribute_str,
		Agi = self.attribute_agi,
		Int = self.attribute_int,
		Mana = self.mp,
		MaxMana = self.mmp
	})
end

function CDOTA_BaseNPC_Hero:CreateMinion(card, minion_name, pos, callback)
	if GameRules.BattleField:IsPositionInLine(pos) then
		pos.y = GameRules.BattleField:GetPositionBattleLine(pos):GetOrigin().y-- 强行召唤在区域正中间
	end 
    local ent = CreateUnitByNameAsync(minion_name, pos, false, self, self, self:GetTeamNumber(), function(ent)
        ent:InitDSMinion(card)
        ent.owner = self
		if callback then callback(ent) end
    end)
end

