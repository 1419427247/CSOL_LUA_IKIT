Clone,Create,New = (function()

    local class = {};

    class["Object"] = {
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
        end
    };

    -- local function instanceof(table,string)
    --     if type(table) == "table" and  type(string) == "string" then
    --         local object = table;
    --         while object ~= nil do
    --             if object.type == string then
    --                 return true;
    --             else
    --                 object = getmetatable(object);
    --             end
    --         end
    --     end
    --     return false;
    -- end

    local function clone(talbe)
        local object = {};
        for key, value in pairs(talbe) do
            object[key] = value;
        end

        if getmetatable(talbe) ~= nil then
            object.super = clone(getmetatable(talbe))
            object.__newindex = object.super.__newindex;
            object.__call = object.super.__call;
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
        class[name] = object;
    end

    local function new(name,...)
        local object = clone(class[name]);
        object:constructor(...);
        return setmetatable({},object);
    end

    return clone,create,new;

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
                    self.length =  string.length;
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

            function String:__add(string)
                if type(string) == "string" then
                    local currentIndex = 1;
                    while currentIndex <= #string do
                        self.length = self.length +1;
                        local cs = charSize(string, currentIndex);
                        table.insert(self.array,string.sub(string,currentIndex,currentIndex+cs-1));
                        currentIndex = currentIndex + cs;
                        self.length =   self.length + 1;
                    end
                elseif type(string) == "table" then

                    for i = 1, string.length, 1 do
                        table.insert(self.array,string.array[i]);
                    end
                    self.length = self.length +  string.length;
                end
                return self;
            end

            function String:__call(index)
                return self.array[index];
            end

            Create(String,"String");
        end)();


    (function()
        local Event = {};

        function Event:constructor()

        end

        function Event:__add(type)
            if not self[type] then
                rawset(self,type,setmetatable({},{
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
            error("Event: '" ..type.."' already exists");
        end

        function Event:__sub(event)
            if self[event] then
                rawset(self,event,nil);
                return self;
            end
            error("Event: '" ..event.."' does not exist");
        end

        function Event:addEventListener(type,event)
            table.insert(self[type],event);
        end

        function Event:detachEventListener(type,event)
            for i = 1, #self[type], 1 do
                if self[type][i] == event then
                    table.remove(self[type],i);
                end
            end
        end

        function Event:forEach(type,...)
            for i = 1, #self[type], 1 do
                self[type][i](...);
            end
        end

        Create(Event,"Event");
    end)();

    Event = New("Event");


    Event = Event + "OnKeyDown";
    Event = Event + "OnKeyUp";


    -- function UI.Event:OnKeyDown(inputs)
    --     Event["OnKeyDown"](inputs);
    -- end

    -- function UI.Event:OnKeyUp (inputs)
    --     Event["OnKeyUp"](inputs);
    -- end


    (function ()
        local Font = {};
        Font["a"] = {0,0,1,4,2,0,3,4,1,1,2,2,1,4,2,5};
        Font["b"] = {0,0,1,5,1,0,2,1,1,2,2,3,1,4,2,5,2,1,3,2,2,3,3,4};
        Font["c"] = {0,1,1,4,1,0,3,1,1,4,3,5};
        Font["d"] = {0,0,1,5,1,0,2,1,1,4,2,5,2,1,3,4};
        Font["e"] = {0,1,1,4,1,0,3,1,1,2,3,3,1,4,3,5};
        Font["f"] = {0,0,1,4,1,2,3,3,1,4,3,5};
        Font["g"] = {0,1,1,4,1,0,2,1,2,0,3,3,1,4,3,5};
        Font["h"] = {0,0,1,5,2,0,3,5,1,2,2,3};
        Font["i"] = {1,0,2,5};
        Font["j"] = {0,1,1,3,1,0,2,1,2,1,3,5};
        Font["k"] = {0,0,1,5,2,0,3,2,2,3,3,5,1,2,2,3};
        Font["l"] = {0,1,1,5,1,0,3,1};
        Font["m"] = {0,0,1,5,2,0,3,5,1,3,2,4};
        Font["n"] = {0,0,1,5,1,4,2,5,2,0,3,4};
        Font["o"] = {0,1,1,4,2,1,3,4,1,0,2,1,1,4,2,5};
        Font["p"] = {0,0,1,4,1,1,2,2,1,4,2,5,2,2,3,4};
        Font["q"] = {0,2,1,4,2,2,3,4,1,0,2,2,1,4,2,5};
        Font["r"] = {0,0,1,4,1,1,2,2,1,4,2,5,2,2,3,4,2,0,3,1};
        Font["s"] = {0,0,2,1,2,1,3,2,1,2,2,3,0,3,1,4,1,4,3,5};
        Font["t"] = {0,4,3,5,1,0,2,4};
        Font["u"] = {0,0,1,5,1,0,2,1,2,1,3,5};
        Font["v"] = {0,1,1,5,1,0,2,1,2,1,3,5};
        Font["w"] = {0,0,1,5,2,0,3,5,1,1,2,2};
        Font["x"] = {0,0,1,2,0,3,1,5,2,0,3,2,2,3,3,5,1,2,2,3};
        Font["y"] = {0,3,1,5,2,3,3,5,1,0,2,3};
        Font["z"] = {0,0,3,1,0,4,3,5,0,1,1,2,1,2,2,3,2,3,3,4};
        Font["0"] = {0,0,1,5,2,0,3,5,1,0,2,1,1,4,2,5};
        Font["1"] = {1,0,2,5,0,3,1,4};
        Font["2"] = {0,0,1,3,2,2,3,5,1,0,3,1,1,2,2,3,0,4,2,5};
        Font["3"] = {2,0,3,5,0,0,2,1,0,2,2,3,0,4,2,5};
        Font["4"] = {0,2,1,5,2,0,3,5,1,2,2,3};
        Font["5"] = {0,2,1,5,0,0,3,1,1,2,3,3,1,4,3,5,2,1,3,2};
        Font["6"] = {0,0,1,5,1,0,3,1,1,2,3,3,1,4,3,5,2,1,3,2};
        Font["7"] = {0,4,3,5,2,0,3,4};
        Font["8"] = {0,0,1,5,2,0,3,5,1,0,2,1,1,2,2,3,1,4,2,5};
        Font["9"] = {0,0,3,1,2,1,3,5,0,2,1,5,1,2,2,3,1,4,2,5};
        Font["."] = {1,0,2,1};
        Font[":"] = {1,1,2,2,1,3,2,4};
        Font["?"] = {1,0,2,1,1,2,2,3,2,2,3,5,0,4,2,5};
        Font["!"] = {1,0,2,1,1,2,2,5};
        Font["+"] = {1,1,2,4,0,2,3,3};
        Font["-"] = {0,2,3,3};
        Font["("] = {0,1,1,4,1,0,2,1,1,4,2,5};
        Font["("] = {2,1,3,4,1,0,2,1,1,4,2,5};
        Font[">"] = {0,0,1,1,1,1,2,2,2,2,3,3,0,4,1,5,1,3,2,4};
        Font["<"] = {0,2,1,3,1,1,2,2,0,2,1,3,1,3,2,4,2,4,3,5};
        Font["="] = {0,1,3,2,0,3,3,4};
        Font["\'"] ={1,3,2,5};
        Font["\\"] ={0,3,1,5,1,2,2,3,2,0,3,2};
        Font["/"] = {0,0,1,2,1,2,2,3,2,3,3,5};

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

        function Graphics:drawText(x,y,size,letterSpacing,string)
            for i=1,string.length do
                local char = string:charAt(i)
                if(Font[char] ~= nil) then
                    local j=1;
                    while j < #Font[char] do
                        local x1 = Font[char][j];
                        local y1 = Font[char][j+1];
                        local x2 = Font[char][j+2];
                        local y2 = Font[char][j+3];
                        local box = UI.Box.Create();
                        if i == 1 then
                            box:Set({x =x + x1*size, y = y - y1*size , width = (x2 -x1)*size, height = (y2-y1)*-size, r = self.color.red, g = self.color.green, b = self.color.blue, a = self.color.alpha})
                        else
                            box:Set({x =(i-1) * letterSpacing + x + x1*size, y = y - y1*size , width = (x2 -x1)*size, height = (y2-y1)*-size, r = self.color.red, g = self.color.green, b = self.color.blue, a = self.color.alpha})
                        end
                        box:Show();
                        table.insert(self.root,box);
                        j = j + 4;
                    end
                end
            end
        end

        function Graphics:getTextSize(size,letterSpacing,string)
            local width = (string.length - 1) * letterSpacing + 3 * size;
            local height = 5 * size;
            return width,height;
        end

        function Graphics:clean()
            for i = 1, #self.root, 1 do
                self.root[i]:Hide();
            end
            self.root = {};
        end

        Create(Graphics,"Graphics");

    end)();

    (function()
        local Frame = {};
        function Frame:constructor(width,height)
            self.x=0;
            self.y=0;
            self.width = width or 100--UI.ScreenSize().width;
            self.height = height or 100--UI.ScreenSize().height;
            self.graphics = New("Graphics");
            self.children = {};

            Event["OnKeyDown"] = Event["OnKeyDown"] + function (inputs)
                self:OnKeyDown(inputs);
            end;
            Event["OnKeyUp"] = Event["OnKeyUp"] + function (inputs)
                self:OnKeyUp(inputs);
            end;
        end

        function Frame:add(...)
            local components = {...};
            for i = 1, #components, 1 do
                components[i].father = self;
                table.insert(self.children,components[i]);
            end
            return self;
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

        function Frame:forEach(fun)
            local function forEach(component)
                if fun(component) == false then
                    return;
                end
                for i = 1, #component.children, 1 do
                    forEach(component.children[i]);
                end
            end
            for i = 1, #self.children, 1 do
                forEach(self.children[i]);
            end
        end

        function Frame:paint()
            self:forEach(function(component)
                component:paint(self.graphics);
            end);
        end

        function Frame:repaint()
            self.graphics:clean();
            self:paint();
        end

        function Frame:findById(id)
            local recomponent = nil;
            self:forEach(function(component)
                if id == component.id then
                    recomponent = component;
                    return false;
                end
            end);
            return recomponent;
        end

        function Frame:findByTag(tag)
            local components = {};
            self:forEach(function(component)
                if tag == component.tag then
                    table.insert(components,component);
                end
            end);
            return components;
        end

        function Frame:OnKeyDown(inputs)
            self:forEach(function(component)
                if component.isfocus == true then
                    component:OnKeyDown(inputs)
                    return false;
                end
            end);
        end

        function Frame:OnKeyUp(inputs)
            self:forEach(function(component)
                if component.isfocus == true then
                    component:OnKeyUp(inputs)
                    return false;
                end
            end);
        end

        Create(Frame,"Frame");
    end)();


    (function()
            local Component = {};
            function Component:constructor(id)
                self.id = id;
                self.tag = "Component";
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
                    backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
                    border = {top = 0,left = 0,right = 0,bottom = 0},
                    bordercolor = {red = 0,green = 0,blue=0,alpha=255},
                    newline = false,
                    fontsize = 15,
                    letterspacing = 50,
                    textalign = "center",
                };
                self.father = 0;
                self.children = {};
            end

            function Component:add(...)
                local components = {...};
                for i = 1, #components, 1 do
                    components[i].father = self;
                    table.insert(self.children,components[i]);
                end
                return self;
            end

            function Component:paint(graphics)
                -- graphics.color = self.style.backgroundcolor;
                -- graphics:drawRect(self.x,self.y,self.width,self.height);
                -- if self.style.border > 0 then
                --     graphics.color = self.style.bordercolor;
                --     graphics:drawRect(self.x,self.y,self.width,self.style.border);
                --     graphics:drawRect(self.x + self.width - self.style.border,self.y,self.style.border,self.height);
                --     graphics:drawRect(self.x,self.y + self.height - self.style.border,self.width,self.style.border);
                --     graphics:drawRect(self.x,self.y,self.style.border,self.height);
                -- end
            end

            function Component:onBlur()
                print(self.tag .. "lost");
            end

            function Component:onFocus()
                print(self.tag .. "get");
            end

            function Component:setFocus(bool)
                self.isfocus = bool;
                if bool == true then
                    self:onFocus();
                else
                    self:onBlur();
                end
            end

            function Component:OnKeyDown(inputs)

            end
            
            function Component:OnKeyDown(inputs)

            end


            function Component:repaint()
                print(self.tag)
                self.father:repaint();
            end
            
            Create(Component,"Component");
    end)();

    (function()
        local Lable = {};

        function Lable:constructor(id,text)
            self.super(id);
            self.tag = "Lable";
            self.text = New("String",text);
        end

        function Lable:paint(graphics)
            -- self.super:paint(graphics);
            -- local w,h = graphics:getTextSize(self.style.fontsize,self.style.letterspacing,self.text);
            -- if self.style.textalign == "center" then
            --     graphics:drawText(self.x + (self.width - w)/2,self.y + (self.height + h) / 2,self.style.fontsize,self.style.letterspacing,self.text);
            -- elseif self.style.textalign == "left" then
            --     graphics:drawText(self.x,self.y + (self.height + h) / 2,self.style.fontsize,self.style.letterspacing,self.text);
            -- elseif self.style.textalign == "rigth" then
            --     graphics:drawText(self.x + (self.width - w),self.y + (self.height + h) / 2,self.style.fontsize,self.style.letterspacing,self.text);
            -- end
        end

        Create(Lable,"Lable","Component");
    end)();

    (function()
        local Edit = {};

        function Edit:constructor(id)
            self.super(id);
            self.text = New("String");
        end

        function Edit:paint(graphics)
            self.super:paint(graphics);
        end

        function Edit:OnKeyDown(inputs)
            -- if inputs[UI.key] then
                -- 
            -- end
        end

        Create(Edit,"Edit","Lable");
    end)();


    -- (function()
    --     local ListBox = {};

    --     function ListBox:constructor(id)
    --         self.super(id);
    --     end

    --     function ListBox:paint(graphics)

    --     end

    --     Create(ListBox,"ListBox","Component");
    -- end)();

    (function()
        local Plane = {};

        function Plane:constructor(id)
            self.super(id);
        end

        function Plane:paint(graphics)

        end

        Create(Plane,"Plane","Component");
    end)();


    Frame = New("Frame");
    Frame:add(
        New("Lable",1,"qwq")
    );

    Component1 = Frame:findById(1);
    Component1.style.top = 40;
    Component1.style.width = 100;
    Component1.style.height = 8;

    Frame:reset();
    Frame:paint();

    Event["OnKeyDown"](123);
    Event["OnKeyUp"](123);

    Component1:setFocus(true);



    str1 = New("String","QWQ阿");

    str2 = New("String","QWQ");

    str1 = str1 + str2;

    for i = 1, str1.length, 2 do
        print(string.byte(str1:charAt(i)));
    end

    print(table.concat(str1.array));