Font = {};

-- (function()
--     local Input = {};
--     local inputs = {};
--     function Input:constructor()
--         local OnKeyDownEventId = 0;
--         local OnKeyUpEventId = 0;
--         local OnUpdateEventId = 0;
        
--             if  OnKeyDownEventId == 0 and OnKeyUpEventId == 0 and OnUpdateEventId == 0 then
--                 OnKeyDownEventId = Event:addEventListener(function(inputs)
--                     self:keyDown(inputs);
--                 end);
--                 OnKeyUpEventId = Event:addEventListener(function(inputs)
--                     self:keyUp(inputs);
--                 end);
--                 OnUpdateEventId = Event:addEventListener(function(time)
--                     self:Update(time);
--                 end);
--             end

--         function self:disable()
--             if  OnKeyDownEventId ~= 0 and OnKeyUpEventId ~= 0 and OnUpdateEventId ~= 0 then
--                 Event:detachEventListener(OnKeyDownEventId);
--                 Event:detachEventListener(OnKeyUpEventId);
--                 Event:detachEventListener(OnUpdateEventId);
--                 OnKeyDownEventId = 0;
--                 OnKeyUpEventId = 0;
--                 OnUpdateEventId = 0;
--             end
--         end
--     end

--     IKit.Class(Input,"Input");
-- end)();

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

    function Graphics:drawText(x,y,size,letterspacing,string,rect)
        for i=1,string.length do
            local char = string:charAt(i)
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
            border = {top = 0,left = 0,right = 0,bottom = 0},
            bordercolor = {red = 0,green = 0,blue=0,alpha=255},
        };
        self.onclick = function() end;
        self.onfouce = function() end;
        self.onblur = function() end;
        self.onkeydown = function() end;
        self.onkeyup = function() end;
        self.onupdate = function() end;
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

    function Container:moveNext()
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


    IKit.Class(Container,"Container",{extends = "Component"});
end)();

(function()
    local Windows = {};

    function Windows:constructor()
        self.super();
        self.graphics = IKit.New("Graphics");
        self.activecomponent = self;

        self.width = UI.ScreenSize().width;
        self.height = UI.ScreenSize().height;

        local OnKeyDownEventId = 0;
        local OnKeyUpEventId = 0;
        local OnUpdateId = 0;

        function self:onkeydown(inputs)
            if inputs[UI.KEY.MOUSE1] == true then
                if self.index ~= 0 then
                    self.activecomponent = self.children[self.index];
                end
            end
            if inputs[UI.KEY.MOUSE2] == true then
                if self.activecomponent.father ~= "nil" then
                    self.activecomponent = self.activecomponent.father;
                    return;
                end
            end
            if inputs[UI.KEY.UP] == true then
                print(self.index)
                self:moveNext();
                if self.activecomponent ~= self.children[self.index] then
                    self.activecomponent:onblur();
                    self.activecomponent = self.children[self.index];
                    self.activecomponent:onfouce();
                end
                return;
            end
            if inputs[UI.KEY.DOWN] == true then
                self:moveNext();
                if self.activecomponent ~= self.children[self.index] then
                    self.activecomponent:onblur();
                    self.activecomponent = self.children[self.index];
                    self.activecomponent:onfouce();
                end
                return;
            end
            if self.activecomponent.onkeydown ~= "nil" and self.activecomponent ~= self then
                self.activecomponent:onkeydown(inputs);
            end
        end

        function self:onkeyup(inputs)
            if self.activecomponent.onkeyup ~= "nil" and self.activecomponent ~= self then
                self.activecomponent:onkeyup(inputs);
            end
        end
        
        function self:onupdate(time)
            if self.activecomponent.onupdate ~= "nil" and self.activecomponent ~= self then
                self.activecomponent:onupdate(time);
            end
            self:reset();
            self:repaint();
        end

        function self:onclick()
            print("QWQ");
        end
        

        function self:enable()
            if OnKeyUpEventId ~= 0 or OnKeyDownEventId ~= 0 or OnUpdateId ~= 0  then
                error("当前窗口以存在监听事件不可重复添加");
            end
            OnKeyDownEventId = Event:addEventListener("OnKeyDown",function(inputs)
                self:onkeydown(inputs);
            end);
            OnKeyUpEventId = Event:addEventListener("OnKeyUp",function(inputs)
                self:onkeyup(inputs);
            end);
            OnUpdateId = Event:addEventListener("OnUpdate",function(time)
                self:onupdate(time);
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

    function Windows:select(name)

    end

    function Windows:setStyle(name,params)

    end

    function Windows:setFocus(component)
        if component.isenabled == false then
            error("'" .. component.type .. "'不可用");
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
        local components = components or self.children;
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
    local Lable = {};

    function Lable:constructor(text)
        self.super();
        self.text = IKit.New("String",text);
        self.style.fontsize = 2;
        self.style.letterspacing = 25;
        self.style.textalign = "center";
        self.overflow = "hidden";
        self.style.offsetx = 0;
        self.style.offsety = 0;
        self.style.fontcolor = {red = 0,green = 0,blue=0,alpha=255};
    end

    function Lable:setText(text)
        self.text = IKit.New("String",text);
    end

    function Lable:paint(graphics)
        self.super:paint(graphics);
        local rect = nil;
        if self.overflow == "hidden" then
            rect = {x = self.x,y = self.y,width = self.width,height = self.height};
        end
        graphics.color = self.style.fontcolor;
        local w,h = graphics:getTextSize(self.text,self.style.fontsize,self.style.letterspacing);
        if self.style.textalign == "center" then
            graphics:drawText(self.x + (self.width - w)/2 + self.style.offsetx ,self.y + (self.height - h) / 2 + self.style.offsety,self.style.fontsize,self.style.letterspacing,self.text,rect);
        elseif self.style.textalign == "left" then
            graphics:drawText(self.x + self.style.offsetx,self.y + (self.height - h) / 2 + self.style.offsety ,self.style.fontsize,self.style.letterspacing,self.text,rect);
        elseif self.style.textalign == "rigth" then
            graphics:drawText(self.x + (self.width - w) + self.style.offsetx ,self.y + (self.height - h) / 2 + self.style.offsety,self.style.fontsize,self.style.letterspacing,self.text,rect);
        end
    end

    IKit.Class(Lable,"Lable",{extends="Component"});
end)();

(function()
    local Edit = {};

    function Edit:constructor(text)
        self.super(text);
        --光标位置
        self.cursor = 0;
        --输入类型,可为 "all" "number" "english"
        self.intype="all";
        --最大输入长度
        self.maxlength = 10;

        self.keyprevious = UI.KEY.LEFT;
        self.keynext = UI.KEY.RIGHT;
        self.keybackspace = UI.KEY.SHIFT;
    end

    function Edit:paint(graphics)
        self.super:paint(graphics);
        local w,h = graphics:getTextSize(self.text,self.style.fontsize,self.style.letterspacing);
        local rect = nil;
        if self.overflow == "hidden" then
            rect = {x = self.x,y = self.y,width = self.width,height = self.height};
        end
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
    end

    function Edit:onkeydown(inputs)
        for key, value in pairs(inputs) do
            if value == true then
                if self.text.length < self.maxlength then
                    if self.intype == "all" or self.intype == "number" then
                        if key >=0 and key <= 8 then
                            self.text:insert(string.char(key+49),self.cursor+1);
                            self.cursor = self.cursor + 1;
                        end
                        if key == 9 then
                            self.text:insert('0',self.cursor);
                            self.cursor = self.cursor + 1;
                        end
                    end

                    if self.intype == "all" or self.intype == "english" then
                        if key >= 10 and key <= 35 then
                            self.text:insert(string.char(key+87),self.cursor+1);
                            self.cursor = self.cursor + 1;
                        end

                        if key == 37 then
                            self.text:insert(' ',self.cursor+1);
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
                    if self.cursor < self.text.length then
                        self.cursor = self.cursor + 1;
                    end
                end
                if key == self.keybackspace then
                    if self.cursor > 0 then
                        self.text:remove(self.cursor);
                        self.cursor = self.cursor - 1;
                    end
                end
            end
        end
    end

    function Edit:getText()
        return self.text;
    end

    IKit.Class(Edit,"Edit",{extends="Lable"});
end)();