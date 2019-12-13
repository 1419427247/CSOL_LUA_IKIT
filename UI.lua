Class = (function()

    local class = {};

    class["Object"] = {
        type = "Object",
        __newindex = function (table,key,value)
            local tobject = table;
            while tobject ~= nil do
                for _key, _value in pairs(tobject) do
                    if key == _key then
                        rawset(tobject,key,value);
                        return;
                    end
                end
                tobject = getmetatable(tobject);
            end
            rawset(table,key,value);
            --error("error: cannot find symbol : " .. key)
        end,
        __call = function(table,...)
            table:constructor(...);
        end,
        __tostring = function(table)
            if table.toString ~= nil then
                return table:toString();
            end
            return table.super:__tostring();
        end,
        toString = function(table)
            return table.type;
        end
    };
    
    local function instanceof(table,string)
        if type(table) == "table" and  type(string) == "string" then
            local object = table;
            while object ~= nil do
                if object.type() == string then
                    return true;
                else
                    object = getmetatable(object);
                end
            end
        end
        return false;
    end
    
    local function clone(talbe)
        local object = {};
        for key, value in pairs(talbe) do
            object[key] = value;
        end
    
        if getmetatable(talbe) ~= nil then
            object.super = clone(getmetatable(talbe))
            object.__newindex = object.super.__newindex;
            object.__call = object.super.__call;
            object.__tostring = object.super.__tostring;
            object.__index = object;
            setmetatable(object,object.super);
        end
        return object;
    end
    
    local function create(object,name,father)
        
        if object.constructor == nil then
            function object:constructor()
            end
        end
    
        if father ~= nil then
            setmetatable(object,class[father]);
        else
            setmetatable(object,class["Object"]);
        end
        rawset(object,"type",name);
        class[name] = object;
    end
    
    local function new(name,...)
        local object = clone(class[name]);
        object:constructor(...);
        return setmetatable({},object);
    end
    
    return {
        Instanceof = instanceof;
        Clone = clone;
        Create = create;
        New = new;
    };
    end)();
    
    (function()
            local function charSize(str, index)
                local curByte = string.byte(str, index)
                local seperate = {0, 0xc0, 0xe0, 0xf0}
                for i = #seperate, 1, -1 do
                    if curByte >= seperate[i] then return i end
                end
                return 1
            end
            local String = {};
    
            function String:constructor(string)
                self.array = {};
                self.length = 0;
                if type(string) == "string" then
                    local currentIndex = 1;
                    while currentIndex <= #string do
                        self.length = self.length +1;
                        local cs = charSize(string, currentIndex);
                        table.insert(self.array,string.sub(string,currentIndex,currentIndex+cs-1));
                        currentIndex = currentIndex + cs;
                    end
                elseif type(string) == "table" then
                    for i = 1, string.length, 1 do
                        table.insert(self.array,string.array[i]);
                    end
                    self.length = string.length;
                end
            end
    
            function String:charAt(index)
                return self.array[index];
            end
    
            function String:substring(beginIndex,endIndex)
                local string = {};
                for i = beginIndex, endIndex, 1 do
                    table.insert(string,self.array[i]);
                end
                return table.concat(string);
            end
    
            function String:isEmpty()
                return self.length == 0;
            end
    
            function String:toString()
                return table.concat(self.array);
            end
    
            function String:__len()
                return self.length;
            end
    
            function String:__eq(string)
                return self.length == string.length and function()
                    for i = 1, self.length, 1 do
                        if self.array[i] ~= string.array[i] then
                            return false;
                        end
                    end
                    return true;
                end
            end
    
            function String:__call(index)
                return self.array[index];
            end
    
            Class.Create(String,"String");
        end)();
    
    
        (function()
        local Event = {};
        function Event:__add(event)
            if not self[event] then
                rawset(self,event,setmetatable({},{
                    __add = function(lis,handle)
                        -- if type(handle) ~= "function" then
                        -- 	error("It is not a function");
                        -- end
                        table.insert(lis,handle);
                        return lis;
                    end,
                     __sub = function(lis,handle)
                        for i = 1, #lis, 1 do
                            if lis[i] == handle then
                                table.remove(lis,i);
                                break;
                            end
                        end
                        return lis;
                    end,
                    __call = function(table,...)
                        for __, value in pairs(table) do
                            value(...);
                        end
                    end
                }));
                return self;
            end
            error("Event: '" ..event.."' already exists");
        end
    
        function Event:__sub(event)
            if self[event] then
                rawset(self,event,nil);
                return self;
            end
            error("Event: '" ..event.."' does not exist");
        end
    
        function Event:constructor()
    
        end
        Class.Create(Event,"Event");
    end)();
    
    (function()
        local Frame = {};
        function Frame:constructor(width,height)
            self.graphics = {
                color = {red = 0,green = 0,blue=0,alpha=0};
                drawRect =  function(x,y,width,height)
                --table.insert(self.root,xxx);
                end,
                drawText = function(x,y,width,height)
                    
                end,
            }
            self.root = {};
            
            self.x = 0;
            self.y = 0;
            self.width = width;
            self.height = height;
    
        end
        
        function Frame:add(component)
            component.father = self;
            table.insert(self.root,component);
        end
    
        function Frame:reset(component)
            component = component or self.root;
    
    
            component.x = component.father.x + component.father.width * (component.style.left /100);
            component.y = component.father.y + component.father.height * (component.style.top /100);
    
            component.width = component.father.width * (component.style.width /100);
            component.height = component.father.height * (component.style.height /100);
    
            for i = 1, #component.children, 1 do
                self:reset(component.children[i]);
            end
        end
    
        
        function Frame:paint(component)
            component.paint(self.graphics);
            for i = 1, #component.children,1 do
                component.children.paint(self.graphics);
            end
        end
    
        Class.Create(Frame,"Frame");
    end)();
    
    (function()
            local Component = {};
            function Component:constructor(id)
                self.id = id or self.type;
                
                self.x = 0;
                self.y = 0;
                self.width = 0;
                self.height = 0;
                self.array = {};
                self.isfocus = false;
                self.style = {
                    left = 0,
                    top = 0,
                    width = 0,
                    height = 0,
                    backgroundcolor = {red = 0,green = 0,blue=0,alpha=0};
                    border = 1;
                    bordercolor = {red = 0,green = 0,blue=0,alpha=0};
                    letterspacing = 0;
                };
                self.tag = self.type;
                self.father = nil;
                self.children = {};
            end
    
            function Component:add(component)
                table.insert(self.children,component);
            end
    
            function Component:isFocuse()
                return self.isfocus;
            end
    
            --获取焦点事件
            function Component:onfocus()
    
            end
            --失去焦点事件
            function Component:onblur()
    
            end
            --键盘抬起事件
            function Component:keydown()
    
            end
            --键盘按下事件
            function Component:keyup()
    
            end
            --键盘按下抬起事件
            function Component:keypress()
                
            end
        
            function Component:paint()
    
            end
    
            function Component:toString()
                return self.x .. "_" .. self.y .. "_" .. self.width .. "_" .. self.height;
            end
    
            Class.Create(Component,"Component");
    end)();
    
    (function()
        local Lable = {};
        
        function Lable:constructor()
            self.super(self.type);
        end
    
        function Lable:paint()
    
        end
    
        Class.Create(Lable,"Lable","Component");
    end)();
    
    (function()
        local Edit = {};
        
        function Edit:constructor()
            self.super(self.type);
        end
    
        function Edit:paint()
    
        end
    
        Class.Create(Edit,"Edit","Lable");
    end)();
    
    
    (function()
        local ListBox = {};
        
        function ListBox:constructor()
            self.super(self.type);
        end
    
        function ListBox:paint()
    
        end
    
        Class.Create(ListBox,"ListBox","Component");
    end)();
    
    (function()
        local Plane = {};
        
        function Plane:constructor()
            self.super(self.type);
        end
    
        function Plane:paint()
    
        end
    
        Class.Create(Plane,"Plane","Component");
    end)();
    
    
    
    b = Class.New("Frame");

    c = Class.New("Edit");
    print(c.type)