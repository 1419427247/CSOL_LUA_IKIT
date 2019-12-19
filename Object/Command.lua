(function()
    local Command = {};
    function Command:constructor()
        self.sendbuffer = {};
        self.receivbBuffer = {};

        self.methods = {};

        local OnSignalId = 0;
        function self:connection()
            OnSignalId = Event:addEventListener("OnSignal",function(signal)
                self:OnSignal(signal);
            end);
        end
        function self:disconnect()
            Event:detachEventListener("OnSignal",OnSignalId);
        end
        self:connection();
    end

    function Command:OnSignal(signal)
        if signal == -1 then
            
        else
            table.insert(self.receivbBuffer,signal);
        end
    end

    function Command:register(name,fun)
        self.methods[name] = fun;
    end

    function Command:execute(name,args)
        self.methods[name](args);
    end

    function Command:sendMessage(message)
        local message = New("String",message):toBytes();
        for i = 1, #message, 1 do
            table.insert(self.sendbuffer,message[i]);
        end
        table.insert(self.sendbuffer,-1);
    end

    Create(Command,"Command");
end)();