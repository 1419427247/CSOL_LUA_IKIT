(function()
    local Event = {};

    function Event:constructor()
        self.id = 1;
    end

    function Event:__add(name)
        if not self[name] then
            self[name] = {};
            return self;
        end
        error("Event: '" ..type.."' already exists");
    end

    function Event:__sub(name)
        if self[name] then
            self[name] = nil;
            return self;
        end
        error("Event: '" ..name.."' does not exist");
    end

    function Event:addEventListener (name,event)
        if type(event) == "function" then
            self[name][self.id] = event;
            self.id = self.id + 1;
            return self.id - 1;
        else
            error("It is not a function");
        end
    end;

    function Event:detachEventListener(name,id)
        self[name][id] = nil;
    end;

    function Event:forEach(name,...)
        for key, value in pairs(self[name]) do
            value(...)
        end
    end

    Create(Event,"Event");
end)();


Event = New("Event");
Event = Event 
    + "OnKeyDown"
    + "OnKeyUp"
    + "OnSignal"
    + "OnUpdate";