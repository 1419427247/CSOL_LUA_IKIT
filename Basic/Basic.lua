--基础工具库,包含了基础的面向对象,事件处理,字符串与计时器,写的太烂了,实在抱歉QWQ
IKit = (function()
    local CLASS = {};
    local INTERFACES = {};

    local Interface = function(_name,_method,_super)
        if INTERFACES[_name] ~= nil then
            error("接口'".. _name .."'重复定义");
        end
        if _super ~= nil then
            if INTERFACES[_super] == nil then
                error("未找到接口'".. _super .."'");
            end
            for i = 1, #INTERFACES[_super],1 do
                _method[#_method + 1] = INTERFACES[_super][i];
            end
        end
        INTERFACES[_name] = _method;
    end

    local Class = function(_table,_name,_super)
        if CLASS[_name] ~= nil then
            error("类'".. _name .."'重复定义");
        end

        _super = _super or {}
        _super.extends = _super.extends or "Object";
        _super.implements = _super.implements or {};

        for i = 1, #_super.implements, 1 do
            for j = 1, #INTERFACES[_super.implements[i]],1 do
                if rawget(_table,INTERFACES[_super.implements[i]][j]) == nil then
                    error("未实现接口'" .. _super.implements[i] .. "'中的方法:" .. INTERFACES[_super.implements[i]][j]);
                end
            end
        end

        CLASS[_name] = {
            Table = _table,
            Super = _super.extends,
            Interface = _super.implements;
        };
    end

    local function _CALL(table,...)
        table:constructor(...);
    end

    local function _NEWINDEX(table,key,value)
        if value == nil then
            error("不可将字段设置为nil");
        end
        local temporary = table;
        if key == "type" and temporary.type ~= "nil" then
            error("type不可修改");
        end
        while table ~= nil do
            for k in pairs(table) do
                if key == k then
                    rawset(table,key,value);
                    return;
                end
            end
            table = getmetatable(table);
        end
        if temporary.type == "nil" then
            rawset(temporary,key,value);
        else
            error("没有找到字段'" .. key .. "'在'" .. temporary.type .."'内");
        end
    end

    CLASS["Object"] = {
        Table = {
            memory = {};
            type = "nil",
            __call = _CALL,
            __newindex = _NEWINDEX,
        },
        Super = "nil",
        Interface = "nil",
    }

    local function Clone(_name)
        if CLASS[_name] == nil then
            error("没有找到类'" .. _name .. "'");
        end
        local object = {};
        for key, value in pairs(CLASS[_name].Table) do
            object[key] = value;
        end
        object.__index = object;
        if CLASS[_name].Super ~= "nil" then
            object.super = Clone(CLASS[_name].Super)
            object.__newindex = object.super.__newindex;
            object.__call = object.super.__call;
            setmetatable(object,object.super);
        end
        return object;
    end

    local New = function(_name,...)
        local object = Clone(_name);
        object(...);
        object.type = _name;
        return setmetatable({},object);
    end

    local function Instanceof(_object,_name)
        if type(_object) == "table" and  type(_name) == "string" and (CLASS[_name] ~= nil or INTERFACES[_name] ~= nil) then
            if INTERFACES[_name] ~= nil then
                local type = _object.type;
                while type ~= nil do
                    if type == _name then
                        return true;
                    end
                    type = CLASS[type].Super;
                end
            end
            if INTERFACES[_name] ~= nil then
                for i = 1, INTERFACES[_name], 2 do
                    if rawget(_object,INTERFACES[_name][i]) == nil then
                        return false;
                    end
                end
                return true;
            end
        end
        return false;
    end
    local function TypeOf(value)
        if type(value) == "table" then
            if value.type ~= nil then
                return value.type;
            end
        end
        return type(value);
    end
    return{
        Interface = Interface,
        Class = Class,
        New = New,
        Instanceof = Instanceof,
        TypeOf = TypeOf
    };
end)();

CLASS = (function()
    NULL = {};
    local CLASS = {};
    CLASS["Object"] = {
        TABLE = {
            type = "Object",
            super = nil,
            __call = function (table,...)
                table:constructor(...);
            end,
            __newindex = function(table,key,value)
                if value == nil then
                    error("不可将字段设置为nil");
                end
                local temporary = table;
                if key == "type" and temporary.type ~= nil then
                    error("type不可修改");
                end
                while table ~= nil do
                    for k in pairs(table) do
                        if key == k then
                            rawset(table,key,value);
                            return;
                        end
                    end
                    table = getmetatable(table);
                end
                rawset(temporary,key,value);
            end,
        },
        SUPER = NULL,
        TYPE = "Object",
    }

    local function CLONE(_table)
        local object = {};
        for key, value in pairs(_table.TABLE) do
            object[key] = value;
        end
        object.__index = object;
        if _table.SUPER ~= NULL then
            object.super = CLONE(_table.SUPER)
            object.type = _table.TYPE;
            object.__call = object.super.__call;
            object.__newindex = object.super.__newindex;
            setmetatable(object,object.super);
        end
        return object;
    end

    local function NEW(_name,...)
        if CLASS[_name] == nil then
            error("没有找到类:" .. _name);
        end
        local object = CLONE(CLASS[_name]);
        object(...);
        rawset(object,"type",_name);
        return setmetatable({},object);
    end

    local function CREATECLASS(_name,_function,_super)
        _super = (_super or {Name = "Object"}).Name;

        if CLASS[_name] ~= nil then
            error("类'".. _name .."'重复定义");
        end
        if CLASS[_super] == nil then
            error("没有找到类:" .. _super);
        end

        local object = {};
        _function(object);

        CLASS[_name] = {
            TABLE = object,
            SUPER = CLASS[_super],
            TYPE = _name,
        };
        _G[_name] = {
            Name = _name;
            New = function(self,...)
                return NEW(self.Name,...);
            end
        };

    end
    return CREATECLASS;
end)();



CLASS("String",function(String)

    local function charSize(curByte)
        local seperate = {0, 0xc0, 0xe0, 0xf0}
        for i = #seperate, 1, -1 do
            if curByte >= seperate[i] then return i end
        end
        return 1
    end

    function String:constructor(value)
        self.array = {};
        self.length = 0;
        self:insert(value);
    end

    function String:charAt(index)
        if index > 0 and index <= self.length then
            return self.array[index];
        end
        error("数组下标越界");
    end

    function String:substring(beginindex,endindex)
        local text = IKit.New("String");
        for i = beginindex, endindex, 1 do
            text:insert(self.array[i]);
        end
        return text;
    end

    function String:isEmpty()
        return self.length == 0;
    end

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

    function String:remove(pos)
        if pos > 0 or pos <= self.length then
            table.remove(self.array,pos);
            self.length = self.length - 1;
        else
            error("数组下标越界");
        end
    end

    function String:clean()
        self.array = {};
        self.length = 0;
    end

    function String:toBytes()
        local bytes = {};
        for i = 1, self.length, 1 do
            for j = 1, #self.array[i], 1 do
                table.insert(bytes,string.byte(self.array[i],j));
            end
        end
        return bytes;
    end
    
    function String:toNumber()
        tonumber(self:toString());
    end

    function String:toString()
        return table.concat(self.array);
    end

    function String:__tostring()
        return self:toString();
    end

    function String:__len()
        return self.length;
    end

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

    function String:__add(value)
        self:insert(value);
        return self;
    end

    function String:__concat(value)
        local str1 = IKit.New("String",self);
        str1:insert(value);
        return str1;
    end
end);


-- (function()
--     local Event = {};

--     function Event:constructor()
--         self.array = {};
--         self.id = 1;
--     end

--     function Event:__add(name)
--         if not self.array[name] then
--             self.array[name] = {};
--             return self;
--         end
--         error("事件:''" ..name.. "'已经存在,请勿重复添加");
--     end

--     function Event:__sub(name)
--         if self.array[name] then
--             self.array[name] = nil;
--             return self;
--         end
--         error("事件:'" ..name.."'不存在");
--     end

--     function Event:addEventListener(name,event)
--         if self.array[name] == nil then
--             error("未找到事件'" .. name .. "'");
--         end
--         if type(event) == "function" then
--             self.array[name][#self.array[name] + 1] = {self.id,event};
--             self.id = self.id + 1;
--             return self.id - 1;
--         else
--             error("它应该是一个函数");
--         end
--     end

--     function Event:detachEventListener(name,id)
--         if self.array[name] == nil then
--             error("未找到'" .. name .. "'");
--         end
--         for i = 1, #self.array[name],1 do
--             if self.array[name][i][1] == id then
--                 table.remove(self.array[name],i);
--                 return;
--             end
--         end
--         error("未找到'" .. id .. "'在Event[" .. name .."]内");
--     end

--     function Event:forEach(name,...)
--         for i = #self.array[name],1,-1 do
--             self.array[name][i][2](...);
--         end
--     end

--     IKit.Class(Event,"Event");
-- end)();

-- (function()
--     local Timer = {};

--     function Timer:constructor()
--         self.id = 1;
--         self.task = {};
--         Event:addEventListener("OnUpdate",function(time)
--             self:OnUpdate(time);
--         end);
--     end

--     function Timer:OnUpdate(time)
--         for key, value in pairs(self.task) do
--             if value.time < time then
--                 if not pcall(value.func) then
--                     self.task[key] = nil;
--                     print("Timer:ID为:[" .. key .. "]的函数发生了异常");
--                 elseif value.period == nil then
--                     self.task[key] = nil;
--                 else
--                     value.time = time + value.period;
--                 end
--             end
--         end
--     end

--     function Timer:schedule(fun,delay,period)
--         if Game ~= nil then
--             self.task[self.id] = {func = fun,time = Game.GetTime() + delay,period = period};
--         end
--         if UI ~= nil then
--             self.task[self.id] = {func = fun,time = UI.GetTime() + delay,period = period};
--         end
--         self.id = self.id + 1;
--         return self.id - 1;
--     end

--     function Timer:find(id)
--         for i = 1, #self.task, 1 do
--             if self.task[i].id == id then
--                 return self.task[i];
--             end
--         end
--         return nil;
--     end

--     function Timer:cancel(id)
--         for key, value in pairs(self.task) do
--             if id == key then
--                 self.task[key] = nil;
--                 return;
--             end
--         end
--     end
    
--     function Timer:purge()
--         self.task = {}
--     end

--     IKit.Class(Timer,"Timer");
-- end)();

-- (function()
--     local Command = {};
--     function Command:constructor()
--         self.sendbuffer = {};
--         self.receivbBuffer = {};
--         self.methods = {};

--     end

--     function Command:register(name,fun)
--         self.methods[name] = fun;
--     end

--     IKit.Class(Command,"Command");
-- end)();

-- (function()
--     local ServerCommand = {};
    
--     function ServerCommand:constructor()
--         self.super();
--         self.syncValue = Game.SyncValue:Create("SCValue");
--         Event:addEventListener("OnUpdate",function()
--             self:OnUpdate();
--         end);
--         Event:addEventListener("OnPlayerSignal",function(player,signal)
--             self:OnPlayerSignal(player,signal);
--         end);
--     end

--     function ServerCommand:OnUpdate()
--         local k = 0;
--         while #self.sendbuffer > 0 do
--             while #self.sendbuffer[1][2] > 0 do
--                 self.sendbuffer[1][1]:Signal(self.sendbuffer[1][2][1]);
--                 table.remove(self.sendbuffer[1][2],1);
--                 k = k + 1;
--                 if k == 1024 then
--                     return;
--                 end
--             end
--             if #self.sendbuffer[1][2] == 0 then
--                 table.remove(self.sendbuffer,1);
--             end
--         end
--     end

--     function ServerCommand:OnPlayerSignal(player,signal)
--         if signal == 4 then
--             local command = IKit.New("String",self.receivbBuffer[player.name]);
--             self:execute(player,command);
--             self.receivbBuffer[player.name] = {};
--         else
--             if self.receivbBuffer[player.name] == nil then
--                 self.receivbBuffer[player.name] = {};
--             end
--             table.insert(self.receivbBuffer[player.name],signal);
--         end
--     end

--     function ServerCommand:sendMessage(message,player)
--         if player ~= nil then
--             local bytes = IKit.New("String",message):toBytes();
--             bytes[#bytes+1] = 4;
--             table.insert(self.sendbuffer,{player,bytes});
--         else
--             syncValue.value = message;
--         end
--     end

--     function ServerCommand:execute(player,command)
--         local args = {IKit.New("String")};
--         for i = 1, command.length, 1 do
--             if command:charAt(i) == ' ' then
--                 if args[#args].length > 0 then
--                     table.insert(args,IKit.New("String"));
--                 end
--             else
--                 args[#args]:insert(command:charAt(i));
--             end
--         end
--         if args[#args].length == 0 then
--             table.remove(args,#args);
--         end
--         local name = args[1];
--         table.remove(args,1);
--         if pcall(self.methods[name:toString()],player,args) == false then
--             print("在执行'" .. name:toString() .. "'命令时发生异常");
--         end
--     end
--     IKit.Class(ServerCommand,"ServerCommand",{extends="Command"});
-- end)();

-- (function()
--     local  ClientCommand = {};
    
--     function ClientCommand:constructor()
--         self.super();
--         self.syncValue = UI.SyncValue:Create("SCValue");
--         self.syncValue.OnSync = self.OnSync;
--         Event:addEventListener("OnSignal",function(signal)
--             self:OnSignal(signal);
--         end);
        
--         Event:addEventListener("OnUpdate",function()
--             self:OnUpdate();
--         end);
--     end

--     function ClientCommand:OnSync()
--         local command = IKit.New("String",self.syncValue.message);
--         self:execute(command);
--     end

--     function ClientCommand:OnUpdate()
--         local i = 0;
--         while #self.sendbuffer > 0 do
--             UI.Signal(self.sendbuffer[1]);
--             table.remove(self.sendbuffer,1);
--             i = i + 1;
--             if i == 30 then
--                 return;
--             end
--         end
--     end

--     function ClientCommand:OnSignal(signal)
--         if signal == 4 then
--             self:execute(IKit.New("String",self.receivbBuffer));
--             self.receivbBuffer = {};
--         else
--             table.insert(self.receivbBuffer,signal);
--         end
--     end

--     function ClientCommand:sendMessage(message)
--         local bytes = IKit.New("String",message):toBytes();
--         bytes[#bytes+1] = 4;
--         table.insert(self.sendbuffer,bytes);
--     end

--     function ClientCommand:execute(command)
--         local args = {IKit.New("String")};
--         for i = 1, command.length, 1 do
--             if command:charAt(i) == ' ' then
--                 if args[#args].length > 0 then
--                     table.insert(args,IKit.New("String"));
--                 end
--             else
--                 args[#args]:insert(command:charAt(i));
--             end
--         end
--         if args[#args].length == 0 then
--             table.remove(args,#args);
--         end
--         local name = args[1];
--         table.remove(args,1);
--         if pcall(self.methods[name:toString()],args) == false then
--             print("在执行'" .. name:toString() .. "'命令时发生异常");
--         end
--     end

--     IKit.Class(ClientCommand,"ClientCommand",{extends="Command"});
-- end)();

-- Font = Font or {};
-- Font['?']={16,15,6,1,13,16,10,1,11,17,6,1,21,17,1,6,22,17,1,5,23,17,1,4,10,18,5,1,9,19,4,1,9,20,2,1,20,20,1,4,19,21,1,4,18,22,1,3,16,23,1,4,17,23,1,3,14,24,1,6,15,24,1,3,13,25,1,5,12,26,1,3}

-- Font['Q']={14,10,4,1,12,11,2,1,18,11,2,1,11,12,1,2,19,12,1,1,10,13,1,5,20,13,1,6,15,17,1,2,11,18,1,1,16,18,1,1,19,18,1,4,12,19,1,1,17,19,2,1,13,20,6,1,20,21,1,2,21,22,1,1}
-- Font['W']={10,10,1,3,15,10,1,3,21,10,1,3,11,13,1,5,14,13,1,3,16,13,1,4,20,13,1,3,13,16,1,2,19,16,1,3,17,17,1,2,12,18,1,3,18,19,1,2}
-- Font['E']={12,10,1,10,13,10,6,1,13,15,6,1,13,20,6,1}
-- Font['R']={12,10,1,11,13,10,3,1,16,11,1,1,17,12,1,4,13,16,4,1,14,17,2,1,16,18,1,1,17,19,1,1,18,20,1,1}
-- Font['T']={11,10,9,1,15,11,1,10}
-- Font['Y']={11,10,1,1,19,10,1,1,12,11,1,1,18,11,1,2,13,12,1,2,17,13,1,2,14,14,1,2,16,15,1,2,15,16,1,4,14,20,1,1}
-- Font['U']={11,10,1,9,19,10,1,8,18,18,1,2,12,19,1,1,13,20,5,1}
-- Font['I']={12,10,7,1,15,11,1,10,12,20,3,1,16,20,3,1}
-- Font['O']={14,10,5,1,13,11,1,1,19,11,1,1,12,12,1,2,20,12,1,5,11,14,1,5,19,17,1,2,12,19,1,1,18,19,1,1,13,20,5,1}
-- Font['P']={13,10,1,11,14,10,3,1,17,11,1,1,18,12,1,3,17,15,1,1,14,16,3,1}
-- Font['L']={13,10,1,11,14,20,5,1}
-- Font['K']={12,10,1,11,18,10,1,1,17,11,1,1,16,12,1,1,15,13,1,1,13,14,1,3,14,14,1,1,14,17,1,1,15,18,1,1,16,19,1,1,17,20,2,1}
-- Font['J']={14,10,6,1,17,11,1,9,12,17,1,2,13,19,1,1,16,19,1,2,14,20,2,1}
-- Font['H']={11,10,1,11,20,10,1,11,12,15,8,1}
-- Font['G']={15,10,4,1,14,11,1,1,18,11,1,1,13,12,1,1,12,13,1,2,11,15,1,5,14,15,6,1,19,16,1,2,18,18,1,1,17,19,1,1,12,20,5,1}
-- Font['F']={12,10,1,11,13,10,6,1,13,14,5,1}
-- Font['D']={12,10,1,10,13,10,1,1,14,11,2,1,16,12,2,1,18,13,1,1,19,14,1,5,18,19,1,1,13,20,5,1}
-- Font['S']={15,10,5,1,14,11,1,1,13,12,1,3,14,15,5,1,19,16,1,3,12,19,1,1,18,19,1,1,13,20,5,1}
-- Font['A']={15,10,1,3,14,13,1,2,16,13,1,4,13,15,1,2,12,16,1,2,14,16,2,1,17,16,1,3,11,18,1,2,18,19,1,2,10,20,1,1}
-- Font['Z']={11,10,10,1,19,11,1,1,18,12,1,1,17,13,1,1,16,14,1,1,15,15,1,1,14,16,1,1,13,17,1,1,12,18,1,1,11,19,1,2,12,20,9,1}
-- Font['X']={11,10,1,1,20,10,1,1,12,11,1,1,19,11,1,1,13,12,1,1,18,12,1,1,14,13,1,1,17,13,1,1,15,14,1,3,16,14,1,2,17,16,1,2,14,17,1,1,13,18,1,1,18,18,1,1,12,19,1,1,19,19,1,1,11,20,1,1,20,20,1,1}
-- Font['C']={15,10,4,1,14,11,1,1,18,11,1,1,13,12,1,1,12,13,1,2,11,15,1,4,12,19,1,1,17,19,2,1,13,20,4,1}
-- Font['V']={12,10,1,3,19,10,1,3,13,13,1,3,18,13,1,2,17,15,1,2,14,16,1,3,16,17,1,2,15,19,1,2}
-- Font['B']={13,10,1,11,14,10,4,1,18,11,1,3,17,14,1,2,14,15,3,1,18,16,1,1,19,17,1,2,18,19,1,1,14,20,4,1}
-- Font['N']={11,10,1,11,20,10,1,11,12,11,1,1,13,12,1,2,14,14,1,1,15,15,1,1,16,16,1,1,17,17,1,1,18,18,1,1,19,19,1,1}
-- Font['M']={12,10,1,4,17,10,1,5,11,14,1,3,13,14,1,3,16,14,1,5,18,15,1,2,10,17,1,2,14,17,1,2,19,17,1,2,15,18,1,3,9,19,1,2,20,19,1,2}
-- Font['q']={15,13,4,1,14,14,1,1,18,14,1,11,13,15,1,4,14,19,1,1,15,20,3,1}
-- Font['w']={12,13,1,3,16,13,1,3,20,13,1,3,13,16,1,3,15,16,1,3,17,16,1,3,19,16,1,3,14,19,1,2,18,19,1,2}
-- Font['e']={15,13,3,1,14,14,1,2,18,14,1,2,13,16,1,4,17,16,1,1,15,17,2,1,14,18,1,1,18,19,1,1,14,20,4,1}
-- Font['r']={13,13,1,8,15,13,3,1,14,14,1,1,17,14,1,2}
-- Font['t']={15,11,1,10,13,13,2,1,16,13,2,1}
-- Font['y']={12,13,1,2,18,13,1,2,13,15,1,2,17,15,1,2,14,17,1,2,16,17,1,2,15,19,1,2,14,21,1,3,13,24,1,1}
-- Font['u']={13,13,1,7,18,13,1,8,14,20,4,1}
-- Font['i']={16,10,1,1,16,13,1,8}
-- Font['o']={15,13,2,1,14,14,1,1,17,14,1,1,13,15,1,4,18,15,1,4,14,19,1,1,17,19,1,1,15,20,2,1}
-- Font['p']={13,13,1,12,15,13,3,1,14,14,1,1,17,14,2,1,18,15,1,4,17,19,1,1,14,20,3,1}
-- Font['a']={15,13,4,1,14,14,1,1,18,14,1,6,13,15,1,4,14,19,1,1,17,19,1,1,15,20,2,1,19,20,1,1}
-- Font['s']={15,13,3,1,14,14,1,1,17,14,1,1,13,15,1,1,14,16,2,1,16,17,1,1,17,18,1,2,13,19,1,1,14,20,3,1}
-- Font['d']={19,9,1,12,15,13,3,1,14,14,1,1,18,14,1,1,13,15,1,4,14,19,1,1,18,19,1,1,15,20,3,1}
-- Font['f']={17,9,2,1,16,10,1,1,15,11,1,10,13,13,2,1,16,13,3,1}
-- Font['g']={15,13,3,1,14,14,1,1,18,14,1,9,13,15,1,5,17,19,1,1,14,20,3,1,17,23,1,1,13,24,4,1}
-- Font['h']={13,9,1,12,15,13,3,1,14,14,1,1,18,14,1,7}
-- Font['j']={16,10,1,1,16,13,1,11,12,22,1,2,13,24,3,1}
-- Font['k']={13,9,1,12,18,14,1,1,17,15,1,1,15,16,2,1,14,17,2,1,17,17,1,1,18,18,1,2,19,20,1,1}
-- Font['l']={16,9,1,12}
-- Font['z']={13,13,6,1,17,14,1,2,16,16,1,1,15,17,1,1,14,18,1,3,13,20,1,1,15,20,4,1}
-- Font['x']={12,13,1,1,19,13,1,1,13,14,1,1,18,14,1,1,14,15,1,1,17,15,1,1,15,16,2,1,15,17,2,1,14,18,1,1,17,18,1,1,13,19,1,1,18,19,1,1,12,20,1,1,19,20,1,1}
-- Font['c']={15,13,3,1,14,14,1,1,18,14,1,1,13,15,1,5,18,19,1,1,14,20,4,1}
-- Font['v']={12,13,1,2,18,13,1,2,13,15,1,3,17,15,1,3,14,18,1,2,16,18,1,2,15,20,1,1}
-- Font['b']={13,9,1,12,15,13,3,1,14,14,1,1,18,14,1,1,19,15,1,4,18,19,1,1,14,20,4,1}
-- Font['n']={13,13,1,8,16,13,2,1,15,14,1,1,18,14,1,7,14,15,1,1}
-- Font['m']={12,13,1,8,14,13,3,1,18,13,2,1,13,14,1,1,16,14,1,7,17,14,1,1,20,14,1,7}
-- Font['1']={16,10,1,11,15,11,1,1,15,20,1,1,17,20,1,1}
-- Font['2']={13,10,4,1,12,11,1,1,17,11,1,1,18,12,1,3,17,15,1,1,15,16,2,1,13,17,2,1,12,18,1,3,13,20,6,1}
-- Font['3']={13,10,4,1,12,11,1,1,17,11,1,9,14,15,3,1,12,19,1,1,13,20,4,1}
-- Font['4']={17,10,1,11,16,11,1,1,15,12,1,2,14,14,1,1,13,15,1,1,12,16,1,2,13,17,4,1,18,17,2,1}
-- Font['5']={12,10,7,1,12,11,1,5,14,13,3,1,13,14,1,2,17,14,1,1,18,15,1,4,12,19,1,1,17,19,1,1,13,20,4,1}
-- Font['6']={16,10,1,1,15,11,1,1,14,12,1,1,13,13,1,2,12,14,1,5,14,14,4,1,18,15,1,4,13,19,1,1,17,19,1,1,14,20,3,1}
-- Font['7']={11,10,8,1,17,11,1,1,16,12,1,2,15,14,1,2,14,16,1,3,13,19,1,2}
-- Font['8']={13,10,5,1,12,11,1,4,18,11,1,4,13,15,5,1,12,16,1,4,18,16,1,4,13,20,5,1}
-- Font['9']={13,10,4,1,12,11,1,1,17,11,1,1,11,12,1,3,18,12,1,4,12,15,1,1,17,15,1,3,13,16,4,1,16,18,1,1,14,19,2,1,12,20,2,1}
-- Font['0']={13,10,4,1,12,11,1,1,17,11,1,1,11,12,1,7,18,12,1,7,12,19,1,1,17,19,1,1,13,20,4,1}
-- Font['`']={13,9,1,1,14,10,1,2,15,12,1,1}
-- Font['-']={13,17,5,1}
-- Font['=']={13,14,6,1,13,18,6,1}
-- Font['[']={15,9,1,15,16,9,2,1,16,23,2,1}
-- Font[']']={15,9,3,1,17,10,1,14,15,23,2,1}
-- Font[';']={15,13,2,1,15,14,2,1,16,20,1,2,15,21,1,2}
-- Font['\'']={15,10,1,5}
-- Font['\\']={13,10,1,2,14,12,1,1,15,13,1,3,16,16,1,2,17,18,1,2,18,20,1,2}
-- Font['/']={18,9,1,1,17,10,1,3,16,13,1,2,15,15,1,2,14,16,1,2,13,18,1,2,12,20,1,2}
-- Font['.']={16,19,1,2}
-- Font[',']={16,20,1,2,15,22,1,2}
-- Font['~']={12,15,2,1,17,15,1,3,18,15,1,2,11,16,2,1,14,16,1,1,11,17,1,1,15,17,2,1}
-- Font['_']={11,22,9,1}
-- Font['+']={15,14,1,5,13,16,2,1,16,16,2,1}
-- Font['{']={15,9,3,1,14,10,1,12,13,16,1,2,15,22,1,2,16,23,2,1}
-- Font['}']={13,9,3,1,16,10,1,6,17,16,1,2,16,18,1,4,15,22,1,2,13,23,2,1}
-- Font[':']={15,13,2,1,15,14,2,1,15,18,2,1,15,19,2,1}
-- Font['"']={14,10,1,5,17,10,1,5}
-- Font['|']={15,9,1,15}
-- Font['?']={12,11,5,1,17,12,1,1,18,13,1,2,17,15,1,1,16,16,1,1,14,17,2,1,14,21,1,1}
-- Font['>']={13,13,1,1,14,14,1,1,15,15,1,1,16,16,2,1,16,17,1,1,14,18,2,1,13,19,1,1}
-- Font['<']={16,14,1,1,15,15,1,1,14,16,1,2,13,17,1,1,15,18,1,1,16,19,1,1}
-- Font['!']={16,9,1,10,15,20,2,1}
-- Font['@']={13,9,6,1,12,10,1,1,19,10,1,1,11,11,1,2,20,11,1,1,14,12,3,1,21,12,1,5,10,13,1,5,13,13,2,1,12,14,1,3,17,14,1,3,16,16,1,1,13,17,3,1,18,17,3,1,11,18,1,2,12,20,2,1,19,20,1,1,14,21,5,1}
-- Font['#']={14,9,1,4,19,9,1,4,11,12,3,1,15,12,4,1,20,12,2,1,13,13,1,2,18,13,1,3,12,15,1,4,17,16,1,3,10,17,2,1,13,17,4,1,18,17,3,1,11,19,1,2,16,19,1,2}
-- Font['$']={14,8,1,16,13,10,1,1,15,10,2,1,12,11,1,4,13,15,1,1,15,15,1,1,16,16,1,1,17,17,1,2,12,19,1,2,16,19,1,1,13,20,1,1,15,20,1,1}
-- Font['%']={18,9,1,2,11,10,3,1,17,10,1,3,10,11,1,3,14,11,1,3,16,12,1,3,11,14,3,1,15,15,1,2,18,16,3,1,14,17,1,2,17,17,1,3,21,17,1,3,13,19,1,2,18,20,3,1}
-- Font['^']={15,9,2,1,14,10,4,1,14,11,1,1,17,11,1,1,13,12,1,1,18,12,1,1}
-- Font['&']={16,10,2,1,15,11,1,4,17,11,1,2,16,13,1,4,14,15,1,1,19,15,1,3,13,16,1,1,17,16,1,2,12,17,1,3,18,17,1,3,17,19,1,1,13,20,4,1,19,20,1,1}
-- Font['*']={15,9,1,4,12,10,3,1,16,10,1,4,17,10,2,1,13,11,2,1,17,11,2,1,14,12,1,2,13,13,1,2,17,13,1,2}
-- Font['(']={17,9,1,1,16,10,1,1,15,11,1,2,14,13,1,8,15,21,1,1,16,22,1,1,17,23,1,1}
-- Font[')']={14,9,1,1,15,10,1,1,16,11,1,2,17,13,1,7,16,20,1,2,15,22,1,1,14,23,1,1}
-- Font[' ']={}


-- (function()
--     local Base64 = {};

--     function Base64:constructor(value,bit)
--         self.charlist = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>";
--         self.charmap = {};
--         for i = 1,#self.charlist do
--             self.charmap[string.sub(self.charlist,i,i)] = i-1;
--         end
--     end

--     function Base64:toString(number,bit)
--         local list = {}; 
--         for i = bit,1,-1 do
--             list[i] = string.sub(self.charlist,number % 64 + 1,number % 64 + 1);
--             number = (number - number % 64) >> 6;
--         end
--         return table.concat(list);
--     end

--     function Base64:toNumber(text)
--         local type = IKit.TypeOf(text);
--         local number = 0;
--         if type == "string" then
--             for i = 1,#text do
--                 number = (number << 6) + self.charmap[string.sub(text,i,i)];
--             end
--         elseif type == "String" then
--             for i = 1,text.length do
--                 number = (number << 6) + self.charmap[text:charAt(i)];
--             end
--         end
--         return number;
--     end

--     IKit.Class(Base64,"Base64");
-- end)();

-- (function()
--     local Font = {};
--     function Font:constructor()
--         self.map = {
--             [' '] = {},
--         };
--     end

--     function Font:getChar(c)
--         return self.map[c] or {};
--     end

--     IKit.Class(Font,"Font");
-- end)();

-- (function()
--     local Image = {};
    
--     IKit.Class(Image,"Image");
-- end)();

-- (function()
--     local Box = {};
    
--     IKit.Class(Box,"Box");
-- end)();

-- (function()
--     local Text = {};
--     function Text:constructor(x,y,size,letterspacing,text)
--         self.boxlist = {};
--         self.x = x;
--         self.y = y;
--         self.size = size;
--         self.letterspacing = letterspacing;
--         self.text = text;
--     end

--     function Text:Show()
--         for i=1,str.length do
--             local char = self.text:charAt(i)
--             if Font[char] == nil then
--                 char = "?";
--             end
--             for j = 1,#Font[char],4 do
--                 local _x = Font[char][j];
--                 local _y = Font[char][j+1];
--                 local width = Font[char][j+2];
--                 local height = Font[char][j+3];

--                 local box = UI.Box.Create();
--                 if box == nil then
--                     print("无法绘制矩形:已超过最大限制");
--                     return;
--                 end
--                 if i == 1 then
--                     box:Set({x=x + _x*size,y=y + _y*size,width=width*size,height=height*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--                 else
--                     box:Set({x=x + (i-1) * letterspacing + _x*size,y=y + _y*size,width=width*size,height=height*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--                 end
--                 self.boxlist[#self.boxlist+1] = box;
--                 box:Show();
--             end
--         end
--     end

--     function Text:Hide()
--         self.boxlist = {};
--         collectgarbage("collect");
--     end


--     function Text:getSize(text,font)
        
--     end

--     IKit.Class(Text,"Text");
-- end)();

-- (function()
--     local Bitmap = {};
    
--     IKit.Class(Bitmap,"Bitmap");
-- end)();

-- (function()
--     local Graphics = {
--         id = 1,
--         root = {},
--         color = {255,255,255,255},
--     };

--     function Graphics:DrawRect(x,y,width,height)
--         local box = UI.Box.Create();
--         if box == nil then
--             print("无法绘制矩形:已超过最大限制");
--             return;
--         end
--         box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--         box:Show();
--         self.root[#self.root + 1] = {self.id,{box}};
--         self.id = self.id + 1;
--         return self.id - 1;
--     end

--     function Graphics:DrawText(x,y,size,letterspacing,text)
--         local str = {
--             array = {},
--             length = 0,
--             charAt = function(self,index)
--                 if index > 0 and index <= self.length then
--                     return self.array[index];
--                 end
--                 print("数组下标越界");
--             end,
--         };
--         local currentIndex = 1;
--         while currentIndex <= #text do
--             local cs = 1;
--             local seperate = {0, 0xc0, 0xe0, 0xf0};
--             for i = #seperate, 1, -1 do
--                 if string.byte(text, currentIndex) >= seperate[i] then
--                     cs = i;
--                     break;
--                 end
--             end
--             str.array[#str.array+1] = string.sub(text,currentIndex,currentIndex+cs-1);
--             currentIndex = currentIndex + cs;
--             str.length = str.length + 1;
--         end
--         self.root[#self.root + 1] = {self.id,{}};
--         for i=1,str.length do
--             local char = str:charAt(i)
--             if Font[char] == nil then
--                 char = "?";
--             end
--             for j = 1,#Font[char],4 do
--                 local _x = Font[char][j];
--                 local _y = Font[char][j+1];
--                 local width = Font[char][j+2];
--                 local height = Font[char][j+3];

--                 local box = UI.Box.Create();
--                 if box == nil then
--                     print("无法绘制矩形:已超过最大限制");
--                     return;
--                 end
--                 if i == 1 then
--                     box:Set({x=x + _x*size,y=y + _y*size,width=width*size,height=height*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--                 else
--                     box:Set({x=x + (i-1) * letterspacing + _x*size,y=y + _y*size,width=width*size,height=height*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--                 end
--                 (self.root[#self.root][2])[#self.root[#self.root][2] + 1] = box;
--                 box:Show();
--             end
--         end
--         self.id = self.id + 1;
--         return self.id - 1;
--     end

--     function Graphics:DrawImage(x,y,size,image)
--         self.root[#self.root + 1] = {self.id,{}};
--         for i = 1,#image,5 do
--             local _x = image[i];
--             local _y = image[i+1];
--             local width = image[i+2];
--             local height = image[i+3];

--             self.color[1] = 0xFF & image[i+4];
--             self.color[2] = (0xFF00 & image[i+4]) >> 8;
--             self.color[3] = (0xFF0000 & image[i+4]) >> 16;

--             local box = UI.Box.Create();
--             if box == nil then
--                 print("无法绘制矩形:已超过最大限制");
--                 return;
--             end
--             box:Set({x=x + _x*size,y=y + _y*size,width=width*size,height=height*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--             (self.root[#self.root][2])[#self.root[#self.root][2] + 1] = box;
--             box:Show();
--         end
--         self.id = self.id + 1;
--         return self.id - 1;
--     end

--     function Graphics:Remove(id)
--         for i = 1,#self.root do
--             if self.root[i][1] == id then
--                 table.remove(self.root,i);
--                 collectgarbage("collect");
--                 return;
--             end
--         end
--     end

--     function Graphics:Show(id)
--         for i = 1,#self.root do
--             if self.root[i][1] == id then
--                 for j = 1,#self.root[i][2] do
--                     self.root[i][2][j]:Show();
--                 end
--                 return;
--             end
--         end
--     end

--     function Graphics:Hide(id)
--         for i = 1,#self.root do
--             if self.root[i][1] == id then
--                 for j = 1,#self.root[i][2] do
--                     self.root[i][2][j]:Hide();
--                 end
--                 return;
--             end
--         end
--     end
    
--     function Graphics:Clean()
--         self.root = {};
--         collectgarbage("collect");
--     end

--     return Graphics;
-- end)();


-- if Game ~= nil then
--     for key, value in pairs(Game.Rule) do
--         print(key);
--     end
-- end

-- if UI ~= nil then
--     for key, value in pairs(UI.Event) do
--         print(key);
--     end
-- end


-- -- Game = {Rule = {}};
-- -- UI = {Event = {}};

-- -- Event = IKit.New("Event");


-- -- if Game~=nil then
-- --     Event = Event
-- --     + "OnPlayerConnect"
-- --     + "OnPlayerDisconnect"
-- --     + "OnRoundStart"
-- --     + "OnRoundStartFinished"
-- --     + "OnPlayerSpawn"
-- --     + "OnPlayerJoiningSpawn"
-- --     + "OnPlayerKilled"
-- --     + "OnKilled"
-- --     + "OnPlayerSignal"
-- --     + "OnUpdate"
-- --     + "OnPlayerAttack"
-- --     + "OnTakeDamage"
-- --     + "CanBuyWeapon"
-- --     + "CanHaveWeaponInHand"
-- --     + "OnGetWeapon"
-- --     + "OnReload"
-- --     + "OnReloadFinished"
-- --     + "OnSwitchWeapon"
-- --     + "PostFireWeapon"
-- --     + "OnGameSave"
-- --     + "OnLoadGameSave"
-- --     + "OnClearGameSave";

-- --     function Game.Rule:OnPlayerConnect (player)
-- --         Event:forEach("OnPlayerConnect",player);
-- --     end
    
-- --     function Game.Rule:OnPlayerDisconnect (player)
-- --         Event:forEach("OnPlayerDisconnect",player);
-- --     end
    
-- --     function Game.Rule:OnRoundStart ()
-- --         Event:forEach("OnRoundStart");
-- --     end
    
-- --     function Game.Rule:OnRoundStartFinished ()
-- --         Event:forEach("OnRoundStartFinished");
-- --     end
    
-- --     function Game.Rule:OnPlayerSpawn (player)
-- --         Event:forEach("OnPlayerSpawn",player);
-- --     end
    
-- --     function Game.Rule:OnPlayerJoiningSpawn (player)
-- --         Event:forEach("OnPlayerJoiningSpawn",player);
-- --     end
    
-- --     function Game.Rule:OnPlayerKilled (victim, killer, weapontype, hitbox)
-- --         Event:forEach("OnPlayerKilled",victim, killer, weapontype, hitbox);
-- --     end
    
-- --     function Game.Rule:OnKilled (victim, killer)
-- --         Event:forEach("OnKilled",victim,killer);
-- --     end
    
-- --     function Game.Rule:OnPlayerSignal (player,signal)
-- --         Event:forEach("OnPlayerSignal",player,signal);
-- --     end
    
-- --     function Game.Rule:OnUpdate (time)
-- --         Event:forEach("OnUpdate",time);
-- --     end
    
-- --     function Game.Rule:OnPlayerAttack (victim, attacker, damage, weapontype, hitbox)
-- --         Event:forEach("OnPlayerAttack",victim, attacker, damage, weapontype, hitbox);
-- --     end
    
-- --     function Game.Rule:OnTakeDamage (victim, attacker, damage, weapontype, hitbox)	
-- --         Event:forEach("OnTakeDamage",victim, attacker, damage, weapontype, hitbox);
-- --     end
    
-- --     function Game.Rule:CanBuyWeapon (player, weaponid)
-- --         Event:forEach("CanBuyWeapon",player,weaponid);
-- --     end
    
-- --     function Game.Rule:CanHaveWeaponInHand (player, weaponid, weapon)
-- --         Event:forEach("CanHaveWeaponInHand",player, weaponid, weapon);
-- --     end
    
-- --     function Game.Rule:OnGetWeapon (player, weaponid, weapon)
-- --         Event:forEach("OnGetWeapon",player, weaponid, weapon);
-- --     end
    
-- --     function Game.Rule:OnReload (player, weapon, time)
-- --         Event:forEach("OnPlayerConnect",player, weapon, time);
-- --     end
    
-- --     function Game.Rule:OnReloadFinished (player, weapon)
-- --         Event:forEach("OnPlayerConnect",player, weapon);
-- --     end
    
-- --     function Game.Rule:OnSwitchWeapon (player)
-- --         Event:forEach("OnPlayerConnect",player);
-- --     end
    
-- --     function Game.Rule:PostFireWeapon (player, weapon, time)
-- --         Event:forEach("OnPlayerConnect",player, weapon, time);
-- --     end
    
-- --     function Game.Rule:OnGameSave (player)
-- --         Event:forEach("OnPlayerConnect",player);
-- --     end
    
-- --     function Game.Rule:OnLoadGameSave (player)
-- --         Event:forEach("OnPlayerConnect",player);
-- --     end
    
-- --     function Game.Rule:OnClearGameSave (player)
-- --         Event:forEach("OnPlayerConnect",player);
-- --     end
-- -- end

-- -- if UI~=nil then
-- --     Event = Event
-- --     + "OnRoundStart"
-- --     + "OnSpawn"
-- --     + "OnKilled"
-- --     + "OnInput"
-- --     + "OnUpdate"
-- --     + "OnChat"
-- --     + "OnSignal"
-- --     + "OnKeyDown"
-- --     + "OnKeyUp"
    
-- --     function UI.Event:OnRoundStart()
-- --         Event:forEach("OnRoundStart");
-- --     end

-- --     function UI.Event:OnSpawn()
-- --         Event:forEach("OnSpawn");
-- --     end

-- --     function UI.Event:OnKilled()
-- --         Event:forEach("OnKilled");
-- --     end

-- --     function UI.Event:OnInput (inputs)
-- --         Event:forEach("OnInput",inputs);
-- --     end

-- --     function UI.Event:OnUpdate(time)
-- --         Event:forEach("OnUpdate",time);
-- --     end

-- --     function UI.Event:OnChat (text)
-- --         Event:forEach("OnChat",text);
-- --     end

-- --     function UI.Event:OnSignal(signal)
-- --         Event:forEach("OnSignal",signal);
-- --     end

-- --     function UI.Event:OnKeyDown(inputs)
-- --         Event:forEach("OnKeyDown",inputs);
-- --     end

-- --     function UI.Event:OnKeyUp (inputs)
-- --         Event:forEach("OnKeyUp",inputs);
-- --     end
-- -- end

-- -- Timer = IKit.New("Timer");

-- -- if Game ~= nil then
-- --     Command = IKit.New("ServerCommand");

-- --     Command:register("killme",function(player,args)
-- --         for i = 1, #args,1 do
-- --             print(args[i]:toString());
-- --         end
-- --         player:Kill();
-- --     end)

-- --     Command:register("kill",function(player,args)
-- --         IKit.Player:find(args[1]):Kill();
-- --     end);
    
-- --     Command:register("tp",function(player,args)
-- --         player.position = IKit.Player:find(args[1]).position;
-- --     end);
-- -- end

-- -- if UI ~= nil then
-- --     Command = IKit.New("ClientCommand");

-- --     Command:register("kill",function(args)
-- --         for i = 1, #args,1 do
-- --             print(args[i]:toString());
-- --         end
-- --     end);
-- -- end
