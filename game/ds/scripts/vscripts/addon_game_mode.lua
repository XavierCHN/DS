print "\nDire Stone @ XavierCHN \n\n Loading...\n\n"

-- alias
ConVars = Convars -- always got a syntax error, this will fix it, lol

require 'direstone'
require 'utils.test'

function PreCache(context)
end

function Activate()
    GameRules.DS = DS()
    GameRules.DS:Init()
end
