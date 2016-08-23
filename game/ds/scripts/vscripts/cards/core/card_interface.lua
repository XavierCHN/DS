-- 卡牌交互类
if CardInterface == nil then 
	_G.CardInterface = class({})
end

function CardInterface:Start()
	CustomGameEventManager:RegisterListener("ds_player_use_card",Dynamic_Wrap(CardInterface, "OnPlayerUsedCard"))
	self.activeCardID = {}

	GameRules.CardHighLight = {}
	-- 循环两个玩家的手牌，如果需要高亮则高亮之
	Timers:CreateTimer(function()
		for _, hero in pairs(GameRUles.AllHeroes) do
			for _, card in pairs(hero:GetAllHandCards) do
				GameRules.CardHighLight[card] = GameRules.CardHighLight[card] or false-- TODO!!!

				if card:ShouldHighLight() and not GameRules.CardHighLight[card] then
					GameRules.CardHighLight[card] = true
					-- 发送到客户端，高亮之
				end

				if not card:ShouldHighLight() and GameRules.CardHighLight[card] then
					GameRules.CardHighLight[card] = false
					-- 发送到客户端，熄灭之
				end
			end
		end
	end)
end

function CardInterface:OnPlayerUsedCard(args)
	local playerID = args.PlayerID
	local idx = args.CardIndex
	local player = PlayerResource:GetPlayer(playerID)
	local hero = player:GetAssignedHero()

	-- 设置当前使用的手牌
	hero:SetCurrentActiveCard(idx)
	local card = hero:GetCurrentActiveCard()
	local ccb = card:GetCardBehavior()

	CustomGameEventManager:Send_ServerToPlayer(player,"ds_execute_card_proxy",{
		behavior = ccb,
	})
end

-- 验证一张卡牌是否可以使用
function CardInterface:Validate(ability)
	local hero = self:GetCaster()
	
	-- 拥有任意出牌的modifer，则随便出
	if hero:HasModifier("modifier_unlimited") then
		return true
	end

	local card = hero:GetCurrentActiveCard()

	local card_validate, reason = card:Validate()
	if card_validate then
		return true
	else
		return false, reason
	end
end