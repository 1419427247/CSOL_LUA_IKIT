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

    function String:subString(beginindex,length)
        local builder = {};
        for i = beginindex, beginindex + length - 1, 1 do
            builder[#builder + 1] = self.array[i];
        end
        return table.concat(builder);
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
        if type(event) == "string" then
            event = self[event];
        end
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

    function Event:forEach(event,...)
        if type(event) == "string" then
            event = self[event];
        end

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

Class("Font",function(Font)
    function Font:constructor(size)
        self.data = {};
        self.map = {
            [' '] = {},
        };
        self.size = size or 3;
        self.letterspacing = 50;
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
end);

Class("Bitmap",function(Bitmap)
    function Bitmap:constructor(data)
        local i = 1;
        local s = i;
        self.data = {};
        self.size = 1;
        self.map = NULL;
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
end);


Class("Graphics",function(Graphics)
    function Graphics:constructor()
        self.color = {255,255,255,255};
    end

    function Graphics:drawText(x,y,font,text)
        local array = {};
        for i=1,text.length do
            local c = text:charAt(i)
            local charArray = font:getChar(c);
            if #charArray == 0 then
                print("未找到字符:"..c);
            end
            for j = 1,#charArray,4 do
                local _x = charArray[j];
                local _y = charArray[j+1];
                local _width = charArray[j+2];
                local _height = charArray[j+3];
                local box = UI.Box.Create();
                if box == nil then
                    print("无法绘制矩形:已超过最大限制");
                    return array;
                end
                if i == 1 then
                    box:Set({x=x + _x*font.size,y=y + _y*font.size,width=_width*font.size,height=_height*font.size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                else
                    box:Set({x=x + (i-1) * font.letterspacing + _x*font.size,y=y + _y*font.size,width=_width*font.size,height=_height*font.size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                end
                array[#array+1] = box;
                box:Show();
            end
        end
        return array;
    end

    function Graphics:drawBitmap(x,y,bitmap)
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
                local box = UI.Box.Create();
                if box == nil then
                    print("无法绘制矩形:已超过最大限制");
                    return;
                end
                box:Set({x=x + _x*bitmap.size,y=y + _y*bitmap.size,width=_width*bitmap.size,height=_height*bitmap.size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                array[#array+1] = box;
                box:Show();
            end
        end
        return array;
    end

end);

Class("Component",function(Component)
    function Component:constructor()
        self.root = {};

        self.id = NULL;
        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
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

Class("Lable",function(Lable)
    function Lable:constructor(x,y,font,text)
        self.super();
        self.x = x;
        self.y = y;
        self.font = font;
        self.text = String:New(text);
        self:paint();
    end

    function Lable:paint()
            self.root = Graphics:drawText(self.x,self.y,self.font,self.text);
    end

end,Component);

Class("PictureBox",function(PictureBox)
    function PictureBox:constructor(x,y,bitmap)
        self.super();
        self.x = x;
        self.y = y;
        self.bitmap = bitmap;
        self:paint();
    end

    function PictureBox:paint()
            self.root = Graphics:drawBitmap(self.x,self.y,self.bitmap);
    end

end,Component);



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


Event = Event:New();


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

    Base64 = Base64:New();

    Song = Font:New();

    Graphics = Graphics:New();
end



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
