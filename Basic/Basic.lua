Class = (function()
    NULL = {};
    local CLASS = {};
    CLASS["Object"] = {
        NAME = "Object",
        TABLE = {
            __call = function (self,...)
                if self.constructor ~= nil then
                    self:constructor(...);
                end
            end,
            __newindex = function(table,key,value)
                if table[key] ~= nil and type(value) ~= type(table[key]) then
                    error('key:'..key.."赋值类型与原类型不相同" .. type(value) .. "~=" .. type(table[key]));
                end
                local t = table;
                while table ~= nil do
                    if rawget(table,key) ~= nil then
                        rawset(table,key,value);
                        return;
                    end
                    table = getmetatable(table);
                end
                rawset(t,key,value);
            end,
        },
        SUPER = nil,
    }
    local function CREATECLASS(_name,_function,_super)
        _super = (_super or {CLASS = CLASS["Object"]}).CLASS;
        local object = {};
        _function(object);
        CLASS[_name] = {
            NAME = _name,
            TABLE = object,
            SUPER = _super,
        }
        if object.STATIC == true then
            _G[_name] = CLASS[_name].TABLE;
        else
            local classList = {CLASS[_name]};
            while _super ~= nil do
                classList[#classList+1] = _super;
                _super = _super.SUPER;
            end
            local str = {};
            for i = 1,#classList do
                str[#str+1] = string.format("local %s = {super=nil,__call =nil,__newindex=nil,__index=nil,",classList[i].NAME)
                for key,_ in pairs(classList[i].TABLE) do
                    str[#str+1] = string.format("%s = CLASS['%s'].TABLE.%s,",key,classList[i].NAME,key);
                end
                str[#str+1] = "};"
            end
            
            for i = 1,#classList - 1 do
                str[#str+1] = string.format("%s.super=%s;",classList[i].NAME,classList[i+1].NAME);
                str[#str+1] = string.format("%s.__call=%s.constructor or function() end;",classList[i].NAME,classList[i].NAME);
                str[#str+1] = string.format("%s.__index=%s;",classList[i].NAME,classList[i].NAME);
                str[#str+1] = string.format("%s.__newindex=Object.__newindex;",classList[i].NAME);
                str[#str+1] = string.format("setmetatable(%s,%s);",classList[i].NAME,classList[i+1].NAME);
            end
            str[#str+1] = string.format("return setmetatable({},%s);",_name);
            CLASS[_name].NEW = load(table.concat(str),"","t",{rawset=rawset,error=error,type=type,rawget=rawget,getmetatable=getmetatable,setmetatable = setmetatable,CLASS = CLASS})
            local POOL = {};
            _G[_name] = setmetatable({
                CLASS = CLASS[_name],
                RETURNOBJECT = function(self,object)
                    POOL[#POOL+1] = object;
                end
            },{
                __call = function(self,...)
                    local object;
                    if #POOL ~= 0 then
                        object = table.remove(POOL,#POOL);
                    else
                        object = self.CLASS.NEW();
                    end
                    object(...);
                    return object;
                end
            });
        end
    end

    return CREATECLASS;
end)();

Class("String",function(String)
    String.STATIC = true;
    function String:charSize(char)
        local seperate = {0, 0xc0, 0xe0, 0xf0}
        for i = #seperate, 1, -1 do
            if char >= seperate[i] then
                return i;
            end
        end
        return 1;
    end

    function String:toString(value)
        local array = {};
        local currentIndex = 1;
        while currentIndex <= #value do
            local cs = String:charSize(value[currentIndex]);
            array[#array+1] = string.char(table.unpack(value,currentIndex,currentIndex + cs - 1));
            currentIndex = currentIndex + cs;
        end
        return table.concat(array);
    end

    function String:toBytes(value)
        local bytes = {};
        if type(value) == "string" then
            value = String:toTable(value);
        end
        for i = 1, #value do
            for j = 1, #value[i], 1 do
                table.insert(bytes,string.byte(value[i],j));
            end
        end
        return bytes;
    end

    function String:toTable(value)
        local currentIndex = 1;
        local array = {};
        while currentIndex <= #value do
            local cs = String:charSize(string.byte(value, currentIndex));
            array[#array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
            currentIndex = currentIndex + cs;
        end
        return array;
    end
end);

Class("Listener",function(Listener)
    function Listener:constructor(func)
        self.call = func;
        self.status = 1;
    end

    function Listener:stop()
        self.status = 0;
    end

    function Listener:start()
        self.status = 1;
    end

    function Listener:cancel()
        self.status = -1;
    end
end);

Class("TimerTask",function(TimerTask)
    function TimerTask:constructor(func,time,period)
        self.super(func);
        self.time = time;
        self.period = period or -1;
    end
end,Listener);

Class("Event",function(Event)
    Event.STATIC = true;
    Event.listenerList = {};
    if Game ~= nil then
        Event.listenerList = {"OnPlayerConnect","OnPlayerDisconnect","OnRoundStart","OnRoundStartFinished","OnPlayerSpawn","OnPlayerJoiningSpawn","OnPlayerKilled","OnKilled","OnPlayerSignal","OnUpdate","OnPlayerAttack","OnTakeDamage","CanBuyWeapon","CanHaveWeaponInHand","OnGetWeapon","OnReload","OnReloadFinished","OnSwitchWeapon","PostFireWeapon","OnGameSave","OnLoadGameSave","OnClearGameSave"};
    end
    if UI~=nil then
        Event.listenerList = {"OnRoundStart","OnSpawn","OnKilled","OnInput","OnUpdate","OnChat","OnSignal","OnKeyDown","OnKeyUp"};
    end

    for i = 1, #Event.listenerList do
        Event[Event.listenerList[i]] = {};
        ((UI or Game).Event or (UI or Game).Rule)[Event.listenerList[i]] = function(_,...)
            local list = Event[Event.listenerList[i]];
            local result;
            for j = #list,1,-1 do
                if list[j].status == 1 then
                    result = list[j]:call(...);
                elseif list[j].status == -1 then
                    table.remove(list,j);
                end
            end
            return result;
        end
    end


    function Event:addEventListener(event,listener)
        if type(event) == "string" then
            event = self[event];
        end
        if type(listener) == "function" then
            listener = Listener(listener);
        end
        event[#event + 1] = listener;
        return listener;
    end

    function Event:purge(event)
        if type(event) == "string" then
            event = self[event];
        end
        event = {};
    end
end);

Class("Timer",function(Timer)
    Timer.STATIC = true;

    Timer.task = {};
    Timer.count = 0;
    Event:addEventListener(Event.OnUpdate,function()
        for i = #Timer.task,1,-1 do
            if Timer.task[i].time <= Timer.count then
                local success,result;
                if Timer.task[i].status == 1 then
                    success,result = pcall(Timer.task[i].call,Timer.task[i])
                    if not success then
                        print("Timer中的函数发生了异常");
                        print(result)
                        Timer.task[i].status = -1;
                    end
                end
                if Timer.task[i].period == -1 or Timer.task[i].status == -1 or result == true then
                    table.remove(Timer.task,i);
                else
                    Timer.task[i].time = Timer.count + Timer.task[i].period;
                end
            end
        end
        Timer.count = Timer.count + 1;
    end);

    function Timer:schedule(call,delay,period)
        self.task[#self.task+1] = TimerTask(call,self.count + delay,period);
        return self.task[#self.task];
    end

    function Timer:purge()
        self.task = {}
    end
end);

Class("Method",function(Method)
    Method.STATIC = true;

    Method.id = 1;
    Method.UI = {};
    Method._UI = {};
    Method.GAME = {};
    Method._GAME = {};
    Method.uiList = {};

    function Method:game(table)
        for key, value in pairs(table) do
            self.GAME[key] = self.id;
            self._GAME[self.id] = value;
            self.id = self.id + 1;
        end
    end

    function Method:ui(table)
        for key, value in pairs(table) do
            self.UI[key] = self.id;
            self._UI[self.id] = value;
            self.id = self.id + 1;
        end
    end
end);

Method:game({
    ["GETNAME"] = function(self,player)
        return String:toBytes(player.name);
    end
});

Method:ui({
    ["REQUEST"] = function(self,bytes)
        table.remove(self.requestQueue)(bytes);
    end,
    ["STOPPLAYERCONTROL"] = function(self,bytes)
        UI.StopPlayerControl();
    end
});

if Game ~= nil then
    Class("Database",function(Database)
        function Database:constructor()
            self.models = {};
            if not Game.Rule:CanSave() then
                error("该地图无法保存数据");
            end
            local value = Game.Rule:GetGameSave("database");
            if value ~= nil then
                for modelName in string.gmatch(value, "%a+") do
                    self.models[modelName] = Model:New(modelName);
                end
            end
        end

        --("ModelName",{['key']=default,...}
        function Database:model(name,struct)
            local model = self.models[name];
            if model == nil then
                local fields = {};
                for key, value in pairs(struct) do
                    fields[#fields+1] = key;
                    fields[#fields+1] = value;
                end
                fields = string.concat(fields,' ');
                Game.Rule:SetGameSave(string.format("%s.%s",name,"count"),0);
                Game.Rule:SetGameSave(string.format("%s.%s",name,"fields"),fields);

                model = Model:New(name);
            else
                local temp = Game.Rule:GetGameSave(string.format("%s.%s",name,"fields"));
                local fields = {};
                for field in string.gmatch(temp, "%a+") do
                    fields[#fields+1] = field;
                end
                for i = 1, #fields, 2 do
                    if struct[fields[i]] == nil then
                        error("字段不匹配");
                    end
                end
            end
            return model;
        end

        function Database:delete(modelName)

        end
    end);
    
    Class("Model",function(Model)
        function Model:constructor(name)
            self.name = name;
            local temp = {};
            self.fields = {};
            for field in string.gmatch(Game.Rule:GetGameSave(string.format("%s.%s",self.name,"fields")), "%a+") do
                temp[#temp+1] = field;
            end
            for i = 1, #temp,2 do
                fields[temp[i]] = temp[i+1];
            end

            self.records = {};
            local count = self:count();
            for i = 1,count do
                local model = {};
                for key,value in pairs(self.fields) do
                    model[key] = Game.Rule:GetGameSave(string.format("%s.%s.%s",name,i,key)) or value;
                end
                self.models[#self.models+1] = model;
            end
        end
    
        function Model:count()
            return Game.Rule:GetGameSave(string.format("%s.%s",self.name,"count"));
        end

        function Model:insert(model)
                self.models[#self.models+1] = {};
                for key,value in pairs(self.keys) do
                    self:set(#self.models,key,model[key])
                    self.models[#self.models][key] = model[key] or value;
                end
                Game.Rule:SetGameSave(string.format("%s.%s",self.name,"count"),#self.models);
        end

        function Model:select(condition)
                local list = {};
                for i = 1,#self.models do
                    if condition(self.models[i]) then
                        list[#list+1] = self.models[i];
                    end
                end
                return list;
        end
    
        function Model:delete(condition)
            if self.canSave then
                
            end
        end
    end);

    Class("NetServer",function(NetServer)
        NetServer.STATIC = true;
        local receivbBuffer = {};
        local syncValue = {};
        local players = {};

        Event:addEventListener(Event.OnPlayerSignal,function(self,player,signal)
            local receivbBuffer = receivbBuffer[player.name];
            if receivbBuffer.id == -1 then
                receivbBuffer.id = signal;
            elseif receivbBuffer.length == -1 then
                receivbBuffer.length = signal;
            else
                receivbBuffer.value[#receivbBuffer.value+1] = signal;
                receivbBuffer.length = receivbBuffer.length - 1;
            end
            if receivbBuffer.length == 0 then
                self:execute(player,Method.UI.REQUEST,Method.GAME[receivbBuffer.id](player,receivbBuffer.value) or {-1});
                receivbBuffer = {
                    id = -1,
                    length = -1,
                    value = {},
                };
            end
        end);
  
        Event:addEventListener(Event.OnPlayerConnect,function(self,player)
            receivbBuffer[player.name] = {
                id = -1,
                length = -1,
                value = {},
            };
            players[player.name] = player;
            syncValue[player.name] = {};
        end);

        Event:addEventListener(Event.OnPlayerDisconnect,function(self,player)
            receivbBuffer[player.name] = nil;
            players[player.name] = nil;
            syncValue[player.name] = nil;
        end);

        function NetServer:createSyncValue(player,key,value)
            local sync = Game.SyncValue.Create(player.name .. "_" .. key);
            sync.value = value;
            syncValue[player.name][key] = syncValue;
            return syncValue;
        end

        function NetServer:setSyncValue(player,key,value)
            self.syncValue[player.name][key].value = value;
        end

        function NetServer:execute(player,key,bytes)
            player:Signal(#bytes);
            for i = 1,#bytes do
                player:Signal(bytes[i]);
            end
        end
    end);

    Class("FunctionMenu",function(FunctionMenu)
        FunctionMenu.STATIC = true;
    end);
end

if UI ~= nil then
    Class("NetClient",function(NetClient)
        NetClient.STATIC = true;
        NetClient.name = "";

        NetClient.requestQueue = {};

        local receivbBuffer = {
            id = -1,
            length = -1,
            value = {},
        };

        Event:addEventListener(Event.OnSignal,function(self,signal)
            if receivbBuffer.id == -1 then
                receivbBuffer.id = signal;
            elseif receivbBuffer.length == -1 then
                receivbBuffer.length = signal;
            else
                receivbBuffer.value[#receivbBuffer.value+1] = signal;
                receivbBuffer.length = receivbBuffer.length - 1;
            end
            if receivbBuffer.length == 0 then
                Method._UI[receivbBuffer.id](NetClient,receivbBuffer.value);
                receivbBuffer = {
                    id = -1,
                    length = -1,
                    value = {},
                };
            end
        end);

        function NetClient:createSyncValue(key,call)
            Timer:schedule(function(self)
                if NetClient.name ~= "" then
                    local syncValue = UI.SyncValue:Create(NetClient.name .. "_" .. key);
                    syncValue.OnSync = call;
                    self:cancel();
                end
            end,10,15);
        end

        function NetClient:request(id,bytes,success)
            UI.Signal(id);
            UI.Signal(#bytes);
            for i = 1,#bytes do
                UI.Signal(bytes[i]);
            end
            requestQueue[#requestQueue+1] = success or function() end;
        end

        NetClient:request(Method.GAME.GETNAME,{},function(bytes)
            print(String:toString(bytes))
        end);
    end);

--     Class("Base64",function(Base64)
--         local charlist = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>";
--         local charmap = {};
--         for i = 1,#charlist do
--             charmap[string.sub(charlist,i,i)] = i-1;
--         end

--         function Base64:toNumber(text)
--             local type = type(text);
--             local number = 0;
--             for i = 1,#text do
--                 number = (number << 6) + charmap[string.sub(text,i,i)];
--             end
--             return number;
--         end
--     end);

--     Class("Font",function(Font)
--         function Font:constructor(size)
--             self.data = {};
--             self.map = {
--                 [' '] = {},
--             };
--             self.sizeMap = {
--             };
--         end

--         function Font:getChar(c)
--             if self.map[c] == nil then
--                 if self.data[c] == nil then
--                    return {};
--                 else
--                     local array = {};
--                     for i = 1,#self.data[c] do
--                         array[#array+1] = Base64:toNumber(string.sub(self.data[c],i,i));
--                     end
--                     self.data[c] = nil;
--                     self.map[c] = array;
--                     return self.map[c];
--                 end
--             end
--             return self.map[c];
--         end

--         local seperate = {0, 0xc0, 0xe0, 0xf0}
--         function Font:load(data)
--             local s = 1;
--             local i = 1;

--             while i < #data do
--                 local c;
--                 local length = 1;
--                 for j = #seperate, 1, -1 do
--                     if string.byte(data,s) >= seperate[j] then
--                         length = j;
--                         break;
--                     end
--                 end
--                 c = string.sub(data,s,s+length-1);
--                 i = i + length;

--                 while string.sub(data,i,i) ~= ' ' do
--                     i = i + 1;
--                 end
--                 self.data[c] = string.sub(data,s+length,i-1);
--                 s = i + 1;
--             end
--         end

--         function Font:getCharSize(char,size)
--             if self.sizeMap[char] == nil then
--                 local charArray = self:getChar(char);
--                 local width = 0;
--                 local height = 0;

--                 for j = 1,#charArray,4 do
--                     local _x = charArray[j];
--                     local _y = charArray[j+1];
--                     local _width = charArray[j+2];
--                     local _height = charArray[j+3];
--                     if _x + _width > width then
--                         width = _x + _width;
--                     end
--                     if _y + _height > height then
--                         height = _y + _height;
--                     end
--                 end

--                 if char == " " then
--                     local w,h = self:getCharSize('a',1);
--                     width = w;
--                     height = h;
--                 end
--                 self.sizeMap[char] = {width,height};
--             end
--             return self.sizeMap[char][1] * size,self.sizeMap[char][2] * size;
--         end

--         function Font:getTextSize(text,size,letterspacing)
--             if type(text) == "string" then
--                 text = String:toTable(text);
--             end
--             local height = 0;
--             local width = 0;
--             for i = 1,#text do
--                 local w,h = self:getCharSize(text[i],size);
--                 width = width + w + letterspacing;
--                 if h > height  then
--                     height = h;
--                 end
--             end
--             return width-letterspacing,height;
--         end
--     end);

--     Song = Font()

--     Class("Bitmap",function(Bitmap)
--         function Bitmap:constructor(data)
--             local i = 5;
--             local s = i;
--             self.data = {};
--             self.size = 1;
--             self.map = NULL;

--             self.width = Base64:toNumber(string.sub(data,1,2));
--             self.height = Base64:toNumber(string.sub(data,3,4));

--             while i < #data do
--                 local c;
--                 local color = string.sub(data,s,s+3);
--                 i = i + 4;
--                 while string.sub(data,i,i) ~= ' ' do
--                     i = i + 1;
--                 end
--                 self.data[color] = string.sub(data,s+4,i-1);
--                 s = i + 1;
--             end
--         end

--         function Bitmap:getTable()
--             if self.map == NULL then
--                 self.map = {};
--                 for key, value in pairs(self.data) do
--                     local color = Base64:toNumber(key);
--                     local array = {};
--                     for i = 1,#value,2 do
--                         array[#array+1] = Base64:toNumber(string.sub(value,i,i+1));
--                     end
--                     self.map[color] = array;
--                 end
--                 self.data = NULL;
--             end
--             return self.map;
--         end

--         function Bitmap:getSize()
--             return self.width*self.size,self.height*self.size;
--         end

--     end);

--     Class("Graphics",function(Graphics)
--         function Graphics:constructor()
--             self.color = {255,255,255,255};
--             self.opacity = 1;

--             self.pixelsize = 3;
--             self.letterspacing = 3;
--             self.font = Song;



--             self.width = UI.ScreenSize().width;
--             self.height = UI.ScreenSize().height;
--         end

--         function Graphics:drawRect(component,x,y,width,height,rect)
--             local box;
--             if self.color[4] <= 0 or self.opacity <= 0 then
--                 return;
--             end
--             if rect~=nil then
--                 if x > rect[1] + rect[3] then
--                     return;
--                 end
--                 if y > rect[2] + rect[4] then
--                     return;
--                 end
--                 if x + width < rect[1] or y + height < rect[2] then
--                     return;
--                 end
--                 if x < rect[1] then
--                      x = rect[1];
--                 end
--                 if y < rect[2] then
--                      y = rect[2];
--                 end
--                 if x + width > rect[1] + rect[3] then
--                     width = rect[1] + rect[3] - x;
--                 end
--                 if y + height > rect[2] + rect[4] then
--                     height = rect[2] + rect[4] - y;
--                 end
--                 box = UI.Box.Create();
--                 if box == nil then
--                     print("无法绘制矩形:已超过最大限制");
--                     return;
--                 end
--                 box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]*self.opacity});
--             else
--                 box = UI.Box.Create();
--                 if box == nil then
--                     print("无法绘制矩形:已超过最大限制");
--                     return;
--                 end
--                 box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]*self.opacity});
--             end
--             box:Show();
--             component.root[#component.root+1] = box;
--         end;

--         function Graphics:drawText(component,x,y,text,rect)
--             if type(text) == "string" then
--                 text = String:toTable(text);
--             end
--             local ls = 0;
--             for i=1,#text do
--                 local c = text[i]
--                 local boxArray = self.font:getChar(c);
--                 if #boxArray == 0 then
--                     print("未找到字符:"..c);
--                 end
--                 for j = 1,#boxArray,4 do
--                     local _x = boxArray[j];
--                     local _y = boxArray[j+1];
--                     local _width = boxArray[j+2];
--                     local _height = boxArray[j+3];
--                     if i == 1 then
--                         self:drawRect(component,x + _x*self.pixelsize,y + _y*self.pixelsize,_width*self.pixelsize,_height*self.pixelsize,rect);
--                     else
--                         self:drawRect(component,x + ls + _x*self.pixelsize,y + _y*self.pixelsize,_width*self.pixelsize,_height*self.pixelsize,rect);
--                     end
--                 end
--                 local charWidth = self.font:getCharSize(c,self.pixelsize);
--                 ls = ls + charWidth + self.letterspacing;
--             end
--         end

--         function Graphics:drawBitmap(component,x,y,bitmap,rect)
--             local map = bitmap:getTable();
--             for key, value in pairs(map) do
--                 self.color[1] = 0xFF & key;
--                 self.color[2] = (0xFF00 & key) >> 8;
--                 self.color[3] = (0xFF0000 & key) >> 16;
--                 for i = 1,#value,4 do
--                     local _x = value[i];
--                     local _y = value[i+1];
--                     local _width = value[i+2];
--                     local _height = value[i+3];
--                     self:drawRect(component,x + _x*bitmap.size,y + _y*bitmap.size,_width*bitmap.size,_height*bitmap.size,rect);
--                 end
--             end
--         end

--     end);

--     Class("Component",function(Component)
--         function Component:constructor(x,y,width,height)
--             self.root = {};
--             self.x = x or 0;
--             self.y = y or 0;
--             self.width = width or 0;
--             self.height = height or 0;

--             self.parent = NULL;
            
--             self.isvisible = false;
--             self.stopplayercontrol = false;
--             self.rect = {self.x,self.y,self.width,self.height};
--             self.opacity = 1;
--             self.backgroundcolor = {255,255,255,255};
--             self.border = {0,0,0,0};
--             self.bordercolor = {0,0,0,255};
--             self.animations = {};
            
--             self.font = Song or NULL;
--             self.pixelsize = 2;
--             self.letterspacing = 0;
            
--             self.fontcolor = {0,0,0,255};
            
--             self.animation = NULL;

--             self.onkeydown = function() end;
--             self.onkeyup = function() end;
--         end

--         function Component:onKeyDown()
--             if self.onkeydown ~= NULL then
--                 self.onkeydown(self);
--             end
--         end

--         function Component:onKeyUp()
--             if self.onkeyup ~= NULL then
--                 self.onkeyup(self);
--             end
--         end

--         function Component:setParent(container)
--             if self.parent ~= NULL then
--                 self.parent:remove(self);
--             end
--             self.parent = NULL;
--             for key, value in pairs(container) do
--                 print(key)
--             end
--             container:add(self);
--         end

--         function Component:show()
--             if self.stopplayercontrol == true then
--                 UI.StopPlayerControl(true);
--             end
--             self:paint();
--             self.isvisible = true;
--         end

--         function Component:hide()
--             if self.stopplayercontrol == true then
--                 UI.StopPlayerControl(false);
--             end
--             self:clear();
--             self.isvisible = false;
--         end

--         function Component:paint()
--             Graphics.font = self.font;
--             Graphics.pixelsize = self.pixelsize;
--             Graphics.letterspacing = self.letterspacing;

--             Graphics.color = self.backgroundcolor;
--             Graphics.opacity = self.opacity;

--             Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y,self.width,self.height);

--             Graphics.color = self.bordercolor;

--             Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y,self.width,self.border[1]);
--             Graphics:drawRect(self,self.parent.x + self.x + self.width - self.border[2],self.parent.y + self.y,self.border[2],self.height);
--             Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y + self.height - self.border[3],self.width,self.border[3]);
--             Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y,self.border[4],self.height);
--         end

--         function Component:repaint()
--             if self.isvisible == true then
--                 self:clear();
--                 self:paint();
--             end
--         end

--         function Component:clear()
--             self.root = {};
--             collectgarbage("collect");
--         end

--         function Component:animate(params,step,callback)
--             local style = {};
--             for i = 1, #params, 1 do
--                 local table = params[i].table or self;
--                 local key = params[i].key;
--                 local value = params[i].value;

--                 style[#style+1] = {
--                     table,
--                     key,
--                     (value - table[key]) / step,
--                     value,
--                 };
--             end
--             if self.animation ~= NULL then
--                 self.animation.destroy = true;
--             end
--             self.animation = Timer:schedule(function()
--                 if step == 0 then
--                     for i = 1, #style, 1 do
--                         style[i][1][style[i][2]] = style[i][4];
--                     end
--                     if callback ~= nil then
--                         callback(self);
--                     end
--                     self:repaint();
--                     self.animation = NULL;
--                     return true;
--                 end
--                 for i = 1, #style, 1 do
--                     style[i][1][style[i][2]] = style[i][1][style[i][2]] + style[i][3];
--                 end
--                 step = step - 1;
--                 self:repaint();
--                 return false;
--             end,0,3);
--         end
--     end);

--     Class("Container",function(Container)
--         function Container:constructor(x,y,width,height)
--             self.super(x,y,width,height);
--             self.children = {};
--         end

--         function Container:onKeyDown(inputs)
--             for i = 1,#self.children do
--                 self.children[i]:onKeyDown(inputs);
--             end
--         end

--         function Container:onKeyUp(inputs)
--             for i = 1,#self.children do
--                 self.children[i]:onKeyUp(inputs);
--             end
--         end

--         function Container:add(component,pos)
--             if component.parent ~= NULL then
--                 component.parent:remove(component);
--             end
--             component.parent = self;
--             table.insert(self.children,pos or #self.children + 1,component);
--             return self;
--         end

--         function Container:remove(component)
--             for i = 1,#self.children do
--                 if component == self.children[i] then
--                     table.remove(self.children,i);
--                     component.parent = NULL;
--                     return;
--                 end
--             end
--         end

--         function Container:repaint()
--             if self.isvisible == true then
--                 self.super:repaint();
--                 for i = 1,#self.children do
--                     self.children[i]:repaint();
--                 end
--             end
--         end

--         function Container:show()
--             self.super:show();
--             for i = 1,#self.children do
--                 self.children[i]:show();
--             end
--         end

--         function Container:hide()
--             self.super:hide();
--             for i = 1,#self.children do
--                 self.children[i]:hide();
--             end
--         end
--     end,Component);

--     Class("Windows",function(Windows)
--         function Windows:constructor()
--             self.super();
--             self.parent = NULL;
--             self.width = Graphics.width;
--             self.height = Graphics.height;

--             Event:addEventListener(Event.OnKeyDown,function(self,listener,inputs)
--                 self:onKeyDown(inputs);
--             end);

--             Event:addEventListener(Event.OnKeyUp,function(self,listener,inputs)
--                 self:onKeyUp(inputs);
--            end);
--         end
--     end,Container);

--     Class("Item",function(Item)
--         function Item:constructor(name,value)
--             self.super();
--             self.parent = NULL;
--             self.children = {};
--             self.call = function() end;
--             self.name = name;

--             self:add(value);
--         end

--         function Item:add(value,pos)
--             if type(value) == "function" then
--                 self.call = value;
--             elseif type(value) == "table" then
--                 for i = 1, #value, 2 do
--                     local item = _G.Item(value[i],value[i+1]);
--                     item.parent = self;
--                     self:addItem(item,pos);
--                 end
--             end
--         end

--         function Item:addItem(item,pos)
--             pos = pos or #self.children+1;
--             table.insert(self.children,pos,item);
--         end

--         function Item:removeItem(name)
--             for i = #self.children,1,-1 do
--                 if self.children[i].name == name then
--                     table.remove(self.children,i);
--                     return;
--                 elseif #self.children[i].children ~= 0 then
--                     self.children[i]:remove(name);
--                 end
--             end
--         end

--         function Item:getItem(name)
--             for i = 1,#self.children do
--                 if self.children[i].name == name then
--                     return self.children[i];
--                 end
--             end
--             return nil;
--         end

--     end,Component);

--     Class("ItemMenu",function(ItemMenu)
--         function ItemMenu:constructor(itemTree,hotkey)
--             self.super(self.type,itemTree);

--             self.page = 1;
--             self.cursor = self;
--             self.x = 0;
--             self.y = 100;
--             self.height = 200;
--             self.width = 100;

--             self.lineheight = 30;
--             self.letterspacing = 5;

--             self.backgroundcolor = {0,0,0,0};
--             self.bordercolor = {0,0,0,0};

--             self.hotkey = hotkey or UI.KEY.O;
--         end

--         function ItemMenu:onKeyDown(inputs)
--             if inputs[self.hotkey] == true then
--                 if self.isvisible == true then
--                     self:hide();
--                 else
--                     self.page = 1;
--                     self.cursor = self;
--                     self:show();
--                 end
--             end

--             if self.isvisible == true then
--                 local item;
--                 if inputs[UI.KEY.NUM1] == true then
--                     item = self.cursor.children[(self.page - 1) * 6 + 1]
--                 elseif inputs[UI.KEY.NUM2] == true then
--                     item = self.cursor.children[(self.page - 1) * 6 + 2]
--                 elseif inputs[UI.KEY.NUM3] == true then
--                     item = self.cursor.children[(self.page - 1) * 6 + 3]
--                 elseif inputs[UI.KEY.NUM4] == true then
--                     item = self.cursor.children[(self.page - 1) * 6 + 4]
--                 elseif inputs[UI.KEY.NUM5] == true then
--                     item = self.cursor.children[(self.page - 1) * 6 + 5]
--                 elseif inputs[UI.KEY.NUM6] == true then
--                     item = self.cursor.children[(self.page - 1) * 6 + 6]
--                 elseif inputs[UI.KEY.NUM7] == true then
--                     if self.page ~= 1 then
--                         self.page = self.page - 1;
--                         self:repaint();
--                     end
--                 elseif inputs[UI.KEY.NUM8] == true then
--                     if self.page * 6 < #self.cursor.children then
--                         self.page = self.page + 1;
--                         self:repaint();
--                     end
--                 elseif inputs[UI.KEY.NUM9] == true then
--                     if self.cursor.parent ~= NULL then
--                         self.page = 1;
--                         self.cursor = self.cursor.parent;
--                         self:repaint();
--                     end
--                 end
--                 if item ~= nil then
--                     if item.call ~= NULL then
--                         local success,result =  pcall(item.call);
--                         if result ~= true then
--                             self:hide();
--                         end
--                     end
--                     if #item.children ~= 0 then
--                         self.cursor = item;
--                     end
--                     self:repaint();
--                 end
--             end
--         end

--         function ItemMenu:paint()
--             self.super:paint();
--             Graphics.color = self.fontcolor;

--             local __,height = Song:getCharSize("A",self.pixelsize);
--             height = height + self.lineheight;

--             for i = 1,6 do
--                 if self.cursor.children[(self.page - 1) * 6 + i] == nil then
--                     break;
--                 end
--                 Graphics:drawText(self,self.x,self.y + (i * height),i..'.'..self.cursor.children[(self.page - 1) * 6 + i].name);
--             end
--             if self.page ~= 1 then
--                 Graphics:drawText(self,self.x,self.y + 7 * height,"7.上一页");
--             end

--             if self.page * 6 < #self.cursor.children then
--                 Graphics:drawText(self,self.x,self.y + 8 * height,"8.下一页");
--             end

--             if self.cursor.parent ~= NULL then
--                 Graphics:drawText(self,self.x,self.y + 9 * height,"9.返回");
--             end
--         end

--     end,Item);
--     MainWindows = Windows();
--     MainMenu = ItemMenu(
--         {"帮助",{
--         "关于",function()
--             Toast:makeText("作者:@iPad水晶");
--          end,
--         }},UI.KEY.O);
--     MainWindows:add(MainMenu);

--     Class("Lable",function(Lable)
--         function Lable:constructor(x,y,width,height,text,font)
--             self.super(x,y,width,height);
--             self.offx = 0;
--             self.offy = 0;
--             self.align = "center" or "left"or "right";
--             self.charArray = String:toTable(text or "");
--             self.font = font or self.font;
--         end

--         function Lable:paint()
--             self.super:paint();
--             Graphics.color = self.fontcolor;

--             local w,h = self.font:getTextSize(self.charArray,self.pixelsize,self.letterspacing);

--             if self.align == "center" then
--                 Graphics:drawText(self,self.parent.x + self.x + self.offx + (self.width - w)/2,self.parent.y + self.y + self.offy,self.charArray);
--             elseif self.align == "left" then
--                 Graphics:drawText(self,self.parent.x + self.x + self.offx,self.parent.y + self.y + self.offy,self.charArray);
--             elseif self.align == "right" then
--                 Graphics:drawText(self,self.parent.x + self.x + self.offx + (self.width - w),self.parent.y + self.y + self.offy,self.charArray);
--             end
--         end

--         function Lable:getText()
--             return String:toString(self.charArray);
--         end

--         function Lable:setText(text)
--             self.charArray = String:toTable(text or "");
--             self:repaint();
--         end

--     end,Component);

--     Class("Edit",function(Edit)
--         function Edit:constructor(x,y,width,height,text,font)
--             self.super(x,y,width,height,text,font);
--             self.cursor = 0;
--             self.maxlength = 10;
--             self.intype = "number";

--             self.keyprevious = UI.KEY.LEFT;
--             self.keynext = UI.KEY.RIGHT;
--             self.keybackspace = UI.KEY.SHIFT;
--         end

--         function Edit:onKeyDown(inputs)
--             self.super:onKeyDown(inputs);
--             if self.isvisible == true then
--                 for key, value in pairs(inputs) do
--                     if value == true then
--                         if #self.charArray < self.maxlength then
--                             if self.intype == "all" or self.intype == "number" then
--                                 if key >=0 and key <= 8 then
--                                     table.insert(self.charArray,self.cursor+1,string.char(key+49));
--                                     self.cursor = self.cursor + 1;
--                                 end
--                                 if key == 9 then
--                                     table.insert(self.charArray,self.cursor+1,"0");
--                                     self.cursor = self.cursor + 1;
--                                 end
--                             end

--                             if self.intype == "all" or self.intype == "english" then
--                                 if key >= 10 and key <= 35 then
--                                     table.insert(self.charArray,self.cursor+1,string.char(key+87));
--                                     self.cursor = self.cursor + 1;
--                                 end

--                                 if key == 37 then
--                                     table.insert(self.charArray,self.cursor+1,' ');
--                                     self.cursor = self.cursor + 1;
--                                 end
--                             end
--                         end
--                         if key == self.keyprevious then
--                             if self.cursor > 0 then
--                                 self.cursor = self.cursor - 1;
--                             end
--                         end
--                         if key == self.keynext then
--                             if self.cursor < #self.charArray then
--                                 self.cursor = self.cursor + 1;
--                             end
--                         end
--                         if key == self.keybackspace then
--                             if self.cursor > 0 then
--                                 table.remove(self.charArray,self.cursor);
--                                 self.cursor = self.cursor - 1;
--                             end
--                         end
--                     end
--                 end
--                 self:repaint();
--             end
--         end

--         function Edit:paint()
--             self.super:paint();
--             local textArray = {};
--             for i = 1,self.cursor do
--                 textArray[#textArray+1] = self.charArray[i];
--             end
--             local w,h = self.font:getTextSize(textArray,self.pixelsize,self.letterspacing);

--             if self.align == "left" then
--                 Graphics:drawRect(self,self.parent.x + self.x + w + self.offx + 1,self.parent.y + self.y +self.offy,self.letterspacing /3 + self.pixelsize,h);
--             elseif self.align == "center" then
--                 local tw,th = self.font:getTextSize(self.charArray,self.pixelsize,self.letterspacing);
--                 Graphics:drawRect(self,self.parent.x + self.x + w + self.offx + (self.width - tw)/2 + 1,self.parent.y + self.y +self.offy,self.letterspacing /3 + self.pixelsize,h);
--             elseif self.align == "right" then
--                 local tw,th = self.font:getTextSize(self.charArray,self.pixelsize,self.letterspacing);
--                 Graphics:drawRect(self,self.parent.x + self.x + w + self.offx + (self.width - tw) + 1,self.parent.y + self.y +self.offy,self.letterspacing /3 + self.pixelsize,h);
--             end
--         end

--     end,Lable);

--     Class("Toast",function(Toast)
--         function Toast:constructor()
--             self.super(0,0,100,100,"QWQ");
--             self.letterspacing = 5;
--         end

--         function Toast:makeText(text,length,x,y)
--             self:setText(text);

--             local w,h = self.font:getTextSize(text,self.pixelsize,self.letterspacing);

--             self.x = x or (MainWindows.width - w)/2;
--             self.y  = y or MainWindows.height * 0.8;
--             self.width = w + 3 * self.pixelsize;
--             self.height = h + 3 * self.pixelsize;


--             self.backgroundcolor = {0,0,0,255};
--             self.opacity = 1;
--             self.fontcolor = {255,255,255,255};
--             self:show();
--             self:animate({{key = "opacity",value = 0}},length or 120,function(self)
--                 self:hide();
--             end);
--         end
--     end,Lable);

--     Class("PictureBox",function(PictureBox)
--         function PictureBox:constructor(x,y,width,height,bitmap)
--             self.super(x,y,width,height);
--             self.bitmap = bitmap;
--             self.backgroundcolor[4] = 0;
--         end

--         function PictureBox:paint()
--             self.super:paint();
--             Graphics:drawBitmap(self,self.x,self.y,self.bitmap,{self.x,self.y,self.width,self.height});
--         end

--     end,Component);
end


----------------------------------------------------
----------------------------------------------------
----------------------------------------------------