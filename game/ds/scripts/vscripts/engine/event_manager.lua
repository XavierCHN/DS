if EventManager == nil then EventManager = class({}) end

function EventManager:constructor()
    self.all_events = {}
end

function EventManager:Emit(event_name, args)
    if self.all_events[event_name] then
        for _, callback in pairs(self.all_events[event_name]) do
            callback(args)
        end
    end
end

function EventManager:Register(event_name, callback)
    self.all_events[event_name] = self.all_events[event_name] or {}
    table.insert(self.all_events[event_name], callback) 
end