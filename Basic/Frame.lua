--GUI工具库,包含了基本框架组件,写的太烂了,实在抱歉QWQ
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

    --获取文字的像素宽高
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

    IKit.Class(Graphics,"Graphics");
end)();

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
        self.isvisible = false;
        self.isenable = false;
        self.graphics = IKit.New("Graphics");
        self.animation = {};
        self.children = {};
        --当前得到焦点的物体，默认为空
        self.focused = 0;

        self.isrepaint = false;

        local OnKeyDownEventId = 0;
        local OnKeyUpEventId = 0;
        local OnUpdateId = 0;

        --为当前Frame注册鼠标键盘监听事件
        function self:enable()
            if OnKeyUpEventId ~= 0 or OnKeyDownEventId ~= 0 or OnUpdateId ~= 0  then
                error("当前窗口以存在监听事件不可重复添加");
            end
            self.isenable = true;
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
            self.isenable = false;
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
            self.children[#self.children+1] = components[i];
        end
        return self;
    end

    --将焦点指向component并触发相应事件
    function Frame:setFocus(component)
        if component.isfreeze == true then
            error(component.type .. "组件已被冻结");
        end
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

    --计算子组件的位置,若components为nil则重新计算所有组件的位置


    --重绘当前frame
    function Frame:paint()
        self.graphics:clean();
        local function forEach(component)
            if component.isvisible == false then
                return;
            end
            component:paint(self.graphics);
            for i = 1, #component.children, 1 do
                forEach(component.children[i]);
            end
        end
        for i = 1, #self.children, 1 do
            forEach(self.children[i]);
        end
    end

    function Frame:repaint()
        self.isrepaint = true;
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

    --设置动画,对性能有一定影响
    --Frame:animate({"x",5,"style.backgroundcolor.r",125},100,nil,Component);
    --Component:animate({"x",5,"style.backgroundcolor.r",125},100);
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
            style[#style+1] = {
                object,
                key:toString(),
                params[i+1],
                (params[i+1] - object[key:toString()])/ timeslice
            };
        end
        component.animation = function()
            if timeslice == 0 then
                for i = 1, #style, 1 do
                    style[i][1][style[i][2]] = style[i][3];
                end
                return callback;
            end
            for i = 1, #style, 1 do
                style[i][1][style[i][2]] = style[i][1][style[i][2]] + style[i][4];
            end
            timeslice = timeslice - 1;
            return true;
        end
        --这样做并不好,可是它确实很香╭(╯^╰)╮
        for i = 1,#self.animation,1 do
            if component == self.animation[i] then
                self.animation[i] = component;
                return;
            end
        end
        self.animation[#self.animation+1] = component;
    end

    function Frame:getRectSize()
        return #self.graphics.root;
    end

    --隐藏并移除当前frame的事件监听
    function Frame:hide()
        self.isvisible = false;
        self:disable();
        self.graphics:clean();
    end

    --显示并重新添加当前frame的事件监听
    function Frame:show()
        self.isvisible = true;
        self:enable();
        self:repaint();
    end

    function Frame:onKeyDown(inputs)
        if self.focused ~= 0 and self.focused.isfreeze == false then
            self.focused:onKeyDown(inputs)
        end
    end

    function Frame:onKeyUp(inputs)
        if self.focused ~= 0 and self.focused.isfreeze == false then
            self.focused:onKeyUp(inputs)
        end
    end

    function Frame:OnUpdate(time)
        if #self.animation > 0 or self.isrepaint == true then
            for i = #self.animation,1,-1 do
                local res = self.animation[i].animation();
                if res == nil then
                    table.remove(self.animation,i);
                elseif res ~= true then
                    table.remove(self.animation,i);
                    res();
                end
            end
            self:reset();
            self:paint();
            if self.isrepaint == true then
                self.isrepaint = false;
            end
        end
    end
    IKit.Class(Frame,"Frame");
end)();

(function()
    local Component = {};
    function Component:constructor(tag,left,top,width,heigth)
        --组件的标签,用于查找特定组件
        self.tag = tag;
        --是否渲染当前组件以及子组件
        self.isvisible = true;
        self.animation = 0;
        --组件是否被冻结
        self.isfreeze = false;

        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
        self.style = {
            left = left or 0,
            top = top or 0,
            width = width or 0,
            height = heigth or 0,
            --设置组件的定位方式,可为 "relative" "absolute"
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

    --隐藏组件以及子组件,我感觉这样写好傻=￣ω￣=
    function Component:hide()
        self.isvisible = false;
        self.isfreeze = true;
        self.memory["posstyle"] = {self.style.top,self.style.left,self.style.width,self.style.height};
        self.style.top = 0;
        self.style.left = 0;
        self.style.width = 0;
        self.style.height = 0;
        self:repaint();
    end

    function Component:show()
        self.isvisible = true;
        self.isfreeze = false;
        self.style.top = self.memory["posstyle"][1];
        self.style.left = self.memory["posstyle"][2];
        self.style.width = self.memory["posstyle"][3];
        self.style.height = self.memory["posstyle"][4];
        self:repaint();
    end

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

    --我要gg了呜呜呜T_T
    function Component:onFocus()
        -- self.style.backgroundcolor.red = self.style.backgroundcolor.red - 20;
        -- self.style.backgroundcolor.green = self.style.backgroundcolor.green - 20;
        -- self.style.backgroundcolor.blue = self.style.backgroundcolor.blue - 20;
        self:animate({"style.backgroundcolor.red",222,
                      "style.backgroundcolor.green",222,
                      "style.backgroundcolor.blue",222,
                    },15,nil,self);
        self:repaint();
    end

    --失去焦点事件
    function Component:onBlur()
        -- self.style.backgroundcolor.red = self.style.backgroundcolor.red + 20;
        -- self.style.backgroundcolor.green = self.style.backgroundcolor.green + 20;
        -- self.style.backgroundcolor.blue = self.style.backgroundcolor.blue + 20;
        self:animate({"style.backgroundcolor.red",255,
                      "style.backgroundcolor.green",255,
                      "style.backgroundcolor.blue",255
                    },15,nil,self);
        self:repaint();
    end

    --键盘按下事件
    function Component:onKeyDown(inputs)

    end

    --键盘抬起事件
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

    IKit.Class(Component,"Component");
end)();

(function()
    local Plane = {};

    function Plane:constructor(tag,left,top,width,heigth)
        self.super(tag,left,top,width,heigth);
        self.components = {};
        self.index = 1;

        self.keyprevious = UI.KEY.UP;
        self.keynext = UI.KEY.DOWN;
    end

    function Plane:add(...)
        local components = {...};
        for i = 1, #components, 1 do
            components[i].father = self;
            self.children[#self.children+1] = components[i];
        end
        self:refresh();
        return self;
    end

    function Plane:refresh()
        self.components = {};
        for i = 1, #self.children, 1 do
            if self.children[i].isfreeze == false then
                self.components[#self.components+1] = self.children[i];
            end
        end
    end

    function Plane:onFocus()
        self:refresh();
        if #self.components > 0 then
            self.components[self.index]:onFocus();
        end
        self.style.border.left = self.style.border.left + 1;
        self.style.border.right = self.style.border.right + 1;
        self.style.border.top = self.style.border.top + 1;
        self.style.border.bottom = self.style.border.bottom + 1;
        self:repaint();
    end

    function Plane:onBlur()
        self:refresh();
        if #self.components > 0 then
            self.components[self.index]:onBlur();
        end
        self.style.border.left = self.style.border.left - 1;
        self.style.border.right = self.style.border.right - 1;
        self.style.border.top = self.style.border.top - 1;
        self.style.border.bottom = self.style.border.bottom - 1;
        self:repaint();
    end

    function Plane:onKeyDown(inputs)
        self:refresh();
        if inputs[self.keyprevious] == true then
            if #self.components > 0 then
                self.components[self.index]:onBlur();
                if self.index == 1 then
                    self.index = #self.components;
                else
                    self.index = self.index - 1;
                end
                self.components[self.index]:onFocus();
            end
        end
        if inputs[self.keynext] == true then
            if #self.components > 0 then
                self.components[self.index]:onBlur();
                if self.index == #self.components then
                    self.index = 1;
                else
                    self.index = self.index + 1;
                end
                self.components[self.index]:onFocus();
            end
        end
        if inputs[UI.KEY.MOUSE1] == true then
            if #self.components > 0 then
                if self.components[self.index].type == "Plane" then
                    self:setFocus(self.components[self.index]);
                end
            end
        end
        if inputs[UI.KEY.MOUSE2] == true then
            if self.father.type == "Plane" then
                self:setFocus(self.father);
                return;
            end
        end
        if #self.components > 0 then
            if self.components[self.index].type~="Plane" then
                self.components[self.index]:onKeyDown(inputs);
            end
        end
    end

    function Plane:onKeyUp(inputs)
        self:refresh();
        if #self.components > 0 then
            if self.components[self.index].type~="Plane" then
                self.components[self.index]:onKeyUp(inputs);
            end
        end
    end

    function Plane:paint(graphics)
        self.super:paint(graphics);
    end

    IKit.Class(Plane,"Plane",{extends="Component"});
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

    IKit.Class(Lable,"Lable",{extends="Component"});
end)();

(function()
    local Edit = {};

    function Edit:constructor(tag,left,top,width,heigth,text)
        self.super(tag,left,top,width,heigth,text);
        self.isfreeze = false;
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
        self:repaint();
    end

    function Edit:getText()
        return self.text;
    end

    IKit.Class(Edit,"Edit",{extends="Lable"});
end)();

(function()
    local Button = {};

    function Button:constructor(tag,left,top,width,heigth,text)
        self.super(tag,left,top,width,heigth,text);
        self.isfreeze = false;
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

    IKit.Class(Button,"Button",{extends="Lable"});
end)();

(function()
    local SelectBox = {};
    
    function SelectBox:constructor(tag,left,top,width,heigth,items)
        self.super(tag,left,top,width,heigth);
        self.isfreeze = false;
        self.items = items or {};
        self.index = 1;
        if #self.items > 0 then
            self.text:clean();
            self.text:insert("◀" .. self.items[self.index] .. "▶");
        end

        self.keyprevious = UI.KEY.LEFT;
        self.keynext = UI.KEY.RIGHT;
    end
    
    function SelectBox:addItem(item)
        self.items[#self.items+1] = item;
    end
    
    function SelectBox:paint(graphics)
        self.super:paint(graphics);
    end
    
    function SelectBox:onKeyDown(inputs)
        if #self.items > 0 then
            if inputs[self.keyprevious] == true then
                if self.index == 1 then
                    self.index = #self.items;
                else
                    self.index = self.index - 1;
                end
                self.onChange();
            elseif inputs[self.keynext] == true then
                if self.index == #self.items then
                    self.index = 1;
                else
                    self.index = self.index + 1;
                end
                self.onChange();
            end
            self.text:clean();
            self.text:insert("◀" .. self.items[self.index] .. "▶");
            self:repaint();
        end
    end

    function SelectBox:onChange()
        
    end

    function SelectBox:getSelected()
        if #self.items > 0 then
            return self.items[self.index];
        end
    end

    IKit.Class(SelectBox,"SelectBox",{extends="Lable"});
end)();

function MessageBox(caption,text,callback)
    local messagebox = IKit.New("Frame");

    local plane = IKit.New("Plane",1,25,25,50,30);

    local caption = IKit.New("Lable",2,2,2,96,20,caption);
    caption.style.fontsize = 2;
    caption.style.textalign = "left"

    local text = IKit.New("Lable",3,2,0,96,50,text);
    text.style.newline = true;

    local mb_ok = IKit.New("Button",4,30,5,40,15,"好的");
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

function SelectBox(caption,items,callback)
    local selectbox = IKit.New("Frame");

    local plane = IKit.New("Plane",1,25,25,50,30);

    local caption = IKit.New("Lable",2,2,2,96,20,caption);
    caption.style.fontsize = 2;
    caption.style.textalign = "left"

    local items = IKit.New("SelectBox",1,5,5,90,40,items);
    items.style.newline = true;

    local mb_ok = IKit.New("Button",4,30,5,40,15,"选择");
    mb_ok.style.newline = true;

    function mb_ok:onClick()
        selectbox:hide();
        if callback ~= nil then
            callback(items:getSelected());
        end
    end
    selectbox:add(
        plane:add(
            caption,
            items,
            mb_ok
        )
    );
    selectbox:setFocus(plane);
    selectbox:show();
end

function EditBox(caption,text,type,callback)
    local editbox = IKit.New("Frame");

    local plane = IKit.New("Plane",1,25,25,50,30);

    local caption = IKit.New("Lable",2,2,2,96,20,caption);
    caption.style.fontsize = 2;
    caption.style.textalign = "left"

    local edit = IKit.New("Edit",1,5,5,90,40,text);
    edit.style.newline = true;
    edit.style.intype = type;

    local mb_ok = IKit.New("Button",4,30,5,40,15,"选择");
    mb_ok.style.newline = true;

    function mb_ok:onClick()
        editbox:hide();
        if callback ~= nil then
            callback(edit:getText());
        end
    end
    editbox:add(
        plane:add(
            caption,
            edit,
            mb_ok
        )
    );
    editbox:setFocus(plane);
    editbox:show();
end