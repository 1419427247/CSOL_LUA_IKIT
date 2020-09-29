Class,InstanceOf,Type = (function()
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

Class("String",function(String)

    function String:constructor()
        self.map = {};
    end

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
            local cs = self:charSize(value[currentIndex]);
            array[#array+1] = string.char(table.unpack(value,currentIndex,currentIndex + cs - 1));
            currentIndex = currentIndex + cs;
        end
        return table.concat(array);
    end

    function String:toBytes(value)
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
    end

    function String:toTable(value)
        local currentIndex = 1;
        local array = {};
        while currentIndex <= #value do
            local cs = self:charSize(string.byte(value, currentIndex));
            array[#array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
            currentIndex = currentIndex + cs;
        end
        return array;
    end
end);

String = String:New();


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

-- Event = Event:New();

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
                        table.remove(task,i);
                        print("计时器中ID为:[" .. key .. "]的函数发生了异常");
                        print(result);
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

-- Timer = Timer:New();


-- Event = Event:New();

-- Event = Event + "OnUpdate";

-- Timer = Timer:New();

-- Class("Command",function(Command)

--     function Command:constructor()
--         self.sendbuffer = {};
--         self.receivbBuffer = {};
--         self.methods = {};
--     end

--     function Command:register(name,fun)
--         self.methods[name] = fun;
--     end

-- end);

-- (function()
--     local ServerCommand = {};

--     function ServerCommand:constructor()
--         self.super();
--         self.syncValue = Game.SyncValue:Create("SCValue");
--         Event:addEventListener("OnUpdate",self.OnUpdate);
--         Event:addEventListener("OnPlayerSignal",self.OnPlayerSignal);
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

-- Class("Method",function(Method)
--     local key = 16;
--     INT = {};
--     BOOL = {};
--     STRING = {};
--     function Method:constructor(name,call,...)
--         key = key + 1;
--         self.key = key;
--         self.fields = {...};
--         self.call = call or NULL;
--     end
-- end);


function Net:constructor()
    self.sendbuffer = {};
    self.receivbBuffer = {};
    self.syncValue = {};
    self.id = 1;
    Event:addEventListener(Event.OnUpdate,function()

    end);
    Event:addEventListener(Event.OnSignal,function(signal)
        
    end);
end

function Net:sendMessageBySyncValue(message,player)
    message = String:New(message);
end

function Net:sendMessageBySignal(message,player)
    
end

function Net:connect(player)
    self.syncValue[self.id] = Game.SyncValue:Create(self.id);
end


-- if UI ~= nil then
--     Class("Base64",function(Base64)
--         function Base64:constructor(value,bit)
--             self.charlist = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>";
--             self.charmap = {};
--             for i = 1,#self.charlist do
--                 self.charmap[string.sub(self.charlist,i,i)] = i-1;
--             end
--         end
    
--         function Base64:toString(number,bit)
--             local list = {};
--             for i = bit,1,-1 do
--                 list[i] = string.sub(self.charlist,number % 64 + 1,number % 64 + 1);
--                 number = (number - number % 64) >> 6;
--             end
--             return table.concat(list);
--         end
    
--         function Base64:toNumber(text)
--             local type = Type(text);
--             local number = 0;
--             if type == "string" then
--                 for i = 1,#text do
--                     number = (number << 6) + self.charmap[string.sub(text,i,i)];
--                 end
--             elseif type == "String" then
--                 for i = 1,text.length do
--                     number = (number << 6) + self.charmap[text:charAt(i)];
--                 end
--             end
--             return number;
--         end
--     end);
--     Base64 = Base64:New();

--     Class("Font",function(Font)
--         function Font:constructor(size)
--             self.data = {};
--             self.map = {
--                 [' '] = {},
--             };
--             self.sizeMap = {};
--             self.size = size or 5;
--             self.letterspacing = 0;
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
    
--         function Font:getCharSize(c)
--             if self.sizeMap[c] == nil then
--                 local charArray = self:getChar(c);
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
--                 self.sizeMap[c] = {width,height};
--             end
--             return self.sizeMap[c][1] * self.size,self.sizeMap[c][2] * self.size;
--         end
--     end);

--     Song = Font:New();

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
--         end
    
--         function Graphics:drawRect(x,y,width,height,rect)
--             local box;
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
--                 box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--             else
--                 box = UI.Box.Create();
--                 if box == nil then
--                     print("无法绘制矩形:已超过最大限制");
--                     return;
--                 end
--                 box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
--             end
--             box:Show();
--             print(x,y,width,height);
--             return box;
--         end;
    
--         function Graphics:drawText(x,y,font,text,rect)
--             local array = {};
--             local letterspacing = 0;
--             local maxHeight = 0;
--             for i=1,text.length do
--                 local c = text:charAt(i)
--                 local charArray = font:getChar(c);
--                 if #charArray == 0 then
--                     print("未找到字符:"..c);
--                 end
--                 local charWidth = 0;
--                 for j = 1,#charArray,4 do
--                     local _x = charArray[j];
--                     local _y = charArray[j+1];
--                     local _width = charArray[j+2];
--                     local _height = charArray[j+3];
--                     local box;
--                     if i == 1 then
--                         box = self:drawRect(x + _x*font.size,y + _y*font.size,_width*font.size,_height*font.size,rect);
--                     else
--                         box = self:drawRect(x + letterspacing + font.letterspacing + _x*font.size,y + _y*font.size,_width*font.size,_height*font.size,rect);
--                     end
--                     if box ~= nil then
--                         array[#array+1] = box;
--                     end
--                 end
--                 local charWidth = font:getCharSize(c);
--                 letterspacing = letterspacing + charWidth + font.letterspacing;
--             end
--             return array;
--         end
    
--         function Graphics:drawBitmap(x,y,bitmap,rect)
--             local array = {};
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
--                     local box = self:drawRect(x + _x*bitmap.size,y + _y*bitmap.size,_width*bitmap.size,_height*bitmap.size,rect);
--                     if box ~= nil then
--                         array[#array+1] = box;
--                     end
--                 end
--             end
--             return array;
--         end
    
--     end);
    
--     Graphics = Graphics:New();

--     Class("Component",function(Component)
--         function Component:constructor(x,y,width,height)
--             self.root = {};
    
--             self.id = NULL;
--             self.x = x;
--             self.y = y;
--             self.width = width;
--             self.height = height;
--             self.style = {
--                 left = 0,
--                 top = 0,
--                 width = 0,
--                 height = 0,
--                 opacity = 1,
--                 isvisible = false;
--                 position = "relative",
--                 backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
--                 border = {top = 1,left = 1,right = 1,bottom = 1},
--                 bordercolor = {red = 0,green = 0,blue=0,alpha=255},
--             };
--             self.onclick = NULL;
--             self.onfouce = NULL;
--             self.onblur = NULL;
--             self.onkeydown = NULL;
--             self.onkeyup = NULL;
--             self.onupdate = NULL;
--         end
    
--         function Component:paint()
            
--         end
    
--         function Component:show()
--             if not self.style.isvisible then
--                 self.style.isvisible = true;
--                 self:paint();
--             end
--         end
    
--         function Component:hide()
--             self.style.isvisible = false;
--             self.root = {};
--             collectgarbage("collect");
--         end
    
--     end);
    
--     Class("Container",function(Container)
--         function Container:constructor()
--             self.super();
--             self.children = {};
--             self.index = 0;
--         end
    
--         function Container:add(...)
--             local components = {...};
--             for i = 1, #components, 1 do
--                 components[i].father = self;
--                 self.children[#self.children+1] = components[i];
--             end
--             if #self.children == 0 or #self.children == 1 then
--                 self.index = #self.children;
--             end
--             return self;
--         end
    
--         function Container:remove(index)
--             return table.remove(self.children,index);
--         end
--     end,Component);
    
--     Class("Lable",function(Lable)
--         function Lable:constructor(x,y,width,height,font,text)
--             self.super(x,y,width,height);
--             self.font = font;
--             self.text = String:New(text);
--             self:paint();
--         end
    
--         function Lable:paint()
--             self.super:paint();
--             self.root = Graphics:drawText(self.x,self.y,self.font,self.text,{self.x,self.y,self.width,self.height});
--         end
    
--     end,Component);
    
--     Class("PictureBox",function(PictureBox)
--         function PictureBox:constructor(x,y,width,height,bitmap)
--             self.super(x,y,width,height);
--             self.bitmap = bitmap;
--             self:paint();
--         end
    
--         function PictureBox:paint()
--             self.super:paint();
--             self.root = Graphics:drawBitmap(self.x,self.y,self.bitmap,{self.x,self.y,self.width,self.height});
--         end
    
--     end,Component);
-- end



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
