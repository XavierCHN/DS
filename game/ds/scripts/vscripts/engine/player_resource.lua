local function sendHttpRequest(req, data, callback)
	local server_addr = "www.avalondota2.com"
	local server_port = 7012

	local req = CreateHTTPRequest("POST",server_addr .. ":" .. port .. "/" .. req)
	for k, v in pairs(data) do
		req:SetHTTPRequestGetOrPostParameter(k, v)
	end

	req:Send(function(result)
		if result.StatusCode == 200 then
			callback(JSON:decode(result.body))
		end
	end)

end

-- 根据玩家ID从服务器获取玩家的卡组列表， callback 回调函数
function CDOTA_PlayerResource:GetPlayerDeckCollectionFromServer(id, callback)
	local steamid = CDOTA_PlayerResource:GetSteamAccountID(id)
	sendHttpRequest("get_deck_collection", {
		steamid = steamid,
	}, callback)
end

-- 根据玩家ID从服务器获取玩家的卡牌收藏列表
function CDOTA_PlayerResource:GetPlayerCardCollectionFromServer(id, callback)
	local steamid = CDOTA_PlayerResource:GetSteamAccountID(id)
	sendHttpRequest("get_card_collection", {
		steamid = steamid,
	}, callback)
end

function CDOTA_PlayerResource:SaveDeckToServer(id, name, card_list, callback)
	local json_card_list = JSON:encode(card_list)
	local steamid = CDOTA_PlayerResource:GetSteamAccountID(id)
	sendHttpRequest("get_card_collection", {
		steamid = steamid,
		name = name,
		card_list = json_card_list,
	}, callback)

end

function CDOTA_PlayerResource:GetPlayerCardList(id)
	self.AllPlayerCardList = self.AllPlayerCardList or {}
	return self.AllPlayerCardList[id] or {}
end

function CDOTA_PlayerResource:SetPlayerCardList(id, card_list)
	self.AllPlayerCardList = self.AllPlayerCardList or {}
	self.AllPlayerCardList[id] = card_list
end

