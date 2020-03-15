Font = {};

(function ()
    local Graphics = {};

    function Graphics:constructor()
        self.root = {};
        self.color = {red = 255,green = 255,blue=255,alpha=255};
        self.opacity = 1;
    end

    function Graphics:drawRect(x,y,width,height,rect)
        local box = UI.Box.Create();
        if box == nil then
            error("无法绘制矩形:已超过最大限制");
        end

        if rect~=nil then
            if x > rect.x + rect.width then
                return;
            end
            if y > rect.y + rect.height then
                return;
            end
            if x + width < rect.x or y + height < rect.y then
                return;
            end
            if x < rect.x then
                 x = rect.x;
            end
            if y < rect.y then
                 y = rect.y;
            end
            if x + width > rect.x + rect.width then
                width = rect.x + rect.width - x;
            end
            if y + height > rect.y + rect.height then
                height = rect.y + rect.height - y;
            end
            box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha * self.opacity});
        else
            box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha * self.opacity});
        end
        box:Show();
        self.root[#self.root+1] = box;
    end;

    function Graphics:drawText(x,y,size,letterspacing,text,rect)
        for i=1,text.length do
            local char = text:charAt(i)
            if Font[char] == nil then
                char = '?';
            end
            for j = 1,#Font[char],4 do
                local x1 = Font[char][j];
                local y1 = Font[char][j+1];
                local x2 = Font[char][j+2];
                local y2 = Font[char][j+3];
                if i == 1 then
                    self:drawRect(x + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                else
                    self:drawRect(x + (i-1) * letterspacing + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                end
            end
        end
    end

    function Graphics:getTextSize(text,fontsize,letterspacing)
        if IKit.TypeOf(text) == "string" then
            text = IKit.New("String",text);
        end
        if text.length == 0 then
            return 0,12 * fontsize;
        end
        local width = (text.length - 1) * letterspacing + 11 * fontsize;
        local height = 12 * fontsize;
        return width,height;
    end

    function Graphics:clean()
        for i = 1, #self.root, 1 do
            self.root[i] = nil;
        end
        self.root = {};
        collectgarbage("collect");
    end

    IKit.Class(Graphics,"Graphics");
end)();

(function()
    local Component = {};

    function Component:constructor()
        self.id = "nil";
        self.tag = "nil";
        self.father = "nil";
        self.isvisible = true;
        self.isenabled = true;
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
            isvisible = true;
            position = "relative",
            backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
            border = {top = 1,left = 1,right = 1,bottom = 1},
            bordercolor = {red = 0,green = 0,blue=0,alpha=255},
        };
        self.onclick = function() end;
        self.onfouce = function() end;
        self.onblur = function() end;
        self.onkeydown = function() end;
        self.onkeyup = function() end;
        self.onupdate = function() end;

    end

    function Component:onClick()
        self:onclick();
    end

    function Component:onFouce()
        self:onfouce();
    end

    function Component:onBlur()
        self:onblur();
    end
    
    function Component:onKeyDown()
        self:onkeydown();
    end

    function Component:onKeyUp()
        self:onkeyup();
    end

    function Component:onUpdate()
        self:onupdate();
    end
    
    function Component:getRect()
        return {x = self.x,y = self.y,width = self.width,height = self.height};
    end

    function Component:getUnitAndNumber(value)
        if type(value) == "number" then
            return "px",value;
        elseif type(value) == "string" then
            if string.find(value,"px") ~= nil then
                return "px",tonumber(string.sub(value,1,#value - 2));
            elseif string.find(value,"%%")  ~= nil then
                return "%",tonumber(string.sub(value,1,#value - 1));
            end
        end
        return "unkonw",0;
    end

    function Component:paint(graphics)
        graphics.color = self.style.backgroundcolor;
        graphics.opacity = self.style.opacity;
        graphics:drawRect(self.x,self.y,self.width,self.height);

        graphics.color = self.style.bordercolor;
        if self.style.border.top > 0 then
            graphics:drawRect(self.x,self.y,self.width,self.style.border.top);
        end
        if self.style.border.right > 0 then
            graphics:drawRect(self.x + self.width - self.style.border.right,self.y,self.style.border.right,self.height);
        end
        if self.style.border.bottom > 0 then
            graphics:drawRect(self.x,self.y + self.height - self.style.border.bottom,self.width,self.style.border.bottom);
        end
        if self.style.border.left > 0 then
            graphics:drawRect(self.x,self.y,self.style.border.left,self.height);
        end
    end

    function Component:set(params)
        if params == nil then
            return;
        end
        local object;
        local key = IKit.New("String");
        for i = 1, #params, 2 do
            object = self;
            key:clean();
            for j = 1, #params[i], 1 do
                if string.sub(params[i],j,j) == '.' then
                    object = object[key:toString()];
                    key:clean();
                else
                    key:insert(string.sub(params[i],j,j));
                end
            end
            object[key:toString()] = params[i+1];
        end
    end

    IKit.Class(Component,"Component");
end)();

(function()
    local Container = {};

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

    function Container:moveToNext()
        if #self.children > 0 then
            local i = self.index + 1;
            while i ~= self.index do
                if i > #self.children then
                    i = 1;
                else
                    if self.children[i].isenabled == true and self.children[i].isvisible == true then
                        self.index = i;
                        break;
                    end
                    i = i + 1;
                end
            end
        end
    end

    function Container:moveToPrevious()
        if #self.children > 0 then
            local i = self.index - 1;
            while i ~= self.index do
                if i < 1 then
                    i = #self.children;
                else
                    if self.children[i].isenabled == true and self.children[i].isvisible == true then
                        self.index = i;
                        break;
                    end
                    i = i - 1;
                end
            end
        end
    end

    IKit.Class(Container,"Container",{extends = "Component"});
end)();

(function()
    local Windows = {};

    function Windows:constructor()
        self.super();

        self.graphics = IKit.New("Graphics");
        self.activecomponent = self;

        self.width,self.height = UI.ScreenSize().width,UI.ScreenSize().height;
        self.style.backgroundcolor = {red = 255,green = 255,blue=255,alpha=0};

        local OnKeyDownEventId = 0;
        local OnKeyUpEventId = 0;
        local OnUpdateId = 0;

        function self:enable()
            if OnKeyUpEventId ~= 0 or OnKeyDownEventId ~= 0 or OnUpdateId ~= 0  then
                error("当前窗口以存在监听事件不可重复添加");
            end
            OnKeyDownEventId = Event:addEventListener("OnKeyDown",function(inputs)
                self:onKeyDown(inputs);
            end);
            OnKeyUpEventId = Event:addEventListener("OnKeyUp",function(inputs)
                self:onKeyUp(inputs);
            end);
            OnUpdateId = Event:addEventListener("OnUpdate",function(time)
                self:onUpdate(time);
            end);
            self.isenabled = true;
        end

        function self:disable()
            if OnKeyUpEventId == 0 or OnKeyDownEventId == 0 or OnUpdateId == 0 then
                error("当前窗口以存在监听事件");
            end
            Event:detachEventListener("OnKeyDown",OnKeyDownEventId);
            Event:detachEventListener("OnKeyUp",OnKeyUpEventId);
            Event:detachEventListener("OnUpdate",OnUpdateId);
            OnKeyUpEventId = 0;
            OnKeyDownEventId = 0;
            OnUpdateId = 0;
            self.isenabled = false;
        end
    end

    function Windows:onKeyDown(inputs)
        self.super:onKeyDown(inputs);
        if inputs[UI.KEY.MOUSE1] == true then
            if self.index ~= 0 then
                self.activecomponent = self.children[self.index];
                self.children[self.index]:onclick();
            end
        end
        if inputs[UI.KEY.MOUSE2] == true then
            if self.activecomponent.father ~= "nil" then
                self.activecomponent = self.activecomponent.father;
                return;
            end
        end
        if inputs[UI.KEY.UP] == true then
            self:moveToPrevious();
            if self.activecomponent ~= self.children[self.index] then
                self.activecomponent:onBlur();
                self.activecomponent = self.children[self.index];
                self.activecomponent:onFouce();
            end
            return;
        end
        if inputs[UI.KEY.DOWN] == true then
            self:moveToNext();
            if self.activecomponent ~= self.children[self.index] then
                self.activecomponent:onBlur();
                self.activecomponent = self.children[self.index];
                self.activecomponent:onFouce();
            end
            return;
        end
        if self.activecomponent ~= self then
            self.activecomponent:onKeyDown(inputs);
        end
    end

    function Windows:onKeyUp(inputs)
        self.super:onKeyUp(inputs);
        if self.activecomponent ~= self then
            self.activecomponent:onKeyUp(inputs);
        end
    end
    
    function Windows:onUpdate(time)
        self.super:onUpdate(time);
        self:reset();
        self:repaint();
    end

    function Windows:onClick()
        self.super:onClick();
        if self.activecomponent ~= self then
            self.activecomponent:onClick();
        end
    end

    -- function Windows:selectByTag()

    -- end

    -- function Windows:selectById()

    -- end

    -- function Windows:selectAll(...)

    -- end

    function Windows:select(...)
         for key, value in pairs({...}) do
             
         end
    end

    function Windows:setStyle(name,params)

    end

    function Windows:setFocus(component)
        if component.isenabled == false then
            print("'" .. component.type .. "'不可用");
            return;
        end
        if self.activecomponent ~= "nil" then
            self.activecomponent:onBlur();
        end
        self.activecomponent = component;
        self.activecomponent:onFocus();
    end
    
    function Windows:paint()
        self.super:paint(self.graphics);
    end

    function Windows:reset(components)
        if components == nil then
            self:reset(self.children);
            return;
        end
        for i = 1, #components, 1 do
            if components[i].style.position == "relative" then
                local unit,left = self:getUnitAndNumber(components[i].style.left);
                if unit == "%" then
                    left = components[i].father.width * (left /100);
                end
                local unit,top = self:getUnitAndNumber(components[i].style.top);
                if unit == "%" then
                    top = components[i].father.height * (top /100);
                end
                local unit,width = self:getUnitAndNumber(components[i].style.width);
                if unit == "%" then
                    width =components[i].father.width * (width /100);
                end
                local unit,height = self:getUnitAndNumber(components[i].style.height);
                if unit == "%" then
                    height =components[i].father.height * (height /100);
                end
                components[i].width = width;
                components[i].height = height;
                if i == 1 then
                    components[i].x = components[i].father.x + left;
                    components[i].y = components[i].father.y + top;
                else
                    if components[i].style.newline == true then
                        local temp;
                        for j = i - 1, 1 , -1 do
                            temp = components[j];
                            if temp.style.newline == true then
                                components[i].x = components[i].father.x + left;
                                components[i].y = temp.y + temp.height + top;
                                break;
                            end
                            if j == 1 then
                                components[i].x = components[i].father.x + left;
                                components[i].y = components[i].father.children[1].y + components[i].father.children[1].height + top;
                            end
                        end
                    else
                        components[i].x = components[i - 1].x + components[i - 1].width + left;
                        components[i].y = components[i - 1].y;
                    end
                end
            elseif components[i].style.position == "absolute" then
                    local unit,left = self:getUnitAndNumber(components[i].style.left);
                    if unit == "%" then
                        left = self.width * (left /100);
                    end
                    local unit,top = self:getUnitAndNumber(components[i].style.top);
                    if unit == "%" then
                        top = self.height * (top /100);
                    end
                    local unit,width = self:getUnitAndNumber(components[i].style.width);
                    if unit == "%" then
                        width = self.width * (width /100);
                    end
                    local unit,height = self:getUnitAndNumber(components[i].style.height);
                    if unit == "%" then
                        height = self.height * (height /100);
                    end
                    components[i].x = self.x + left;
                    components[i].y = self.y + top;
                    components[i].width = width;
                    components[i].height = height;
            end
        end
        for i = 1, #components,1 do
            if components[i].children ~= nil then
                self:reset(components[i].children);
            end
        end
    end

    function Windows:repaint(component)
        local component = component or self;
        if component == self then
            self.graphics:clean();
        end
        component:paint(self.graphics);
        if component.children ~= nil then
            for i = 1,#component.children,1 do
                self:repaint(component.children[i]);
            end
        end
    end

    IKit.Class(Windows,"Windows",{extends = "Container"});
end)();

(function()
    local Div = {};

    function Div:constructor()
        self.super();
    end

    IKit.Class(Div,"Div",{extends = "Container"});
end)();

(function()
    local TextView = {};

    function TextView:constructor()
        self.super();
        self.text = "";
        self.style.fontsize = 2;
        self.style.letterspacing = 25;
        self.style.textalign = "center";
        self.style.overflow = "hidden";
        self.style.singleline = true;
        self.style.offsetx = 0;
        self.style.offsety = 0;
        self.style.textcolor = {red = 0,green = 0,blue=0,alpha=255};
    end

    function TextView:setText(text)
        self.text = text;
    end

    function TextView:paint(graphics)
        self.super:paint(graphics);
        local text = IKit.New("String",self.text);
        local rect = nil;
        if self.style.overflow == "hidden" then
            rect = {x = self.x,y = self.y,width = self.width,height = self.height};
        end
        graphics.color = self.style.textcolor;
        if self.style.singleline == false then
            local w,h = graphics:getTextSize(text,self.style.fontsize,self.style.letterspacing);
            if self.style.textalign == "center" then
                graphics:drawText(self.x + (self.width - w)/2 + self.style.offsetx ,self.y + (self.height - h) / 2 + self.style.offsety,self.style.fontsize,self.style.letterspacing,text,rect);
            elseif self.style.textalign == "left" then
                graphics:drawText(self.x + self.style.offsetx,self.y + (self.height - h) / 2 + self.style.offsety ,self.style.fontsize,self.style.letterspacing,text,rect);
            elseif self.style.textalign == "rigth" then
                graphics:drawText(self.x + (self.width - w) + self.style.offsetx ,self.y + (self.height - h) / 2 + self.style.offsety,self.style.fontsize,self.style.letterspacing,text,rect);
            end
        else
            local array = {};
            local i = 1;
            while i <= text.length do
                local t = IKit.New("String");
                local w,h = graphics:getTextSize(t,self.style.fontsize,self.style.letterspacing);
                if w > self.width - 11 * self.style.fontsize then
                    t:insert(text:charAt(i));
                    i = i + 1;
                else
                    while w < self.width - 11 * self.style.fontsize and i <= text.length do
                        t:insert(text:charAt(i));
                        w,h = graphics:getTextSize(t,self.style.fontsize,self.style.letterspacing);
                        i = i + 1;
                    end
                end
                array[#array+1] = t;
            end
            for i = 1, #array, 1 do
                local w,h = graphics:getTextSize(array[i],self.style.fontsize,self.style.letterspacing);
                graphics:drawText(self.x + self.style.offsetx,self.y + self.style.offsety + (i - 1) * h ,self.style.fontsize,self.style.letterspacing,array[i],rect);
            end
        end
    end

    IKit.Class(TextView,"TextView",{extends="Component"});
end)();

(function()
    local EditText = {};

    function EditText:constructor()
        self.super();

        self.numeric="integer";
        self.password="false"
        self.hint = "";


        self.keyprevious = UI.KEY.LEFT;
        self.keynext = UI.KEY.RIGHT;
        self.keybackspace = UI.KEY.SHIFT;
    end

    function EditText:paint(graphics)
        self.super:paint(graphics);
        local w,h = graphics:getTextSize(self.text,self.style.fontsize,self.style.letterspacing);
        local rect = nil;
        if self.overflow == "hidden" then
            rect = {x = self.x,y = self.y,width = self.width,height = self.height};
        end
        if self.style.singleline == false then
            if self.style.textalign == "center" then
                graphics:drawRect(self.x + (self.width - w)/2 + (self.cursor) * self.style.letterspacing - (self.style.letterspacing - self.style.fontsize * 11)/2 ,
                self.y + (self.height - h) / 2,
                self.style.fontsize / 2,
                self.style.fontsize * 12,rect);
            elseif self.style.textalign == "left" then
                graphics:drawRect(self.x + (self.cursor) * self.style.letterspacing - (self.style.letterspacing - self.style.fontsize * 11)/2 ,
                self.y + (self.height - h) / 2,
                self.style.fontsize / 2,
                self.style.fontsize * 12,rect);
            elseif self.style.textalign == "rigth" then
                graphics:drawRect(self.x + (self.cursor) * self.style.letterspacing + (self.width - w) - (self.style.letterspacing - self.style.fontsize * 11)/2 ,
                self.y + (self.height - h) / 2,
                self.style.fontsize / 2,
                self.style.fontsize * 12,rect);
            end
        else
            -- graphics:drawRect(self.x + (self.cursor) * self.style.letterspacing + (self.width - w) - (self.style.letterspacing - self.style.fontsize * 11)/2 ,
            --     self.y + (self.height - h) / 2,
            --     self.style.fontsize / 2,
            --     self.style.fontsize * 12,rect);
        end
    end

    IKit.Class(EditText,"EditText",{extends="TextView"});
end)();


(function()
    local Br = {};
    
    function Br:constructor()
        self.super();

        self.style.newline = true;
        self.isenabled = false;
    end

    IKit.Class(Br,"Br",{extends="Component"});
end)();

function Windows(arg1,...)
    local windows = IKit.New("Windows");
    windows:set(arg1);
    windows:add(...);
    return windows;
end

function Div(arg1,...)
    local div = IKit.New("Div");
    div:set(arg1);
    div:add(...);
    return div;
end

function Component(arg1)
    local component = IKit.New("Component");
    component:set(arg1);
    return component;
end

function TextView(arg1)
    local textview = IKit.New("TextView");
    textview:set(arg1);
    return textview;
end

function EditText(arg1)
    local edittext = IKit.New("EditText");
    edittext:set(arg1);
    return edittext;
end

function Br(arg1)
    local br = IKit.New("Br");
    br:set(arg1);
    return br;
end