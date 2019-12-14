Instanceof,Clone,Create,New = (function()

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
    
    return instanceof,clone,create,new;
        
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
    
            Create(String,"String");
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
        Create(Event,"Event");
    end)();
    
    (function ()
        local Graphics = {};

        function Graphics:constructor()
            self.root = {};
            self.color = {red = 255,green = 255,blue=255,alpha=255};
        end

        function Graphics:drawRect(x,y,width,height)
            local box = UI.Box.Create();
            box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha});
            box:Show();
            table.insert(self.root,box);
        end;
    
        function Graphics:drawText(x,y,string)
            
        end

        Create(Graphics,"Graphics");
        
    end)();

    (function()
            local Component = {};
            function Component:constructor(id)
                self.id = id or self.type;
                
                self.x = 0;
                self.y = 0;
                self.width = 0;
                self.height = 0;
                self.isfocus = false;
                self.style = {
                    left = 0,
                    top = 0,
                    width = 0,
                    height = 0,
                    position = "relative",
                    backgroundcolor = {red = 0,green = 0,blue=0,alpha=0};
                    border = 1;
                    bordercolor = {red = 0,green = 0,blue=0,alpha=0};
                    newline = false;
                    letterspacing = 0;
                };
                self.tag = self.type;
                self.father = nil;
                self.children = {};
            end
    
            function Component:isFocuse()
                return self.isfocus;
            end
    
            function Component:add(...)
                local components = {...};
                for i = 1, #components, 1 do
                    components[i].father = self;
                    table.insert(self.children,components[i]);
                end
                return self;
            end

            --获取焦点事件
            function Component:onfocus()
                
            end
            --失去焦点事件
            function Component:onblur()
                
            end
            --键盘抬起事件
            function Component:keydown(keycode)
    
            end
            --键盘按下事件
            function Component:keyup(keycode)
    
            end
            --键盘按下抬起事件
            function Component:keypress(keycode)
                
            end
        
            function Component:paint(graphics)
                --graphics.drawRect(self.x,self.y,self.width,self.height);
            end
    
            function Component:toString()
                return self.x .. "_" .. self.y .. "_" .. self.width .. "_" .. self.height;
            end
    
            Create(Component,"Component");
    end)();

    (function()
        local Frame = {};
        function Frame:constructor(width,height)
            self.super:constructor();
            self.super.width = width or 300;
            self.super.height = height or 300;
            self.graphics = New("Graphics");
        end
    
        function Frame:reset(component)
        local components = {};
        if component == nil then
            for i = 1, #self.children, 1 do
                table.insert(components,self.children[i]);
            end
        else
            table.insert(components,component);
        end

        local i = 1;
        while i < #components + 1 do
            if components[i].style.position == "relative" then
                components[i].width = components[i].father.width * (components[i].style.width /100);
                components[i].height = components[i].father.height * (components[i].style.height /100);

                if i == 1 then
                    components[i].x = self.x + components[i].father.width * (components[i].style.left /100);
                    components[i].y = self.y + components[i].father.height * (components[i].style.top /100);
                else
                    if components[i].style.newline == true then
                        local j = i - 1;
                        local temp = components[j];
                        while temp.father == components[j].father do
                            if temp.style.newline == true then
                                components[i].x = components[i].father.width * (components[i].style.left /100);
                                components[i].y = temp.y + temp.height + components[i].father.height * (components[i].style.top /100);
                                break;
                            end
                            j = j - 1;
                            if j < 1 then
                                break;
                            end
                            temp = components[j];
                        end
                        if j == 0 then
                            components[i].x = components[i].father.x + components[i].father.width * (components[i].style.left /100);
                            components[i].y = components[i].father.children[1].y + components[i].father.children[1].height + components[i].father.height * (components[i].style.top /100);
                        end
                    else
                        components[i].x = components[i - 1].x + components[i - 1].width + components[i].father.width * (components[i].style.left /100);
                        components[i].y = components[i - 1].y + components[i].father.height * (components[i].style.top /100);
                    end
                end

            elseif components[i].style.position == "absolute" then
                components[i].x = components[i].father.x + components[i].father.width * (components[i].style.left /100);
                components[i].y = components[i].father.y + components[i].father.height * (components[i].style.top /100);
            end

            for j = 1, #components[i].children, 1 do
                table.insert(components,components[i].children[j]);
            end

            i = i + 1;
        end
        end
    
        function Frame:paint(component)
            if component == nil then
                for i = 1, #self.children, 1 do
                    self:paint(self.children[i]);
                end
            else
                component:paint(self.graphics);
                for i = 1, #component.children, 1 do
                    self:paint(component.children[i]);
                end
            end
        end
    
        function Frame:findById(id,component)
            component = component or self;
            if id == component.id then
                return component;
            end
            for i = 1, #component.children, 1 do
                self:findById(id,component.children[i]);
            end
            return nil;
        end

        function Frame:findByTag(tag)
            
        end
        Create(Frame,"Frame","Component");
    end)();
    
    (function()
        local Lable = {};
        
        function Lable:constructor()
            self.super(self.type);
        end
    
        function Lable:paint()
    
        end
    
        Create(Lable,"Lable","Component");
    end)();
    
    (function()
        local Edit = {};
        
        function Edit:constructor()
            self.super(self.type);
        end
    
        function Edit:paint(graphics)
    
        end
    
        Create(Edit,"Edit","Lable");
    end)();
    
    
    (function()
        local ListBox = {};
        
        function ListBox:constructor()
            self.super(self.type);
        end
    
        function ListBox:paint(graphics)
    
        end
    
        Create(ListBox,"ListBox","Component");
    end)();
    
    (function()
        local Plane = {};
        
        function Plane:constructor()
            self.super(self.type);
        end

        function Plane:paint(graphics)
            
        end
    
        Create(Plane,"Plane","Component");
    end)();
    
    Frame = New("Frame",300,300);
    Component1 = New("Component");
    Component1.style.left = 15;
    Component1.style.width = 15;

    Component2 = New("Component");

    Frame:add(Component1,Component2);

    Frame:reset();
    Frame:paint();
