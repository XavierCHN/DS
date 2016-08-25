print "\nAmazing DotA2 Custom Game Mode Dire Stone Created by XavierCHN is now Loading...\n\n"

-- alias
ConVars = Convars -- 妈的这个老是打错，烦死了！

-- 在非测试环境下，不输出任何信息
if not IsInToolsMode() then
    print = function() end
end

require 'direstone'

function PreCache(context)
end

function Activate()
    GameRules.DS = DS()
    GameRules.DS:Init()
end