--[[
    自定义的事件管理器
    主要是用来给自定义的modifier的触发使用的
    例如 OnTurnStart
]]

if Events == nil then Events = class({}) end

function Events:constructor()
    self.all_events = {}
end

function Events:RegisterListener(event_name, callback)
    self.all_events[event_name] = self.all_events[event_name] or {}
    table.insert(self.all_events[event_name], callback) 
end

function Events:Emit(event_name, args)
    if self.all_events[event_name] then
        for _, func in pairs(self.all_events[event_name]) do
            if type(func) == "function" then
                func(args)
            end
        end
    end
end
