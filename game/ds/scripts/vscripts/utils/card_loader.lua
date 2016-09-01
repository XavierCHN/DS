local path_prefix = "cards."
local max_card_number = 10 -- 当前最大的卡牌数量

-- 储存游戏中的全部卡牌
GameRules.AllCards = {}

local function registerCard(data, id)
    -- 因为所有卡牌都在同一个文件夹，因此不可能出现有卡牌ID重复的问题
    -- 直接注册
    GameRules.AllCards[tonumber(id)] = data
end

print 'NOW RELOADING CARD DATA'
local rcc = 0
for id = 1, max_card_number do
    local f_name = path_prefix .. string.format("%05d", id)
    local data = pcall(require, f_name)
    if data then
        registerCard(require(f_name), id)
        rcc = rcc + 1
    end
end

if IsInToolsMode() then
    -- 输出所有卡牌的数据到all_card_data.js文件中
    print("writting card data to js file")
    local all_lines = '$.Msg("Card data has refreshed in all_card_data.js;");\nGameUI.CustomUIConfig().AllCards = {\n'
    for id, data in pairs(GameRules.AllCards) do
        local line = tonumber(id) .. ":"
        local d = {}
        for k, v in pairs(data) do
            if type(v) ~= "function" and k ~= "_NAME" and k ~= '_PACKAGE' and k ~= '_M' then
                d[k] = v
            end
        end
        local dd = JSON:encode(d)
        all_lines = all_lines .. '\t' .. id .. ':' .. dd .. ',\n'
    end
    all_lines = all_lines .. '}'
    local f = io.open('../../../content/dota_addons/ds/panorama/scripts/all_card_data.js', 'w')
    f:write(all_lines)
    f:close()
end