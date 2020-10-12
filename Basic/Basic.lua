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
                local cs = String.charSize(value[currentIndex]);
                array[#array+1] = string.char(table.unpack(value,currentIndex,currentIndex + cs - 1));
                currentIndex = currentIndex + cs;
            end
            return table.concat(array);
        end,
        toBytes = function(value)
            local bytes = {};
            if type(value) == "string" then
                value = String.toTable(value);
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
                local cs = String.charSize(string.byte(value, currentIndex));
                array[#array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
                currentIndex = currentIndex + cs;
            end
            return array;
        end
    };

    Event = (function()
        local object;
        local event;
        if Game ~= nil then
            object = {
                    ["OnPlayerConnect"] = {},
                    ["OnPlayerDisconnect"] = {},
                    ["OnRoundStart"] = {},
                    ["OnRoundStartFinished"] = {},
                    ["OnPlayerSpawn"] = {},
                    ["OnPlayerJoiningSpawn"] = {},
                    ["OnPlayerKilled"] = {},
                    ["OnKilled"] = {},
                    ["OnPlayerSignal"] = {},
                    ["OnUpdate"] = {},
                    ["OnPlayerAttack"] = {},
                    ["OnTakeDamage"] = {},
                    ["CanBuyWeapon"] = {},
                    ["CanHaveWeaponInHand"] = {},
                    ["OnGetWeapon"] = {},
                    ["OnReload"] = {},
                    ["OnReloadFinished"] = {},
                    ["OnSwitchWeapon"] = {},
                    ["PostFireWeapon"] = {},
                    ["OnGameSave"] = {},
                    ["OnLoadGameSave"] = {},
                    ["OnClearGameSave"] = {},
                };
                event = Game.Rule;
        end
        if UI~=nil then
            object = {
                    ["OnRoundStart"] = {},
                    ["OnSpawn"] = {},
                    ["OnKilled"] = {},
                    ["OnInput"] = {},
                    ["OnUpdate"] = {},
                    ["OnChat"] = {},
                    ["OnSignal"] = {},
                    ["OnKeyDown"] = {},
                    ["OnKeyUp"] = {},
                };
                event = UI.Event;
        end
        for key, value in pairs(object) do
            event[key] = function(self,...)
                for i = #value,1,-1 do
                    if value[i].stop == false then
                        value[i]:call(...);
                    end
                    if value[i].destroy == true then
                        table.remove(value,i);
                    end
                end
            end;
        end

        local metatable = {
            id = 0,
            addEventListener = function(self,event,listener)
                event[#event + 1] = {call = listener,stop = false,destroy = false};
                return event[#event];
            end,
            detachEventListener = function(self,listener)
                if type(event) == "string" then
                    event = self[event];
                end
                listener.destroy = true;
            end,
            stopEventListener = function(self,listener)
                if type(event) == "string" then
                    event = self[event];
                end
                listener.stop = true;
            end,
            startEventListener = function(self,listener)
                if type(event) == "string" then
                    event = self[event];
                end
                listener.stop = false;
            end,
        };
        metatable.__index = metatable;
        return setmetatable(object,metatable);
    end)();

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


Class("Timer",function(Timer)
    local task = {};
    local count = 0;
    function Timer:constructor()
        Event:addEventListener(Event.OnUpdate,function(listener,time)
            for i = #task,1,-1 do
                if task[i].value <= count then
                    local success,result;
                    if task[i].stop == false then
                        success,result = pcall(task[i].call,task[i])
                        if not success then
                            print("计时器中的函数发生了异常");
                            log(result)
                            table.remove(task,i);
                        end
                    end
                    if task[i].period == nil or task[i].destroy == true or result == true then
                        table.remove(task,i);
                    else
                        task[i].value = count + task[i].period;
                    end
                end
            end
            count = count + 1;
        end);
    end

    function Timer:schedule(call,delay,period)
        task[#task+1] = {call = call,value = count + delay,period = period,destroy = false,stop = false};
        return task[#task];
    end

    function Timer:purge()
        task = {}
    end
end);

Timer = Timer:New();

Class("Method",function(Method)
    local key = 1;
    function Method:constructor()

    end

    function Method:Create(call)
        key = key + 1;
        return {KEY = key - 1,CALL = call};
    end
end);

Method = Method:New();

METHODTABLE = {
    GAME = {

    },
    UI = {
        GETNAME = Method:Create(function(self,bytes)
            self.name = String.toString(bytes);
            self.syncValue = {};
        end),
        CREATSYNCVALUE = Method:Create(function(self,bytes)
            local key = String.toString(bytes);
            self.syncValue[key] = UI.SyncValue:Create(self.name .. key);
            print("成功创建同步变量:"..String.toString(bytes));
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
                self:sendMessageBySignal(player,METHODTABLE.UI.GETNAME.key,String.toBytes(player.name));
            end);

            Event:addEventListener(Event.OnPlayerDisconnect,function(player)
                self.syncValue[player.name] = nil;
            end);
        end

        function NetServer:createSyncValue(player,key,value)
            self:sendMessageBySignal(player,METHODTABLE.UI.CREATSYNCVALUE.key,String.toBytes(key));
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


    -- group = {

    -- }
    -- Class("Group",function(Group)
    --     function Group:constructor()
    --         self.groups = {};

    --     end
    -- end);
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
            self.sizeMap = {
            };
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

        function Font:getCharSize(char,size)
            if self.sizeMap[char] == nil then
                local charArray = self:getChar(char);
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

                if char == " " then
                    local w,h = self:getCharSize('a',1);
                    width = w;
                    height = h;
                end
                self.sizeMap[char] = {width,height};
            end
            return self.sizeMap[char][1] * size,self.sizeMap[char][2] * size;
        end

        function Font:getTextSize(text,size,letterspacing)
            if type(text) == "string" then
                text = String.toTable(text);
            end
            local height = 0;
            local width = 0;
            for i = 1,#text do
                local w,h = self:getCharSize(text[i],size);
                width = width + w + letterspacing;
                if h > height  then
                    height = h;
                end
            end
            return width-letterspacing,height;
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
            self.opacity = 1;

            self.pixelsize = 3;
            self.letterspacing = 3;
            self.font = Song;



            self.width = UI.ScreenSize().width;
            self.height = UI.ScreenSize().height;
        end

        function Graphics:drawRect(component,x,y,width,height,rect)
            local box;
            if self.color[4] <= 0 or self.opacity <= 0 then
                return;
            end
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
                if box == nil then
                    print("无法绘制矩形:已超过最大限制");
                    return;
                end
                box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]*self.opacity});
            else
                box = UI.Box.Create();
                if box == nil then
                    print("无法绘制矩形:已超过最大限制");
                    return;
                end
                box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]*self.opacity});
            end
            box:Show();
            component.root[#component.root+1] = box;
        end;

        function Graphics:drawText(component,x,y,text,rect)
            if type(text) == "string" then
                text = String.toTable(text);
            end
            local ls = 0;
            for i=1,#text do
                local c = text[i]
                local boxArray = self.font:getChar(c);
                if #boxArray == 0 then
                    print("未找到字符:"..c);
                end
                for j = 1,#boxArray,4 do
                    local _x = boxArray[j];
                    local _y = boxArray[j+1];
                    local _width = boxArray[j+2];
                    local _height = boxArray[j+3];
                    if i == 1 then
                        self:drawRect(component,x + _x*self.pixelsize,y + _y*self.pixelsize,_width*self.pixelsize,_height*self.pixelsize,rect);
                    else
                        self:drawRect(component,x + ls + _x*self.pixelsize,y + _y*self.pixelsize,_width*self.pixelsize,_height*self.pixelsize,rect);
                    end
                end
                local charWidth = self.font:getCharSize(c,self.pixelsize);
                ls = ls + charWidth + self.letterspacing;
            end
        end

        function Graphics:drawBitmap(component,x,y,bitmap,rect)
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
                    self:drawRect(component,x + _x*bitmap.size,y + _y*bitmap.size,_width*bitmap.size,_height*bitmap.size,rect);
                end
            end
        end

    end);

    Graphics = Graphics:New();

    Class("Component",function(Component)
        function Component:constructor(x,y,width,height)
            self.root = {};
            self.x = x or 0;
            self.y = y or 0;
            self.width = width or 0;
            self.height = height or 0;

            self.parent = NULL;
            
            self.isvisible = false;
            self.stopplayercontrol = false;
            self.rect = {self.x,self.y,self.width,self.height};
            self.opacity = 1;
            self.backgroundcolor = {255,255,255,255};
            self.border = {0,0,0,0};
            self.bordercolor = {0,0,0,255};
            self.animations = {};
            
            self.font = Song;
            self.pixelsize = 2;
            self.letterspacing = 0;
            
            self.fontcolor = {0,0,0,255};
            
            self.animation = NULL;

            self.onkeydown = NULL;
            self.onkeyup = NULL;
        end

        function Component:onKeyDown()
            if self.onkeydown ~= NULL then
                self.onkeydown(self);
            end
        end

        function Component:onKeyUp()
            if self.onkeyup ~= NULL then
                self.onkeyup(self);
            end
        end

        function Component:setParent(container)
            if self.parent ~= NULL then
                self.parent:remove(self);
            end
            self.parent = NULL;
            for key, value in pairs(container) do
                print(key)
            end
            container:add(self);
        end

        function Component:show()
            if self.stopplayercontrol == true then
                UI.StopPlayerControl(true);
            end
            self:paint();
            self.isvisible = true;
        end

        function Component:hide()
            if self.stopplayercontrol == true then
                UI.StopPlayerControl(false);
            end
            self:clear();
            self.isvisible = false;
        end

        function Component:paint()
            Graphics.font = self.font;
            Graphics.pixelsize = self.pixelsize;
            Graphics.letterspacing = self.letterspacing;

            Graphics.color = self.backgroundcolor;
            Graphics.opacity = self.opacity;

            Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y,self.width,self.height);

            Graphics.color = self.bordercolor;

            Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y,self.width,self.border[1]);
            Graphics:drawRect(self,self.parent.x + self.x + self.width - self.border[2],self.parent.y + self.y,self.border[2],self.height);
            Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y + self.height - self.border[3],self.width,self.border[3]);
            Graphics:drawRect(self,self.parent.x + self.x,self.parent.y + self.y,self.border[4],self.height);
        end

        function Component:repaint()
            if self.isvisible == true then
                self:clear();
                self:paint();
            end
        end

        function Component:clear()
            self.root = {};
            collectgarbage("collect");
        end

        function Component:animate(params,step,callback)
            local style = {};
            for i = 1, #params, 1 do
                local table = params[i].table or self;
                local key = params[i].key;
                local value = params[i].value;

                style[#style+1] = {
                    table,
                    key,
                    (value - table[key]) / step,
                    value,
                };
            end
            if self.animation ~= NULL then
                self.animation.destroy = true;
            end
            self.animation = Timer:schedule(function()
                if step == 0 then
                    for i = 1, #style, 1 do
                        style[i][1][style[i][2]] = style[i][4];
                    end
                    if callback ~= nil then
                        callback(self);
                    end
                    self:repaint();
                    self.animation = NULL;
                    return true;
                end
                for i = 1, #style, 1 do
                    style[i][1][style[i][2]] = style[i][1][style[i][2]] + style[i][3];
                end
                step = step - 1;
                self:repaint();
                return false;
            end,0,3);
        end
    end);

    Class("Container",function(Container)
        function Container:constructor(x,y,width,height)
            self.super(x,y,width,height);
            self.children = {};
        end

        function Container:onKeyDown(inputs)
            for i = 1,#self.children do
                self.children[i]:onKeyDown(inputs);
            end
        end

        function Container:onKeyUp(inputs)
            for i = 1,#self.children do
                self.children[i]:onKeyUp(inputs);
            end
        end

        function Container:add(component,pos)
            if component.parent ~= NULL then
                component.parent:remove(component);
            end
            component.parent = self;
            table.insert(self.children,pos or #self.children + 1,component);
            return self;
        end

        function Container:remove(component)
            for i = 1,#self.children do
                if component == self.children[i] then
                    table.remove(self.children,i);
                    component.parent = NULL;
                    return;
                end
            end
        end

        function Container:repaint()
            if self.isvisible == true then
                self.super:repaint();
                for i = 1,#self.children do
                    self.children[i]:repaint();
                end
            end
        end

        function Container:show()
            self.super:show();
            for i = 1,#self.children do
                self.children[i]:show();
            end
        end

        function Container:hide()
            self.super:hide();
            for i = 1,#self.children do
                self.children[i]:hide();
            end
        end
    end,Component);

    Class("Windows",function(Windows)
        function Windows:constructor()
            self.super();
            self.parent = NULL;
            self.width = Graphics.width;
            self.height = Graphics.height;

            Event:addEventListener(Event.OnKeyDown,function(listener,inputs)
                self:onKeyDown(inputs);
            end);

            Event:addEventListener(Event.OnKeyUp,function(listener,inputs)
                self:onKeyUp(inputs);
           end);
        end
    end,Container);

    MainWindows = Windows:New();

    Class("Item",function(Item)
        function Item:constructor(name,value)
            self.super();
            self.parent = NULL;
            self.children = {};
            self.call = NULL;
            self.name = name;

            self:add(value);
        end

        function Item:add(value,pos)
            if type(value) == "function" then
                self.call = value;
            elseif type(value) == "table" then
                for i = 1, #value, 2 do
                    local item = _G.Item:New(value[i],value[i+1]);
                    item.parent = self;
                    self:addItem(item,pos);
                end
            end
        end

        function Item:addItem(item,pos)
            pos = pos or #self.children+1;
            table.insert(self.children,pos,item);
        end

        function Item:removeItem(name)
            for i = #self.children,1,-1 do
                if self.children[i].name == name then
                    table.remove(self.children,i);
                    return;
                elseif #self.children[i].children ~= 0 then
                    self.children[i]:remove(name);
                end
            end
        end

        function Item:getItem(name)
            for i = 1,#self.children do
                if self.children[i].name == name then
                    return self.children[i];
                end
            end
            return nil;
        end

    end,Component);

    Class("ItemMenu",function(ItemMenu)
        function ItemMenu:constructor(itemTree,hotkey)
            self.super(self.type,itemTree);

            self.page = 1;
            self.cursor = self;

            self.x = 0;
            self.y = 100;
            self.height = 200;
            self.width = 100;

            self.lineheight = 30;
            self.letterspacing = 5;

            self.backgroundcolor = {0,0,0,0};
            self.bordercolor = {0,0,0,0};

            self.hotkey = hotkey or UI.KEY.O;
        end

        function ItemMenu:onKeyDown(inputs)
            if inputs[self.hotkey] == true then
                if self.isvisible == true then
                    self:hide();
                else
                    self.page = 1;
                    self.cursor = self;
                    self:show();
                end
            end

            if self.isvisible == true then
                local item;
                if inputs[UI.KEY.NUM1] == true then
                    item = self.cursor.children[(self.page - 1) * 6 + 1]
                elseif inputs[UI.KEY.NUM2] == true then
                    item = self.cursor.children[(self.page - 1) * 6 + 2]
                elseif inputs[UI.KEY.NUM3] == true then
                    item = self.cursor.children[(self.page - 1) * 6 + 3]
                elseif inputs[UI.KEY.NUM4] == true then
                    item = self.cursor.children[(self.page - 1) * 6 + 4]
                elseif inputs[UI.KEY.NUM5] == true then
                    item = self.cursor.children[(self.page - 1) * 6 + 5]
                elseif inputs[UI.KEY.NUM6] == true then
                    item = self.cursor.children[(self.page - 1) * 6 + 6]
                elseif inputs[UI.KEY.NUM7] == true then
                    if self.page ~= 1 then
                        self.page = self.page - 1;
                        self:repaint();
                    end
                elseif inputs[UI.KEY.NUM8] == true then
                    if self.page * 6 < #self.cursor.children then
                        self.page = self.page + 1;
                        self:repaint();
                    end
                elseif inputs[UI.KEY.NUM9] == true then
                    if self.cursor.parent ~= NULL then
                        self.page = 1;
                        self.cursor = self.cursor.parent;
                        self:repaint();
                    end
                end
                if item ~= nil then
                    if item.call ~= NULL then
                        local success,result =  pcall(item.call);
                        if result ~= true then
                            self:hide();
                        end
                    end
                    if #item.children ~= 0 then
                        self.cursor = item;
                    end
                    self:repaint();
                end
            end
        end

        function ItemMenu:paint()
            self.super:paint();
            Graphics.color = self.fontcolor;

            local __,height = Song:getCharSize("A",self.pixelsize);
            height = height + self.lineheight;

            for i = 1,6 do
                if self.cursor.children[(self.page - 1) * 6 + i] == nil then
                    break;
                end
                Graphics:drawText(self,self.x,self.y + (i * height),i..'.'..self.cursor.children[(self.page - 1) * 6 + i].name);
            end
            if self.page ~= 1 then
                Graphics:drawText(self,self.x,self.y + 7 * height,"7.上一页");
            end

            if self.page * 6 < #self.cursor.children then
                Graphics:drawText(self,self.x,self.y + 8 * height,"8.下一页");
            end

            if self.cursor.parent ~= NULL then
                Graphics:drawText(self,self.x,self.y + 9 * height,"9.返回");
            end
        end

    end,Item);

    MainMenu = ItemMenu:New(
        {"帮助",{
        "关于",function()
            Toast:makeText("作者:@iPad水晶");
         end,
        }},UI.KEY.O);
    MainWindows:add(MainMenu);

    Class("Lable",function(Lable)
        function Lable:constructor(x,y,width,height,text,font)
            self.super(x,y,width,height);
            self.offx = 0;
            self.offy = 0;
            self.align = "center" or "left"or "right";
            self.charArray = String.toTable(text or "");
            self.font = font or self.font;
        end

        function Lable:paint()
            self.super:paint();
            Graphics.color = self.fontcolor;

            local w,h = self.font:getTextSize(self.charArray,self.pixelsize,self.letterspacing);

            if self.align == "center" then
                Graphics:drawText(self,self.parent.x + self.x + self.offx + (self.width - w)/2,self.parent.y + self.y + self.offy,self.charArray);
            elseif self.align == "left" then
                Graphics:drawText(self,self.parent.x + self.x + self.offx,self.parent.y + self.y + self.offy,self.charArray);
            elseif self.align == "right" then
                Graphics:drawText(self,self.parent.x + self.x + self.offx + (self.width - w),self.parent.y + self.y + self.offy,self.charArray);
            end
        end

        function Lable:getText()
            return String.toString(self.charArray);
        end

        function Lable:setText(text)
            self.charArray = String.toTable(text or "");
            self:repaint();
        end

    end,Component);

    Class("Edit",function(Edit)
        function Edit:constructor(x,y,width,height,text,font)
            self.super(x,y,width,height,text,font);
            self.cursor = 0;
            self.maxlength = 10;
            self.intype = "number";

            self.keyprevious = UI.KEY.LEFT;
            self.keynext = UI.KEY.RIGHT;
            self.keybackspace = UI.KEY.SHIFT;
        end

        function Edit:onKeyDown(inputs)
            self.super:onKeyDown(inputs);
            if self.isvisible == true then
                for key, value in pairs(inputs) do
                    if value == true then
                        if #self.charArray < self.maxlength then
                            if self.intype == "all" or self.intype == "number" then
                                if key >=0 and key <= 8 then
                                    table.insert(self.charArray,self.cursor+1,string.char(key+49));
                                    self.cursor = self.cursor + 1;
                                end
                                if key == 9 then
                                    table.insert(self.charArray,self.cursor+1,"0");
                                    self.cursor = self.cursor + 1;
                                end
                            end

                            if self.intype == "all" or self.intype == "english" then
                                if key >= 10 and key <= 35 then
                                    table.insert(self.charArray,self.cursor+1,string.char(key+87));
                                    self.cursor = self.cursor + 1;
                                end

                                if key == 37 then
                                    table.insert(self.charArray,self.cursor+1,' ');
                                    self.cursor = self.cursor + 1;
                                end
                            end
                        end
                        if key == self.keyprevious then
                            if self.cursor > 0 then
                                self.cursor = self.cursor - 1;
                            end
                        end
                        if key == self.keynext then
                            if self.cursor < #self.charArray then
                                self.cursor = self.cursor + 1;
                            end
                        end
                        if key == self.keybackspace then
                            if self.cursor > 0 then
                                table.remove(self.charArray,self.cursor);
                                self.cursor = self.cursor - 1;
                            end
                        end
                    end
                end
                self:repaint();
            end
        end

        function Edit:paint()
            self.super:paint();
            local textArray = {};
            for i = 1,self.cursor do
                textArray[#textArray+1] = self.charArray[i];
            end
            local w,h = self.font:getTextSize(textArray,self.pixelsize,self.letterspacing);

            if self.align == "left" then
                Graphics:drawRect(self,self.parent.x + self.x + w + self.offx + 1,self.parent.y + self.y +self.offy,self.letterspacing /3 + self.pixelsize,h);
            elseif self.align == "center" then
                local tw,th = self.font:getTextSize(self.charArray,self.pixelsize,self.letterspacing);
                Graphics:drawRect(self,self.parent.x + self.x + w + self.offx + (self.width - tw)/2 + 1,self.parent.y + self.y +self.offy,self.letterspacing /3 + self.pixelsize,h);
            elseif self.align == "right" then
                local tw,th = self.font:getTextSize(self.charArray,self.pixelsize,self.letterspacing);
                Graphics:drawRect(self,self.parent.x + self.x + w + self.offx + (self.width - tw) + 1,self.parent.y + self.y +self.offy,self.letterspacing /3 + self.pixelsize,h);
            end
        end

    end,Lable);


    Class("Toast",function(Toast)
        function Toast:constructor()
            self.super(0,0,100,100,"QWQ");
            self.letterspacing = 5;
        end

        function Toast:makeText(text,length,x,y)
            self:setText(text);

            local w,h = self.font:getTextSize(text,self.pixelsize,self.letterspacing);

            self.x = x or (MainWindows.width - w)/2;
            self.y  = y or MainWindows.height * 0.8;
            self.width = w + 3 * self.pixelsize;
            self.height = h + 3 * self.pixelsize;


            self.backgroundcolor = {0,0,0,255};
            self.opacity = 1;
            self.fontcolor = {255,255,255,255};
            self:show();
            self:animate({{key = "opacity",value = 0}},length or 120,function(self)
                self:hide();
            end);
        end
    end,Lable);

    Toast = Toast:New();
    MainWindows:add(Toast);

    Class("PictureBox",function(PictureBox)
        function PictureBox:constructor(x,y,width,height,bitmap)
            self.super(x,y,width,height);
            self.bitmap = bitmap;
            self.backgroundcolor[4] = 0;
        end

        function PictureBox:paint()
            self.super:paint();
            Graphics:drawBitmap(self,self.x,self.y,self.bitmap,{self.x,self.y,self.width,self.height});
        end

    end,Component);
end


----------------------------------------------------
----------------------------------------------------
----------------------------------------------------


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
