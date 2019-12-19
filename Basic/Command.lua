(function()
    local Command = {};
    function Command:constructor()
        self.whoami = "unknow";

        self.sendbuffer = {};
        self.receivbBuffer = {};

        self.methods = {};

        local OnSignalId = 0;
        local OnPlayerSignalId = 0;

        function self:connection()
            if Game ~= nil then
                self.whoami = "server";
                OnSignalId = Event:addEventListener("OnSignal",function(signal)
                    self:OnSignal(signal);
                end);
            end
            if UI ~= nil then
                self.whoami = "client";
                OnPlayerSignal = Event:addEventListener("OnPlayerSignal",function(player,signal)
                    self:OnPlayerSignal(player,signal);
                end);
            end
        end

        function self:disconnect()
            if UI ~= nil then
                Event:detachEventListener("OnSignal",OnSignalId);
            end
            if Game ~= nil then
                Event:detachEventListener("OnPlayerSignal",OnPlayerSignalId);
            end
        end

        self:connection();
    end

    function Command:OnSignal(signal)
        if signal == -1 then
            
        else
            table.insert(self.receivbBuffer,signal);
        end
    end

    function Command:OnPlayerSignal(player,signal)
        if signal == -1 then
            
        else
            if self.receivbBuffer[player.name] == nil then
                self.receivbBuffer[player.name] = {};
            end
            table.insert(self.receivbBuffer[player.name],signal);
        end
    end

    function Command:register(name,fun)
        self.methods[name] = fun;
    end

    function Command:execute(player,name,args)
        if self.whoami == "server" then
            self.methods[name](player,args);
        end
        if self.whoami == "clent" then
            self.methods[name](args);
        end
    end

    function Command:sendMessage(message)
        local message = IKit.New("String",message):toBytes();
        for i = 1, #message, 1 do
            table.insert(self.sendbuffer,message[i]);
        end
        table.insert(self.sendbuffer,-1);
    end

    IKit.Create(Command,"Command");
end)();

Command = IKit.New("Command");