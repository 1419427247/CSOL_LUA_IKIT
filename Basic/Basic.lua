--基础工具库,包含了基础的面向对象,事件处理,字符串与计时器,写的太烂了,实在抱歉QWQ

IKit = (function()
    local class = {};

    --local interface = {};

    local classtree = {};

    local call = function(table,...)
        table:constructor(...);
    end;

    local newindex = function(table,key,value)
        local tobject = table;
        while tobject ~= nil do
            for k in pairs(tobject) do
                if key == k then
                    rawset(tobject,key,value);
                    return;
                end
            end
            tobject = getmetatable(tobject);
        end
        rawset(table,key,value);
    end

    local basic = {
        __newindex = newindex,
        __call = call,
    };

    class["Object"] = {
        type = "Object",
        __newindex = newindex,
        __call = call,
    };

    classtree["Object"] = nil;

    local function instanceof(value,string)
        if type(value) == "table" and  type(string) == "string" then
            local ttype = value.type;
            while ttype ~= nil do
                if ttype == string then
                    return true;
                end
                ttype = classtree[ttype];
            end
        end
        return false;
    end

    local function clone(talbe)
        local object = {};
        for key, value in pairs(talbe) do
            object[key] = value;
        end
        object.__index = object;
        if getmetatable(talbe) ~= nil then
            object.super = clone(getmetatable(talbe))
            object.__newindex = object.super.__newindex;
            object.__call = object.super.__call;
            setmetatable(object,object.super);
        else
            setmetatable(object,basic);
        end
        return object;
    end

    local function createclass(object,name,father)
        if object.constructor == nil then
            function object:constructor()
            end
        end

        if father ~= nil then
            setmetatable(object,class[father]);
            classtree[name]=father;
        else
            setmetatable(object,class["Object"]);
            classtree[name]="Object";
        end
        class[name] = object;
    end

    local function createinterface(object,name,father)
        
    end
    
    local newindex = function(table,key,value)
        local tobject = table;
        while tobject ~= nil do
            for k in pairs(tobject) do
                if key == k then
                    rawset(tobject,key,value);
                    return;
                end
            end
            tobject = getmetatable(tobject);
        end
        error("没有找到字段'" .. key .. "'在'" .. table.type .."'内");
    end

    local function new(name,...)
        local object = clone(class[name]);
        object.type = name;
        object:constructor(...);
        local tobject = object;
        while tobject ~= nil do
            rawset(tobject,"__newindex",newindex);
            tobject = getmetatable(tobject);
        end
        return setmetatable({},object);
    end

    return {
        Class = createclass,
        New = new,
        Instanceof = instanceof,
    }
end)();
IKit.iif = function (arg1, arg2, arg3)
    if arg1 == true then
        return arg2;
    end
    return arg3
end

(function()
    local function charSize(curByte)
        local seperate = {0, 0xc0, 0xe0, 0xf0}
        for i = #seperate, 1, -1 do
            if curByte >= seperate[i] then return i end
        end
        return 1
    end
    local String = {};

    function String:constructor(value)
        self.array = {};
        --字符串的长度,请不要直接修改它
        self.length = 0;
        self:insert(value);
    end

    function String:charAt(index)
        if index > 0 and index <= self.length then
            return self.array[index];
        end
        error("数组下标越界");
    end

    --截取一段字符并返回它
    function String:substring(beginindex,endindex)
        local text = IKit.New("String");
        for i = beginindex, endindex, 1 do
            text:insert(self.array[i]);
        end
        return text;
    end

    --当前字符串长度是否为0
    function String:isEmpty()
        return self.length == 0;
    end

    --在第pos处插入字符串value,pos若为空则在末尾添加字符串value
    function String:insert(value,pos)
        pos = pos or self.length + 1;
        if type(value) == "string" then
            local currentIndex = 1;
            while currentIndex <= #value do
                local cs = charSize(string.byte(value, currentIndex));
                if pos > self.length then
                    self.array[#self.array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
                else
                    table.insert(self.array,pos,string.sub(value,currentIndex,currentIndex+cs-1));
                end
                currentIndex = currentIndex + cs;
                self.length = self.length + 1;
                pos = pos + 1;
            end
        elseif type(value) == "table" then
            if value.type == "String" then
                for i = 1, value.length, 1 do
                    if pos > self.length then
                        self.array[#self.array+1] = value.array[i];
                    else
                        table.insert(self.array,pos,value.array[i]);
                    end
                    pos = pos + 1;
                end
                self.length = self.length +  value.length;
            else
                local currentIndex = 1;
                while currentIndex <= #value do
                    local cs = charSize(value[currentIndex])
                    if pos > self.length then
                        if cs == 1 then
                            self.array[#self.array+1] = string.char(value[currentIndex]);
                        elseif cs == 2 then
                            self.array[#self.array+1] = string.char(value[currentIndex],value[currentIndex+1]);
                        elseif cs == 3 then
                            self.array[#self.array+1] = string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2]);
                        elseif cs == 4 then
                            self.array[#self.array+1] = string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2],value[currentIndex+3]);
                        end
                    else
                        if cs == 1 then
                            table.insert(self.array,pos,string.char(value[currentIndex]));
                        elseif cs == 2 then
                            table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1]));
                        elseif cs == 3 then
                            table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2]));
                        elseif cs == 4 then
                            table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2],value[currentIndex+3]));
                        end
                    end
                    currentIndex = currentIndex+cs;
                    self.length = self.length + 1;
                    pos = pos + 1;
                end
            end
        end
    end

    --移除第pos个字符
    function String:remove(pos)
        if pos > 0 or pos <= self.length then
            table.remove(self.array,pos);
            self.length = self.length - 1;
        else
            error("数组下标越界");
        end
    end

    --清除所有字符
    function String:clean()
        self.array = {};
        self.length = 0;
    end

    --将字符串转换为byte数组
    function String:toBytes()
        local bytes = {};
        for i = 1, self.length, 1 do
            for j = 1, #self.array[i], 1 do
                table.insert(bytes,string.byte(self.array[i],j));
            end
        end
        return bytes;
    end
    
    --字符串转数字
    function String:toNumber()
        local sum = 0;
        local neg = false;
        local float = false;
        local s = 10;

        local i = 1;
        if self.array[1] == '-' then
            neg = true;
            i = 2;
        end
        while i <= #self.array do
            if self.array[i] == '.' then
                float = true;
            else
                if float == false then
                    sum = sum * 10 + string.byte(self.array[i]) - 48;
                else
                    sum = sum + (string.byte(self.array[i]) - 48) / s;
                    s = s * 10;
                end
            end
            i = i + 1;
        end
        if neg == true then
            sum = sum * -1;
        end
        return sum;
    end
    --转默认字符串
    function String:toString()
        return table.concat(self.array);
    end

    --重载#运算符,返回字符串的长度
    function String:__len()
        return self.length;
    end

    --重载==运算符,比较2字符串是否相等
    function String:__eq(value)
        return self.length == value.length and function()
            for i = 1, self.length, 1 do
                if self.array[i] ~= value.array[i] then
                    return false;
                end
            end
            return true;
        end
    end
    --重载+运算符
    function String:__add(value)
        self:insert(value);
        return self;
    end
    --重载..运算符,返回一个合并后新的字符串
    function String:__concat(value)
        local str1 = IKit.New("String",self);
        str1:insert(value);
        return str1;
    end
    -- --重载()运算符
    -- function String:__call(index)
    --     return self.array[index];
    -- end

    IKit.Class(String,"String");
end)();

(function()
    local Event = {};

    function Event:constructor()
        self.array = {};
        self.id = 1;
    end

    function Event:__add(name)
        if not self.array[name] then
            self.array[name] = {};
            return self;
        end
        error("事件:''" ..name.. "'已经存在,请勿重复添加");
    end

    function Event:__sub(name)
        if self.array[name] then
            self.array[name] = nil;
            return self;
        end
        error("事件:'" ..name.."'不存在");
    end

    function Event:addEventListener(name,event)
        if self.array[name] == nil then
            error("未找到事件'" .. name .. "'");
        end
        if type(event) == "function" then
            self.array[name][#self.array[name] + 1] = {self.id,event};
            self.id = self.id + 1;
            return self.id - 1;
        else
            error("它应该是一个函数");
        end
    end

    function Event:detachEventListener(name,id)
        if self.array[name] == nil then
            error("未找到'" .. name .. "'");
        end
        for i = 1, #self.array[name],1 do
            if self.array[name][i][1] == id then
                table.remove(self.array[name],i);
                return;
            end
        end
        error("未找到'" .. id .. "'在Event[" .. name .."]内");
    end

    function Event:forEach(name,...)
        for i = #self.array[name],1,-1 do
            self.array[name][i][2](...);
        end
    end

    IKit.Class(Event,"Event");
end)();

(function()
    local Timer = {};

    function Timer:constructor()
        self.id = 1;
        self.task = {};
        Event:addEventListener("OnUpdate",function(time)
            self:OnUpdate(time);
        end);
    end

    function Timer:OnUpdate(time)
        local i = 1;
        while i <= #self.task do
            if self.task[i].time < time then
                if not pcall(self.task[i].func) then
                    table.remove(self.task,i);
                    print("Timer:ID为:[" .. self.task[i].id .. "]的函数发生了异常");
                elseif self.task[i].period == nil then
                    table.remove(self.task,i);
                else
                    self.task[i].time = time + self.task[i].period;
                end
            end
            i = i + 1;
        end
    end

    function Timer:schedule(fun,delay,period)
        if Game ~= nil then
            self.task[#self.task+1] = {id = self.id,func = fun,time = Game.GetTime() + delay,period = period};
        end
        if UI ~= nil then
            self.task[#self.task+1] = {id = self.id,func = fun,time = UI.GetTime() + delay,period = period};
        end
        self.id = self.id + 1;
        return self.id - 1;
    end

    function Timer:find(id)
        for i = 1, #self.task, 1 do
            if self.task[i].id == id then
                return self.task[i];
            end
        end
        return nil;
    end

    function Timer:cancel(id)
        for i = 1, #self.task, 1 do
            if self.task[i].id == id then
                table.remove(self.task,i);
                return;
            end
        end
    end
    function Timer:purge()
        self.task = {}
    end

    IKit.Class(Timer,"Timer");
end)();

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

    IKit.Class(Command,"Command");
end)();

(function()
    local ServerCommand = {};
    
    function ServerCommand:constructor()
        self.super();
        local OnPlayerSignalId = 0;
        function self:connection()
            OnPlayerSignalId = Event:addEventListener("OnPlayerSignal",function(player,signal)
                self:OnPlayerSignal(player,signal);
            end);
        end

        function self:disconnect()
            Event:detachEventListener("OnPlayerSignal",OnPlayerSignalId);
        end
        self:connection();
    end

    function ServerCommand:OnPlayerSignal(player,signal)
        if signal == 4 then
            local command = IKit.New("String",self.receivbBuffer[player.name]);

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

            self:execute(player,args);
            self.receivbBuffer[player.name] = {};
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

    function ServerCommand:execute(player,args)
        local name = args[1];
        table.remove(args,1);
        self.methods[name:toString()](player,args);
    end

    IKit.Class(ServerCommand,"ServerCommand","Command");
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
    function ClientCommand:sendMessage(message)
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

    IKit.Class(ClientCommand,"ClientCommand","Command");
end)();

Event = IKit.New("Event");

if Game~=nil then
    Event = Event
    + "OnPlayerConnect"
    + "OnPlayerDisconnect"
    + "OnRoundStart"
    + "OnRoundStartFinished"
    + "OnPlayerSpawn"
    + "OnPlayerJoiningSpawn"
    + "OnPlayerKilled"
    + "OnKilled"
    + "OnPlayerSignal"
    + "OnUpdate"
    + "OnPlayerAttack"
    + "OnTakeDamage"
    + "CanBuyWeapon"
    + "CanHaveWeaponInHand"
    + "OnGetWeapon"
    + "OnReload"
    + "OnReloadFinished"
    + "OnSwitchWeapon"
    + "PostFireWeapon"
    + "OnGameSave"
    + "OnLoadGameSave"
    + "OnClearGameSave";

    function Game.Rule:OnPlayerConnect (player)
        Event:forEach("OnPlayerConnect",player);
    end
    
    function Game.Rule:OnPlayerDisconnect (player)
        Event:forEach("OnPlayerDisconnect",player);
    end
    
    function Game.Rule:OnRoundStart ()
        Event:forEach("OnRoundStart");
    end
    
    function Game.Rule:OnRoundStartFinished ()
        Event:forEach("OnRoundStartFinished");
    end
    
    function Game.Rule:OnPlayerSpawn (player)
        Event:forEach("OnPlayerSpawn",player);
    end
    
    function Game.Rule:OnPlayerJoiningSpawn (player)
        Event:forEach("OnPlayerJoiningSpawn",player);
    end
    
    function Game.Rule:OnPlayerKilled (victim, killer, weapontype, hitbox)
        Event:forEach("OnPlayerKilled",victim, killer, weapontype, hitbox);
    end
    
    function Game.Rule:OnKilled (victim, killer)
        Event:forEach("OnKilled",victim,killer);
    end
    
    function Game.Rule:OnPlayerSignal (player,signal)
        Event:forEach("OnPlayerSignal",player,signal);
    end
    
    function Game.Rule:OnUpdate (time)
        Event:forEach("OnUpdate",time);
    end
    
    function Game.Rule:OnPlayerAttack (victim, attacker, damage, weapontype, hitbox)
        Event:forEach("OnPlayerAttack",victim, attacker, damage, weapontype, hitbox);
    end
    
    function Game.Rule:OnTakeDamage (victim, attacker, damage, weapontype, hitbox)	
        Event:forEach("OnTakeDamage",victim, attacker, damage, weapontype, hitbox);
    end
    
    function Game.Rule:CanBuyWeapon (player, weaponid)
        Event:forEach("CanBuyWeapon",player,weaponid);
    end
    
    function Game.Rule:CanHaveWeaponInHand (player, weaponid, weapon)
        Event:forEach("CanHaveWeaponInHand",player, weaponid, weapon);
    end
    
    function Game.Rule:OnGetWeapon (player, weaponid, weapon)
        Event:forEach("OnGetWeapon",player, weaponid, weapon);
    end
    
    function Game.Rule:OnReload (player, weapon, time)
        Event:forEach("OnPlayerConnect",player, weapon, time);
    end
    
    function Game.Rule:OnReloadFinished (player, weapon)
        Event:forEach("OnPlayerConnect",player, weapon);
    end
    
    function Game.Rule:OnSwitchWeapon (player)
        Event:forEach("OnPlayerConnect",player);
    end
    
    function Game.Rule:PostFireWeapon (player, weapon, time)
        Event:forEach("OnPlayerConnect",player, weapon, time);
    end
    
    function Game.Rule:OnGameSave (player)
        Event:forEach("OnPlayerConnect",player);
    end
    
    function Game.Rule:OnLoadGameSave (player)
        Event:forEach("OnPlayerConnect",player);
    end
    
    function Game.Rule:OnClearGameSave (player)
        Event:forEach("OnPlayerConnect",player);
    end
end

if UI~=nil then
    Event = Event
    + "OnRoundStart"
    + "OnSpawn"
    + "OnKilled"
    + "OnInput"
    + "OnUpdate"
    + "OnChat"
    + "OnSignal"
    + "OnKeyDown"
    + "OnKeyUp"
    
    function UI.Event:OnRoundStart()
        Event:forEach("OnRoundStart");
    end

    function UI.Event:OnSpawn()
        Event:forEach("OnSpawn");
    end

    function UI.Event:OnKilled()
        Event:forEach("OnKilled");
    end

    function UI.Event:OnInput (inputs)
        Event:forEach("OnInput",inputs);
    end

    function UI.Event:OnUpdate(time)
        Event:forEach("OnUpdate",time);
    end

    function UI.Event:OnChat (text)
        Event:forEach("OnChat",text);
    end

    function UI.Event:OnSignal(signal)
        Event:forEach("OnSignal",signal);
    end

    function UI.Event:OnKeyDown(inputs)
        Event:forEach("OnKeyDown",inputs);
    end

    function UI.Event:OnKeyUp (inputs)
        Event:forEach("OnKeyUp",inputs);
    end
end

Timer = IKit.New("Timer");

if Game ~= nil then
    Command = IKit.New("ServerCommand");
end

if UI ~= nil then
    Command = IKit.New("ClientCommand");
end