-- Lua list class for dota2 modding
-- author: XavierCHN
-- date: 2016.08
-- Usage
-- list = List()
-- list:AddHead(data) -- return node
-- list:AddRear(data) -- return node
-- list:Insert(position, data) -- return node
-- list:Remove(position) -- return data
-- list:GetData(position) -- return data
-- list:Clear() -- return void
-- list:Display() -- return void
-- list:Count() -- return number
-- list:Swap(i,j) -- return void
-- list:GetNodeAt(i) -- return node

-- head{next=ele1} ele1{data=, next=ele2} ele2{data=, next=nil}

if not class then require 'class' end

if List == nil then
    List = class({})
end

function List:constructor()
    self.tail = {}
    self.head = self.tail
    self.head.next = nil
    self.count = 0
end

function List:AddHead(d)
    local nn = {}
    nn.data = d
    nn.next = self.head.next
    self.head.next = nn
    self.count = self.count + 1 
    return nn
end

function List:AddRear(d)
    local nn = {}
    nn.data = d
    self.tail.next = nn
    self.tail = nn
    self.count = self.count + 1
    return nn
end

function List:Display()
    local n = self.head.next
    i = 0
    while n do
        i = i + 1
        -- print("List",i,n.data)
        n = n.next
    end
    -- print("---- list display finished ---")
end

function List:GetNodeAt(i)
    local n = self.head
    for i = 1, i do
        if n then
            n = n.next
        else
            -- print("Get node overflow @",i)
            return nil
        end
    end
    return n
end

function List:Remove(i)
    local node = self:GetNodeAt(i-1)
    if not node or node.next == nil then
        -- print("Remove node overflow @",i)
        return nil
    end
    local t = node.next
    node.next = t.next
    self.count = self.count - 1
    return t.data
end

function List:Insert(i, data)
    local node = self:GetNodeAt(i-1)
    if not node then
        -- print("Insert node overflow@",i)
        return
    end
    local nn = {}
    nn.data = data
    nn.next = node.next
    node.next = nn
    self.count = self.count + 1
end

function List:Clear()
    while true do
        local n = self.head.next
        if not n then
            break
        end
        local t = n.next
        self.head.next = nil
        self.head.next = t
    end
    self.count = 0
end

function List:Count()
    return self.count
end

function List:Swap(i,j)
    local n1 = self:GetNodeAt(i)
    local n2 = self:GetNodeAt(j)
    if not ( n1 and n2 ) then
        -- print("Swap overflow @",i,j)
        return
    end
    n1.data, n2.data = n2.data, n1.data
end

function List:GetData(i)
    local n = self:GetNodeAt(i)
    if n then
        return n.data
    else
        -- print("GetData overflow @",i)
    end
end