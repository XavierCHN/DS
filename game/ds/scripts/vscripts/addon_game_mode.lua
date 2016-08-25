print "\nAmazing DotA2 Custom Game Mode Dire Stone Created by XavierCHN is now Loading...\n\n"

-- alias
ConVars = Convars -- 妈的这个老是打错，烦死了！

require 'direstone'

function PreCache(context)
end

function Activate()
    GameRules.DS = DS()
    GameRules.DS:Init()
end