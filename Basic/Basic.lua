Class,InstanceOf,Type = (function()
    String = {
        charSize = function(char)
            local seperate = {0, 0xc0, 0xe0, 0xf0}
            for i = #seperate, 1, -1 do
                if char >= seperate[i] then 
                    return i;
                end
            end
            return 1;
        end,
        toString = function(value)
            local array = {};
            local currentIndex = 1;
            while currentIndex <= #value do
                local cs = self:charSize(value[currentIndex]);
                array[#array+1] = string.char(table.unpack(value,currentIndex,currentIndex + cs - 1));
                currentIndex = currentIndex + cs;
            end
            return table.concat(array);
        end,
        toBytes = function(value)
            local bytes = {};
            if type(value) == "string" then
                value = self:toTable(value);
            end
            for i = 1, #value do
                for j = 1, #value[i], 1 do
                    table.insert(bytes,string.byte(value[i],j));
                end
            end
            return bytes;
        end,
        toTable = function(value)
            local currentIndex = 1;
            local array = {};
            while currentIndex <= #value do
                local cs = self:charSize(string.byte(value, currentIndex));
                array[#array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
                currentIndex = currentIndex + cs;
            end
            return array;
        end
    };
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

    local function INSTANCEOF(_object,_class)
        local table = CLASS[_object.type];
        while table ~= NULL do
            if table.TYPE == _class.Name then
                return true;
            end
            table = table.SUPER;
        end
        return false;
    end

    local function TYPE(value)
        if type(value) == "table" then
            if value.type ~= nil then
                return value.type;
            end
        end
        return type(value);
    end


    return CREATECLASS,INSTANCEOF,TYPE;
end)();

Class("Event",function(Event)
    local instance = NULL;
    local id = 0;
    function Event:constructor()
        if instance ~= NULL then
            error("只能有一个实例化对象");
        end
        instance = self;
    end

    function Event:__add(name)
        if not self[name] then
            self[name] = {};
            return self;
        end
        error("事件:''" ..name.. "'已经存在,请勿重复添加");
    end

    function Event:__sub(name)
        if self[name] then
            self[name] = nil;
            return self;
        end
        error("事件:'" ..name.."'不存在");
    end

    function Event:addEventListener(event,listener)
        if type(listener) == "function" then
            event[#event + 1] = {id,listener};
            id = id + 1;
            return id - 1;
        else
            error("它应该是一个函数");
        end
    end

    function Event:detachEventListener(event,id)
        if type(event) == "string" then
            event = self[event];
        end
        for i = 1, #event,1 do
            if event[i][1] == id then
                table.remove(event,i);
                return;
            end
        end
        error("未找到'" .. id .. "'在Event[" .. name .."]内");
    end

    function Event:run(event,...)
        for i = #event,1,-1 do
            event[i][2](...);
        end
    end
end);

Class("Timer",function(Timer)
    local instance = NULL;
    local id = 0;
    local task = {};
    local count = 0;
    function Timer:constructor()
        Event:addEventListener(Event.OnUpdate,function()
            for i = 1,#task do
                if task[i].value <= count then
                    local success,result = pcall(task[i].call)
                    if not success then
                        print("计时器中ID为:[" .. task[i].id .. "]的函数发生了异常");
                        print(result);
                        table.remove(task,i);
                    elseif task[i].period == nil then
                        table.remove(task,i);
                    else
                        task[i].value = count + task[i].period;
                    end
                end
            end
            count = count + 1;
        end);
        if instance ~= NULL then
            error("只能有一个实例化对象");
        end
        instance = self;
    end

    function Timer:schedule(call,delay,period)
        task[#task+1] = {call = call,value = count + delay,period = period,id = id};
        id = id + 1;
        return id - 1;
    end

    function Timer:find(id)
        for i = 1, #task,1 do
            if task[i].id == id then
                return task[i];
            end
        end
        return nil;
    end

    function Timer:cancel(id)
        for i = 1, #task,1 do
            if task[i].id == id then
                table.remove(task,i);
                return;
            end
        end
    end

    function Timer:purge()
        task = {}
    end
end);

Class("Method",function(Method)
    local key = 1;
    function Method:constructor(func)
        self.key = key;
        self.func = func or function() end;
        key = key + 1;
    end

    function Method:call(...)
        self.func(...);
    end
end);

Event = Event:New();
if Game~=nil then
    Event = Event + "OnPlayerConnect" + "OnPlayerDisconnect" + "OnRoundStart" + "OnRoundStartFinished" + "OnPlayerSpawn" + "OnPlayerJoiningSpawn" + "OnPlayerKilled" + "OnKilled" + "OnPlayerSignal" + "OnUpdate" + "OnPlayerAttack" + "OnTakeDamage" + "CanBuyWeapon" + "CanHaveWeaponInHand" + "OnGetWeapon" + "OnReload" + "OnReloadFinished" + "OnSwitchWeapon" + "PostFireWeapon" + "OnGameSave" + "OnLoadGameSave" + "OnClearGameSave";

    for key, value in pairs(Event) do
        Game.Rule[key] = function(self,...)
            Event:run(value,...);
        end;
    end

end
if UI~=nil then
    Event = Event + "OnRoundStart" + "OnSpawn" + "OnKilled" + "OnInput" + "OnUpdate" + "OnChat" + "OnSignal" + "OnKeyDown" + "OnKeyUp";
    
    for key, value in pairs(Event) do
        UI.Event[key] = function(self,...)
            Event:run(value,...);
        end;
    end
end

Timer = Timer:New();
METHODTABLE = {
    GAME = {

    },
    UI = {
        GETNAME = Method:New(function(self,bytes)
            self.name = String:toString(bytes);
            self.syncValue = {};
            print(self.name);
        end),
        CREATSYNCVALUE = Method:New(function(self,bytes)
            local key = String:toString(bytes);
            self.syncValue[key] = UI.SyncValue:Create(self.name .. key);
            print("成功创建同步变量:"..String:toString(bytes));
        end),
    }
};

if Game ~= nil then
    Class("NetServer",function(NetServer)
        function NetServer:constructor()
            self.cursor = 1;
            self.receivbBuffer = {
                key = 0,
                length = -1,
                bytes = {},
            };
            self.sendbuffer = {};
            self.syncValue = {};

            self.players = {};
    
            self.methods = {};
    
            Event:addEventListener(Event.OnUpdate,function()
                for i = #self.sendbuffer,1,-1 do
                    self.sendbuffer[i].receiver:Signal(self.sendbuffer[i].key);
                    self.sendbuffer[i].receiver:Signal(self.sendbuffer[i].length);
                    while self.cursor <= #self.sendbuffer[i].bytes do
                        self.sendbuffer[i].receiver:Signal(self.sendbuffer[i].bytes[self.cursor]);
                        self.cursor = self.cursor + 1;
                    end
                    self.sendbuffer[#self.sendbuffer] = nil;
                    self.cursor = 1;
                end
            end);
    
            Event:addEventListener(Event.OnPlayerSignal,function(player,signal)
                if self.receivbBuffer.key == 0 then
                    self.receivbBuffer.key = signal;
                elseif self.receivbBuffer.length == -1 then
                    self.receivbBuffer.length = signal;
                else
                    self.receivbBuffer.length = self.receivbBuffer.length - 1;
                    self.receivbBuffer.bytes[#self.receivbBuffer.bytes+1] = signal;
                    if self.receivbBuffer.length == 0 then
                        self.methods[self.receivbBuffer.key]:call(self,player,self.receivbBuffer.bytes);
                        self.receivbBuffer.key = 0;
                        self.receivbBuffer.length = -1;
                        self.receivbBuffer.bytes = {};
                    end
                end
            end);
    
            Event:addEventListener(Event.OnPlayerConnect,function(player)
                self.players[player.name] = player;
                self.syncValue[player.name] = {};
                self:sendMessageBySignal(player,METHODTABLE.UI.GETNAME.key,String:toBytes(player.name));
            end);
    
            Event:addEventListener(Event.OnPlayerDisconnect,function(player)
                self.syncValue[player.name] = nil;
            end);
        end
        
        function NetServer:createSyncValue(player,key,value)
            self:sendMessageBySignal(player,METHODTABLE.UI.CREATSYNCVALUE.key,String:toBytes(key));
            self.syncValue[player.name] = self.syncValue[player.name] or {};
            local syncValue = Game.SyncValue:Create(player.name .. key);
            syncValue.value = value;
            self.syncValue[player.name][player.name .. key] = syncValue;
            return syncValue;
        end

        function NetServer:setSyncValue(player,key,value)
            self.syncValue[player.name .. key].value = value;
        end
    
        function NetServer:sendMessageBySignal(player,key,bytes)
            self.sendbuffer[#self.sendbuffer + 1] = {receiver = player,key = key,length = #bytes,bytes = bytes};
        end
    
        function NetServer:register(method)
            self.methods[method.key] = method;
        end
    end);
end

if UI ~= nil then
    Class("NetClient",function(NetClient)
        function NetClient:constructor()
            self.name = NULL;
            self.cursor = 1;
            self.sendbuffer = {};
            self.receivbBuffer = {
                key = 0,
                length = -1,
                bytes = {},
            };
    
            self.syncValue = NULL;

            self.methods = {
                [METHODTABLE.UI.GETNAME.key] = METHODTABLE.UI.GETNAME,
                [METHODTABLE.UI.CREATSYNCVALUE.key] = METHODTABLE.UI.CREATSYNCVALUE,
            };
    
            Event:addEventListener(Event.OnUpdate,function()
                for i = #self.sendbuffer,1,-1 do
                    UI.Signal(self.sendbuffer[i].key);
                    UI.Signal(self.sendbuffer[i].length);
                    while self.cursor <= #self.sendbuffer[i].bytes do
                        UI.Signal(self.sendbuffer[i].bytes[self.cursor]);
                        self.cursor = self.cursor + 1;
                    end
                    self.sendbuffer[#self.sendbuffer] = nil;
                    self.cursor = 1;
                end
            end);
    
            Event:addEventListener(Event.OnSignal,function(signal)
                if self.receivbBuffer.key == 0 then
                    self.receivbBuffer.key = signal;
                elseif self.receivbBuffer.length == -1 then
                    self.receivbBuffer.length = signal;
                else
                    self.receivbBuffer.length = self.receivbBuffer.length - 1;
                    self.receivbBuffer.bytes[#self.receivbBuffer.bytes+1] = signal;
                    if self.receivbBuffer.length == 0 then
                        self.methods[self.receivbBuffer.key]:call(self,self.receivbBuffer.bytes);
                        self.receivbBuffer.key = 0;
                        self.receivbBuffer.length = -1;
                        self.receivbBuffer.bytes = {};
                    end
                end
            end);
        end
        
        function NetClient:sendMessageBySignal(key,bytes)
            self.sendbuffer[#self.sendbuffer + 1] = {key = key,length = #bytes,bytes = bytes};
        end
    
        function NetClient:register(method)
            self.methods[method.key] = method;
        end
    
    end);

    Class("Base64",function(Base64)
        function Base64:constructor(value,bit)
            self.charlist = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>";
            self.charmap = {};
            for i = 1,#self.charlist do
                self.charmap[string.sub(self.charlist,i,i)] = i-1;
            end
        end
    
        function Base64:toString(number,bit)
            local list = {};
            for i = bit,1,-1 do
                list[i] = string.sub(self.charlist,number % 64 + 1,number % 64 + 1);
                number = (number - number % 64) >> 6;
            end
            return table.concat(list);
        end
    
        function Base64:toNumber(text)
            local type = Type(text);
            local number = 0;
            if type == "string" then
                for i = 1,#text do
                    number = (number << 6) + self.charmap[string.sub(text,i,i)];
                end
            elseif type == "String" then
                for i = 1,text.length do
                    number = (number << 6) + self.charmap[text:charAt(i)];
                end
            end
            return number;
        end
    end);
    Base64 = Base64:New();

    Class("Font",function(Font)
        function Font:constructor(size)
            self.data = {};
            self.map = {
                [' '] = {},
            };
            self.sizeMap = {};
            self.size = size or 5;
            self.letterspacing = 0;
        end
    
        function Font:getChar(c)
            if self.map[c] == nil then
                if self.data[c] == nil then
                   return {};
                else
                    local array = {};
                    for i = 1,#self.data[c] do
                        array[#array+1] = Base64:toNumber(string.sub(self.data[c],i,i));
                    end
                    self.data[c] = nil;
                    self.map[c] = array;
                    return self.map[c];
                end
            end
            return self.map[c];
        end
    
        local seperate = {0, 0xc0, 0xe0, 0xf0}
        function Font:load(data)
            local s = 1;
            local i = 1;
    
            while i < #data do
                local c;
                local length = 1;
                for j = #seperate, 1, -1 do
                    if string.byte(data,s) >= seperate[j] then 
                        length = j;
                        break;
                    end
                end
                c = string.sub(data,s,s+length-1);
                i = i + length;
    
                while string.sub(data,i,i) ~= ' ' do
                    i = i + 1;
                end
                self.data[c] = string.sub(data,s+length,i-1);
                s = i + 1;
            end
        end
    
        function Font:getCharSize(c)
            if self.sizeMap[c] == nil then
                local charArray = self:getChar(c);
                local width = 0;
                local height = 0;
                
                for j = 1,#charArray,4 do
                    local _x = charArray[j];
                    local _y = charArray[j+1];
                    local _width = charArray[j+2];
                    local _height = charArray[j+3];
                    if _x + _width > width then
                        width = _x + _width;
                    end
                    if _y + _height > height then
                        height = _y + _height;
                    end
                end
                self.sizeMap[c] = {width,height};
            end
            return self.sizeMap[c][1] * self.size,self.sizeMap[c][2] * self.size;
        end
    end);

    Song = Font:New();

    Class("Bitmap",function(Bitmap)
        function Bitmap:constructor(data)
            local i = 5;
            local s = i;
            self.data = {};
            self.size = 1;
            self.map = NULL;
    
            self.width = Base64:toNumber(string.sub(data,1,2));
            self.height = Base64:toNumber(string.sub(data,3,4));
    
            while i < #data do
                local c;
                local color = string.sub(data,s,s+3);
                i = i + 4;
                while string.sub(data,i,i) ~= ' ' do
                    i = i + 1;
                end
                self.data[color] = string.sub(data,s+4,i-1);
                s = i + 1;
            end
        end
    
        function Bitmap:getTable()
            if self.map == NULL then
                self.map = {};
                for key, value in pairs(self.data) do
                    local color = Base64:toNumber(key);
                    local array = {};
                    for i = 1,#value,2 do
                        array[#array+1] = Base64:toNumber(string.sub(value,i,i+1));
                    end
                    self.map[color] = array;
                end
                self.data = NULL;
            end
            return self.map;
        end
    
        function Bitmap:getSize()
            return self.width*self.size,self.height*self.size;
        end
    
    end);
    
    Class("Graphics",function(Graphics)
        function Graphics:constructor()
            self.color = {255,255,255,255};
            self.width = UI.ScreenSize().width; 
            self.height = UI.ScreenSize().height;
        end
    
        function Graphics:drawRect(x,y,width,height,rect)
            local box;
            if rect~=nil then
                if x > rect[1] + rect[3] then
                    return;
                end
                if y > rect[2] + rect[4] then
                    return;
                end
                if x + width < rect[1] or y + height < rect[2] then
                    return;
                end
                if x < rect[1] then
                     x = rect[1];
                end
                if y < rect[2] then
                     y = rect[2];
                end
                if x + width > rect[1] + rect[3] then
                    width = rect[1] + rect[3] - x;
                end
                if y + height > rect[2] + rect[4] then
                    height = rect[2] + rect[4] - y;
                end
                box = UI.Box.Create();
                box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
            else
                box = UI.Box.Create();
                if box == nil then
                    print("无法绘制矩形:已超过最大限制");
                    return;
                end
                box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
            end
            box:Show();
            print(x,y,width,height);
            return box;
        end;
    
        function Graphics:drawText(x,y,font,text,rect)
            local array = {};
            local letterspacing = 0;
            for i=1,#text do
                local c = text[i]
                local boxArray = font:getChar(c);
                if #boxArray == 0 then
                    print("未找到字符:"..c);
                end
                local charWidth = 0;
                for j = 1,#boxArray,4 do
                    local _x = boxArray[j];
                    local _y = boxArray[j+1];
                    local _width = boxArray[j+2];
                    local _height = boxArray[j+3];
                    local box;
                    if i == 1 then
                        box = self:drawRect(x + _x*font.size,y + _y*font.size,_width*font.size,_height*font.size,rect);
                    else
                        box = self:drawRect(x + letterspacing + font.letterspacing + _x*font.size,y + _y*font.size,_width*font.size,_height*font.size,rect);
                    end
                    if box ~= nil then
                        array[#array+1] = box;
                    end
                end
                local charWidth = font:getCharSize(c);
                letterspacing = letterspacing + charWidth + font.letterspacing;
            end
            return array;
        end
    
        function Graphics:drawBitmap(x,y,bitmap,rect)
            local array = {};
            local map = bitmap:getTable();
            for key, value in pairs(map) do
                self.color[1] = 0xFF & key;
                self.color[2] = (0xFF00 & key) >> 8;
                self.color[3] = (0xFF0000 & key) >> 16;
                for i = 1,#value,4 do
                    local _x = value[i];
                    local _y = value[i+1];
                    local _width = value[i+2];
                    local _height = value[i+3];
                    local box = self:drawRect(x + _x*bitmap.size,y + _y*bitmap.size,_width*bitmap.size,_height*bitmap.size,rect);
                    if box ~= nil then
                        array[#array+1] = box;
                    end
                end
            end
            return array;
        end
    
    end);
    
    Graphics = Graphics:New();

    Class("Component",function(Component)
        function Component:constructor(x,y,width,height)
            self.root = {};
    
            self.id = NULL;
            self.x = x;
            self.y = y;
            self.width = width;
            self.height = height;
            self.style = {
                left = 0,
                top = 0,
                width = 0,
                height = 0,
                opacity = 1,
                isvisible = false;
                position = "relative",
                backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
                border = {top = 1,left = 1,right = 1,bottom = 1},
                bordercolor = {red = 0,green = 0,blue=0,alpha=255},
            };
            self.onclick = NULL;
            self.onfouce = NULL;
            self.onblur = NULL;
            self.onkeydown = NULL;
            self.onkeyup = NULL;
            self.onupdate = NULL;
        end
    
        function Component:paint()
            
        end
    
        function Component:show()
            if not self.style.isvisible then
                self.style.isvisible = true;
                self:paint();
            end
        end
    
        function Component:hide()
            self.style.isvisible = false;
            self.root = {};
            collectgarbage("collect");
        end
    
    end);
    
    Class("Container",function(Container)
        function Container:constructor()
            self.super();
            self.children = {};
            self.index = 0;
        end
    
        function Container:add(...)
            local components = {...};
            for i = 1, #components, 1 do
                components[i].father = self;
                self.children[#self.children+1] = components[i];
            end
            if #self.children == 0 or #self.children == 1 then
                self.index = #self.children;
            end
            return self;
        end
    
        function Container:remove(index)
            return table.remove(self.children,index);
        end
    end,Component);
    
    Class("Lable",function(Lable)
        function Lable:constructor(x,y,width,height,font,text)
            self.super(x,y,width,height);
            self.font = font;
            self.charArray = String:toTable(text);
            self:paint();
        end
    
        function Lable:paint()
            self.super:paint();
            self.root = Graphics:drawText(self.x,self.y,self.font,self.text,{self.x,self.y,self.width,self.height});
        end
    
    end,Component);
    
    Class("PictureBox",function(PictureBox)
        function PictureBox:constructor(x,y,width,height,bitmap)
            self.super(x,y,width,height);
            self.bitmap = bitmap;
            self:paint();
        end
    
        function PictureBox:paint()
            self.super:paint();
            self.root = Graphics:drawBitmap(self.x,self.y,self.bitmap,{self.x,self.y,self.width,self.height});
        end
    
    end,Component);
end


----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
----------------------------------------------------

if Game~=nil then
    Class("ZombieEscape",function(ZombieEscape)
        local Status = {
            Ready = 0,
            Run = 1,
            End = 2,
        };
        function ZombieEscape:constructor(recordPointNumber)
            self.index = 0;
            self.recordPointNumber = recordPointNumber;
            self.destinationEntityBlocks = NULL;
            self.status = Status.Ready;

            self.recordPoints = Game.SyncValue:Create("ZombieEscape_recordPoints");
            self.allCTPositions = Game.SyncValue:Create("ZombieEscape_allCTPositions");
            self.allTPositions = Game.SyncValue:Create("ZombieEscape_allTPositions");

            self.recordPoints.value = recordPointNumber;
            
            Event:addEventListener(Event.OnPlayerConnect,function(player)
                player.user.ZombieEscape = {};
                player.team = Game.TEAM.CT;
            end);
            Event:addEventListener(Event.OnPlayerSpawn,function(player)
                player.position = player.user.ZombieEscape.archivePoint or player.position;
            end);
            Event:addEventListener(Event.OnPlayerAttack,function(victim,attacker,damage,weapontype,hitbox)
                if attacker == nil then
                    return;
                end
                if attacker:IsPlayer() and victim:IsPlayer() then
                    attacker = attacker:ToPlayer();
                    victim = attacker:ToPlayer();
                else
                    return;
                end
                if attacker.team == Game.TEAM.T and victim.team == Game.Team.CT then
                    victim.team = Game.TEAM.T;
                    victim.model = Game.MODEL.NORMAL_ZOMBIE;
                end
            end);

            Timer:schedule(function()
                local ct = {};
                local t = {};

                for __,player in pairs(NetServer.players) do
                    if player.team == Game.TEAM.CT then
                        ct[#ct+1] = player.user.ZombieEscape.index or 0;
                    else
                        t[#t+1] = player.user.ZombieEscape.index or 0;
                    end
                end
                self.allCTPositions.value = table.concat(ct," ");
                self.allTPositions.value = table.concat(t," ");
            end,0,10);
        end
    
        function ZombieEscape:CreateRecordPoint(entityBlock)
            self.index = self.index + 1;
            local index = self.index;
            if self.index == self.recordPointNumber then
                self.destinationEntityBlocks = entityBlock;
                self.destinationEntityBlocks.OnTouch = function(self,player)
                    player.user.ZombieEscape.index = index;
                    player.user.ZombieEscape.archivePoint = entityBlock.position;
                    Game.SetTrigger("GameOver",true);
                end
            else
                entityBlock.OnTouch = function(self,player)
                    player.user.ZombieEscape.index = index;
                    player.user.ZombieEscape.archivePoint = entityBlock.position;
                    print(player.name.."到了" .. index);
                end
            end
        end
    



        function ZombieEscape:startNewGame()
    
        end
    end);


    NetServer = NetServer:New();

    ZombieEscape = ZombieEscape:New(3);

    function CreateRecordPoint(__,args)
        if args == nil then
            local entity =  Game.GetScriptCaller();

            local entityBlock;
            for i = -1,1 do
                if i ~= 0 then 
                    entityBlock = entityBlock or Game.EntityBlock:Create({x = entity.position.x + i,y = entity.position.y,z = entity.position.z});
                    entityBlock = entityBlock or Game.EntityBlock:Create({x = entity.position.x,y = entity.position.y + i,z = entity.position.z});
                    entityBlock = entityBlock or Game.EntityBlock:Create({x = entity.position.x,y = entity.position.y,z = entity.position.z + i});
                end
            end
            ZombieEscape:CreateRecordPoint(entityBlock);
        else
            local iterator = string.gmatch(args,"-*%d+");
            local x,y,z = tonumber(iterator()),tonumber(iterator()),tonumber(iterator());
            local entityBlock = Game.EntityBlock:Create({x = x,y = y,z = z})
            ZombieEscape:CreateRecordPoint(entityBlock);
        end
    end
end

if UI ~= nil then
    Class("ZombieEscape",function(ZombieEscape)
        local Status = {
            Ready = 0,
            Run = 1,
            End = 2,
        };
        function ZombieEscape:constructor(maxIndex)
            self.recordPoints = UI.SyncValue:Create("ZombieEscape_recordPoints");
            self.allCTPositions = UI.SyncValue:Create("ZombieEscape_allCTPositions");
            self.allTPositions = UI.SyncValue:Create("ZombieEscape_allTPositions");
            
            Timer:schedule(function()
                print(self.allCTPositions.value or "")

                local iterator = string.gmatch(self.allCTPositions.value or "0","%d+");
                for value in iterator do
                    print(value);
                end

                iterator = string.gmatch(self.allTPositions.value or "0","%d+");
                for value in iterator do
                    print(value);
                end
                
            end,0,1);
        end
    end);

    NetClient = NetClient:New();
    ZombieEscape = ZombieEscape:New();


end









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
