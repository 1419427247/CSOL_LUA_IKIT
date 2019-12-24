Font = {};

(function ()
    local Graphics = {};
    function Graphics:constructor()
        self.root = {};
        self.color = {red = 255,green = 255,blue=255,alpha=255};
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
            box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha});
        else
            box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha});
        end
        box:Show();
        table.insert(self.root,box);
    end;

    --在屏幕上绘制文字
    function Graphics:drawText(x,y,size,letterSpacing,string,rect)
        for i=1,string.length do
            local char = string:charAt(i)
            if(Font[char] ~= nil) then
                local j=1;
                while j < #Font[char] do
                    local x1 = Font[char][j];
                    local y1 = Font[char][j+1];
                    local x2 = Font[char][j+2];
                    local y2 = Font[char][j+3];
                    -- local box = UI.Box.Create();
                    -- if box == nil then
                    --     error("无法绘制文字:已超过最大限制");
                    -- end
                    if i == 1 then
                        self:drawRect(x + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                    else
                        self:drawRect(x + (i-1) * letterSpacing + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                    end
                    -- if i == 1 then
                    --     box:Set({x =x + x1*size, y = y + (12 - y2)*size, width = (x2 - x1)*size, height = (y2 - y1)*size, r = self.color.red, g = self.color.green, b = self.color.blue, a = self.color.alpha})
                    -- else
                    --     box:Set({x =x + (i-1) * letterSpacing + x1*size, y = y + (12 - y2)*size, width = (x2 - x1)*size, height = (y2 - y1)*size, r = self.color.red, g = self.color.green, b = self.color.blue, a = self.color.alpha})
                    -- end
                    -- box:Show();
                    -- table.insert(self.root,box);
                    j = j + 4;
                end
            end
        end
    end

    --获取文字的宽高
    function Graphics:getTextSize(text,fontsize,letterspacing)
        local width = (text.length - 1) * letterspacing + 11 * fontsize;
        local height = 12 * fontsize;
        return width,height;
    end

    --清楚屏幕上绘制的一切
    function Graphics:clean()
        for i = 1, #self.root, 1 do
            self.root[i] = nil;
        end
        self.root = {};
        collectgarbage("collect");
    end

    IKit.Create(Graphics,"Graphics");
end)();

-- (function()
--     local ComponentBox = {};

--     function ComponentBox:constructor()
--         self.components = {};
--     end

--     function ComponentBox:set(key,value)
--         for i = 1, #self.components, 1 do
--             self.components[i][key] = value;
--         end
--     end
    
--     function ComponentBox:get(tag)
--         local array = {};
--         for i = 1, #self.components, 1 do
--             if self.components[i] == tag then
--                 array[#array+1] = self.components[i];
--             end
--         end
--         return array;
--     end

--     function ComponentBox:call(key,...)
--         for i = 1, #self.components, 1 do
--             self.components[i][key](self.components[i],...);
--         end
--     end

--     function ComponentBox:forEach(func)
--         for i = 1, #self.components, 1 do
--             func(self.components[i]);
--         end
--     end

--     IKit.Create(ComponentBox,"ComponentBox");
-- end)();

(function()
    local Frame = {};
    function Frame:constructor(width,height)
        --设置当前窗口的x轴位置
        self.x=0;
        --设置当前窗口的y轴位置
        self.y=0;
        --设置当前窗口的宽度,默认为屏幕的宽度
        self.width = width or UI.ScreenSize().width;
        --设置当前窗口的宽度,默认为屏幕的高度
        self.height = height or UI.ScreenSize().height;
        self.graphics = IKit.New("Graphics");
        self.animation = 0;
        self.children = {};
        --当前得到焦点的物体，默认为空
        self.focused = 0;

        local OnKeyDownEventId = 0;
        local OnKeyUpEventId = 0;
        local OnUpdateId = 0;

        --为当前Frame注册鼠标键盘监听事件
        function self:enable()
            if OnKeyUpEventId ~= 0 or OnKeyDownEventId ~= 0 then
                error("当前窗口以存在监听事件不可重复添加");
            end
            OnKeyDownEventId = Event:addEventListener("OnKeyDown",function(inputs)
                self:onKeyDown(inputs);
            end);
            OnKeyUpEventId = Event:addEventListener("OnKeyUp",function(inputs)
                self:onKeyUp(inputs);
            end);
            OnUpdateId = Event:addEventListener("OnUpdate",function(time)
                self:OnUpdate(time);
            end);
        end

        --移除当前Frame注册的鼠标键盘监听事件
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
        end
    end

    --添加一个或多个组件
    function Frame:add(...)
        local components = {...};
        for i = 1, #components, 1 do
            components[i].father = self;
            table.insert(self.children,components[i]);
        end
        return self;
    end

    --将焦点指向component并触发相应事件
    function Frame:setFocus(component)
        if self.focused ~= 0 then
            self.focused:onBlur();
        end
        self.focused = component;
        self.focused:onFocus();
    end

    --前序遍历所有子组件
    function Frame:forEach(func)
        local function forEach(component)
            if func(component) == false then
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

    --计算子组件的位置,若components为nil则重新计算所有组建的位置
    function Frame:reset(components)
        local components = components or self.children;
            for i = 1, #components, 1 do
                if components[i].style.position == "relative" then
                    components[i].width = components[i].father.width * (components[i].style.width /100);
                    components[i].height = components[i].father.height * (components[i].style.height /100);
                    if i == 1 then
                        components[i].x = components[i].father.x + components[i].father.width * (components[i].style.left /100);
                        components[i].y = components[i].father.y + components[i].father.height * (components[i].style.top /100);
                    else
                        if components[i].style.newline == true then
                            local temp;
                            for j = i - 1, 1 , -1 do
                                temp = components[j];
                                if temp.style.newline == true then
                                    components[i].x = components[i].father.x + components[i].father.width * (components[i].style.left /100);
                                    components[i].y = temp.y + temp.height + components[i].father.height * (components[i].style.top /100);
                                    break;
                                end
                                if j == 1 then
                                    components[i].x = components[i].father.x + components[i].father.width * (components[i].style.left /100);
                                    components[i].y = components[i].father.children[1].y + components[i].father.children[1].height + components[i].father.height * (components[i].style.top /100);
                                end
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
            end

            for i = 1, #components,1 do
                self:reset(components[i].children);
            end
    end

    -- function Frame:freeze(component)
        
    -- end

    --重绘当前frame
    function Frame:repaint()
        self.graphics:clean();
        self:forEach(function(component)
            if component.isvisible == true then
                component:paint(self.graphics);
            end
        end);
    end

    --通过标签查找子组件,若未查到相同tag的组件返回nil,查询到一个返回该组件，若查询到多个组件则返回包含多个组件的数组
    function Frame:findByTag(tag)
        local components = {};
        self:forEach(function(component)
            if tag == component.tag then
                components[#components+1] = component;
            end
        end);
        if #components == 0 then
            return nil;
        elseif #components == 1 then
            return components[1];
        else
            return components;
        end
    end

    --设置动画,对性能有较大影响Frame:animate{"x",5,"style.backgroundcolor.r",125},nil,Button);
    function Frame:animate(params,timeslice,callback,component)
        local style = {};
        local object;
        local key = IKit.New("String");
        for i = 1, #params, 2 do
            object = component;
            key:clean();

            for j = 1, #params[i], 1 do
                if string.sub(params[i],j,j) == '.' then
                    object = object[key:toString()];
                    key:clean();
                else
                    key:insert(string.sub(params[i],j,j));
                end
            end
            table.insert(style,{
                object,
                key:toString(),
                params[i+1],
                (params[i+1] - object[key:toString()])/ timeslice
            });
        end
        component.animation = function()
            if timeslice == 0 then
                for i = 1, #style, 1 do
                    style[i][1][style[i][2]] = style[i][3];
                end
                if callback ~= nil then
                    callback();
                end
                return false;
            end
            for i = 1, #style, 1 do
                style[i][1][style[i][2]] = style[i][1][style[i][2]] + style[i][4];
            end
            timeslice = timeslice - 1;
            return true;
        end
        self.animation = self.animation + 1;
    end

    function Frame:getRectSize()
        return #self.graphics.root;
    end
    --隐藏并移除当前frame的事件监听
    function Frame:hide()
        self:disable();
        self.graphics:clean();
    end

    --显示并重新添加当前frame的事件监听
    function Frame:show()
        self:enable();
        self:reset();
        self:repaint();
    end

    function Frame:onKeyDown(inputs)
        if self.focused ~= 0 then
            self.focused:onKeyDown(inputs)
        end
    end

    function Frame:onKeyUp(inputs)
        if self.focused ~= 0 then
            self.focused:onKeyUp(inputs)
        end
    end

    function Frame:OnUpdate(time)
        if self.animation > 0 then
            local function forEach(component)
                if component.animation ~= 0 then
                    if component.animation() == false then
                        component.animation = 0;
                        self.animation = self.animation - 1;
                    end
                end
                for i = 1, #component.children, 1 do
                    forEach(component.children[i]);
                end
            end
            for i = 1, #self.children, 1 do
                forEach(self.children[i]);
            end

            self:reset();
            self:repaint();
        end
    end
    IKit.Create(Frame,"Frame");
end)();

(function()
    local Component = {};
    function Component:constructor(tag,left,top,width,heigth)
        --组件的标签,用于查找特定组件
        self.tag = tag;
        --是否渲染当前组件(不包括子组件)
        self.isvisible = true;
        self.animation = 0;
        --组件是否可被选中
        --self.isfreeze = false;
        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
        self.style = {
            left = left or 0,
            top = top or 0,
            width = width or 0,
            height = heigth or 0,
            --设置组建的定位方式,可为 "relative" "absolute"
            position = "relative",
            --背景颜色
            backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
            --边框
            border = {top = 0,left = 0,right = 0,bottom = 0},
            --边框颜色
            bordercolor = {red = 0,green = 0,blue=0,alpha=255},
            --是否换行
            newline = false,
        };
        self.father = 0;
        self.children = {};
    end

    --没有用的东西
    -- function Component:getIndex()
    --     for i = 1, #self.father.children, 1 do
    --         if self.father.children[i] == self then
    --             return i;
    --         end
    --     end
    -- end

    function Component:paint(graphics)
        graphics.color = self.style.backgroundcolor;
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

    function Component:onFocus()
        -- self.style.backgroundcolor.red = self.style.backgroundcolor.red - 20;
        -- self.style.backgroundcolor.green = self.style.backgroundcolor.green - 20;
        -- self.style.backgroundcolor.blue = self.style.backgroundcolor.blue - 20;
        self:animate({"style.backgroundcolor.red",222,
                      "style.backgroundcolor.green",222,
                      "style.backgroundcolor.blue",222,
                    },10,nil,self);
        self:repaint();
    end

    function Component:onBlur()
        -- self.style.backgroundcolor.red = self.style.backgroundcolor.red + 20;
        -- self.style.backgroundcolor.green = self.style.backgroundcolor.green + 20;
        -- self.style.backgroundcolor.blue = self.style.backgroundcolor.blue + 20;
        self:animate({"style.backgroundcolor.red",255,
                      "style.backgroundcolor.green",255,
                      "style.backgroundcolor.blue",255
                    },10,nil,self);
        self:repaint();
    end


    function Component:onKeyDown(inputs)

    end

    function Component:onKeyUp(inputs)

    end

    function Component:animate(params,timeslice,callback,component)
        component = component or self;
        self.father:animate(params,timeslice,callback,component);
    end

    function Component:setFocus(component)
        self.father:setFocus(component);
    end

    function Component:repaint()
        self.father:repaint();
    end

    IKit.Create(Component,"Component");
end)();

(function()
    local Plane = {};

    function Plane:constructor(tag,left,top,width,heigth)
        self.super(tag,left,top,width,heigth);
        self.index = 1;
    end

    function Plane:add(...)
        local components = {...};
        for i = 1, #components, 1 do
            components[i].father = self;
            table.insert(self.children,components[i]);
        end
        return self;
    end

    function Plane:onFocus()
        if #self.children > 0 then
            self.children[self.index]:onFocus();
        end
        self.style.border.left = self.style.border.left + 3;
        self.style.border.right = self.style.border.right + 3;
        self.style.border.top = self.style.border.top + 3;
        self.style.border.bottom = self.style.border.bottom + 3;
        self:repaint();
    end

    function Plane:onBlur()
        if #self.children > 0 then
            self.children[self.index]:onBlur();
        end
        self.style.border.left = self.style.border.left - 3;
        self.style.border.right = self.style.border.right - 3;
        self.style.border.top = self.style.border.top - 3;
        self.style.border.bottom = self.style.border.bottom - 3;
        self:repaint();
    end

    function Plane:onKeyDown(inputs)
        if inputs[UI.KEY.UP] == true then
            if #self.children > 0 then
                self.children[self.index]:onBlur();
                if self.index == 1 then
                    self.index = #self.children;
                else
                    self.index = self.index - 1;
                end
                self.children[self.index]:onFocus();
            end
        end
        if inputs[UI.KEY.DOWN] == true then
            if #self.children > 0 then
                self.children[self.index]:onBlur();
                if self.index == #self.children then
                    self.index = 1;
                else
                    self.index = self.index + 1;
                end
                self.children[self.index]:onFocus();
            end
        end
        if inputs[UI.KEY.MOUSE1] == true then
            if #self.children > 0 then
                if self.children[self.index].type == "Plane" then
                    self:setFocus(self.children[self.index]);
                end
            end
        end
        if inputs[UI.KEY.MOUSE2] == true then
            if self.father.type == "Plane" then
                self:setFocus(self.father);
                return;
            end
        end
        if #self.children > 0 then
            if self.children[self.index].type~="Plane" then
                self.children[self.index]:onKeyDown(inputs);
            end
        end
    end

    function Plane:onKeyUp(inputs)
        if #self.children > 0 then
            if self.children[self.index].type~="Plane" then
                self.children[self.index]:onKeyUp(inputs);
            end
        end
    end

    function Plane:paint(graphics)
        self.super:paint(graphics);
    end

    IKit.Create(Plane,"Plane","Component");
end)();


(function()
    local Lable = {};

    function Lable:constructor(tag,left,top,width,heigth,text)
        self.super(tag,left,top,width,heigth);
        --要显示的文本
        self.text = IKit.New("String",text);
        --文字大小
        self.style.fontsize = 2;
        --文字间距
        self.style.letterspacing = 25;
        --文本对齐方式,可为 "center","left","rigth"
        self.style.textalign = "center";
        --对超出区域的文本的操作 可为 "hiddne" "none"
        self.overflow = "hidden";
        --文本x轴偏移量
        self.style.offsetx = 0;
        --文本y轴偏移量
        self.style.offsety = 0;
        --文本颜色
        self.style.color = {red = 0,green = 0,blue=0,alpha=255};
    end

    function Lable:paint(graphics)
        self.super:paint(graphics);
        local rect = nil;
        if self.overflow == "hidden" then
            rect = {x = self.x,y = self.y,width = self.width,height = self.height};
        end
        graphics.color = self.style.color;
        local w,h = graphics:getTextSize(self.text,self.style.fontsize,self.style.letterspacing);
        if self.style.textalign == "center" then
            graphics:drawText(self.x + (self.width - w)/2 + self.style.offsetx ,self.y + (self.height - h) / 2 + self.style.offsety,self.style.fontsize,self.style.letterspacing,self.text,rect);
        elseif self.style.textalign == "left" then
            graphics:drawText(self.x + self.style.offsetx,self.y + (self.height - h) / 2 + self.style.offsety ,self.style.fontsize,self.style.letterspacing,self.text,rect);
        elseif self.style.textalign == "rigth" then
            graphics:drawText(self.x + (self.width - w) + self.style.offsetx ,self.y + (self.height - h) / 2 + self.style.offsety,self.style.fontsize,self.style.letterspacing,self.text,rect);
        end
    end

    IKit.Create(Lable,"Lable","Component");
end)();

(function()
    local Edit = {};

    function Edit:constructor(tag,left,top,width,heigth,text)
        self.super(tag,left,top,width,heigth,text);
        --光标位置
        self.cursor = 0;
        --输入类型,可为 "all" "number" "english"
        self.intype="all";
        --最大输入长度
        self.maxlength = 10;
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

    function Edit:onKeyDown(inputs)
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
                if key == 41 then
                    if self.cursor > 0 then
                        self.cursor = self.cursor - 1;
                    end
                end
                if key == 42 then
                    if self.cursor < self.text.length then
                        self.cursor = self.cursor + 1;
                    end
                end
                if key == 36 then
                    if self.cursor > 0 then
                        self.text:remove(self.cursor);
                        self.cursor = self.cursor - 1;
                    end
                end
            end
        end
        self:repaint();
    end

    function Edit:getText()
        return self.text;
    end

    IKit.Create(Edit,"Edit","Lable");
end)();

(function()
    local Button = {};

    function Button:constructor(tag,left,top,width,heigth,text)
        self.super(tag,left,top,width,heigth,text);
    end

    function Button:paint(graphics)
        self.super:paint(graphics);
    end

    function Button:onKeyDown(inputs)
        if inputs[UI.KEY.MOUSE1] == true then
            self:onClick();
        end
    end

    function Button:onClick()

    end

    IKit.Create(Button,"Button","Lable");
end)();

(function()
    local SelectBox = {};
    
    function SelectBox:constructor(tag,left,top,width,heigth)
        self.super(tag,left,top,width,heigth);
        self.list = {};
    end
    
    function SelectBox:addItem()
        
    end
    
    function SelectBox:paint(graphics)
    
    end
    
    IKit.Create(SelectBox,"SelectBox","Plane");
end)();


(function()
    local MessageBox = {};
    
    function MessageBox:constructor(caption,text,callback)
        local messagebox = IKit.New("Frame");

        local plane = IKit.New("Plane",1,25,25,50,30);

        local caption = IKit.New("Lable",2,2,2,96,20,caption);
        caption.style.fontsize = 1.5;
        caption.style.textalign = "left"

        local text = IKit.New("Lable",3,2,0,96,50,text);
        text.style.newline = true;

        local mb_ok = IKit.New("Button",4,30,5,40,15,"确定");
        mb_ok.style.newline = true;

        function mb_ok:onClick()
            messagebox:hide();
            if callback ~= nil then
                callback();
            end
        end

        messagebox:add(
            plane:add(
                caption,
                text,
                mb_ok
            )
        );
        messagebox:setFocus(plane);
        messagebox:show();
    end
    IKit.Create(MessageBox,"MessageBox");
end)();