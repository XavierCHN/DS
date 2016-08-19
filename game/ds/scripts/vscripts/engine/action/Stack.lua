if Stack == nil then 
    Stack = class({}) 
    GameRules.Stack = Stack()
end

function Stack:constructor()
    self.vObjects = {}
end

function Stack:ProcNext()
end