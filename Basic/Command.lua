(function()
    local Command = {};
    function Command:constructor()
        self.sendbuffer = {};
        self.receivbBuffer = {};

        self.methods = {};
    end

    function Command:register(name,fun)
        self.methods[name] = fun;
    end

    IKit.Create(Command,"Command");
end)();

(function()
    local  ServerCommand = {};
    
    function ServerCommand:constructor()
        self.super();

        local OnPlayerSignalId = 0;
        function self:connection()
            OnPlayerSignal = Event:addEventListener("OnPlayerSignal",function(player,signal)
                self:OnPlayerSignal(player,signal);
            end);
        end

        function self:disconnect()
            Event:detachEventListener("OnPlayerSignal",OnPlayerSignalId);
        end
        self:connection();
    end

    function ServerCommand:OnPlayerSignal(player,signal)
        if signal == -1 then
            
        else
            if self.receivbBuffer[player.name] == nil then
                self.receivbBuffer[player.name] = {};
            end
            table.insert(self.receivbBuffer[player.name],signal);
        end
    end

    function ServerCommand:sendMessage(player,message)
        local message = IKit.New("String",message):toBytes();
        for i = 1, #message, 1 do
            player:Signal(message[i]);
            -- table.insert(self.sendbuffer,message[i]);
        end
        player:Signal(4);
        -- table.insert(self.sendbuffer,-1);
    end

    function ServerCommand:execute(player,name,args)
        self.methods[name](player,args);
    end

    IKit.Create(ServerCommand,"ServerCommand","Command");
end)();

(function()
    local  ClientCommand = {};
    
    function ClientCommand:constructor()
        self.super();

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

    function ClientCommand:OnSignal(signal)
        if signal == 4 then
            local command = IKit.New("String",self.receivbBuffer);

            local args = {IKit.New("String")};
            for i = 1, command.length, 1 do
                if command:charAt(i) == ' ' then
                    if args[#args].length > 0 then
                        table.insert(args,IKit.New("String"));
                    end
                else
                    args[#args]:insert(command:charAt(i));
                end
            end

            self:execute(args);
            self.receivbBuffer = {};
        else
            table.insert(self.receivbBuffer,signal);
        end
    end

    --当传出信号值为4时表示传输结束
    function ClientCommand:sendMessage(message,player)
        local message = IKit.New("String",message):toBytes();
            for i = 1, #message, 1 do
                UI.Signal(message[i]);
                -- table.insert(self.sendbuffer,message[i]);
            end
            UI.Signal(4);
            -- table.insert(self.sendbuffer,-1);
    end

    function ClientCommand:execute(args)
        local name = args[1];
        table.remove(args,1);
        self.methods[name:toString()](args);
    end

    IKit.Create(ClientCommand,"ClientCommand","Command");
end)();

if Game ~= nil then
    Command = IKit.New("ServerCommand");
end

if UI ~= nil then
    Command = IKit.New("ClientCommand");
end