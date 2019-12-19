Font = {};
Font["a"]={0,0,1,4,2,0,3,4,1,1,2,2,1,4,2,5};
Font["b"]={0,0,1,5,1,0,2,1,1,2,2,3,1,4,2,5,2,1,3,2,2,3,3,4};
Font["c"]={0,1,1,4,1,0,3,1,1,4,3,5};
Font["d"]={0,0,1,5,1,0,2,1,1,4,2,5,2,1,3,4};
Font["e"]={0,1,1,4,1,0,3,1,1,2,3,3,1,4,3,5};
Font["f"]={0,0,1,4,1,2,3,3,1,4,3,5};
Font["g"]={0,1,1,4,1,0,2,1,2,0,3,3,1,4,3,5};
Font["h"]={0,0,1,5,2,0,3,5,1,2,2,3};
Font["i"]={1,0,2,5};
Font["j"]={0,1,1,3,1,0,2,1,2,1,3,5};
Font["k"]={0,0,1,5,2,0,3,2,2,3,3,5,1,2,2,3};
Font["l"]={0,1,1,5,1,0,3,1};
Font["m"]={0,0,1,5,2,0,3,5,1,3,2,4};
Font["n"]={0,0,1,5,1,4,2,5,2,0,3,4};
Font["o"]={0,1,1,4,2,1,3,4,1,0,2,1,1,4,2,5};
Font["p"]={0,0,1,4,1,1,2,2,1,4,2,5,2,2,3,4};
Font["q"]={0,2,1,4,2,2,3,4,1,0,2,2,1,4,2,5};
Font["r"]={0,0,1,4,1,1,2,2,1,4,2,5,2,2,3,4,2,0,3,1};
Font["s"]={0,0,2,1,2,1,3,2,1,2,2,3,0,3,1,4,1,4,3,5};
Font["t"]={0,4,3,5,1,0,2,4};
Font["u"]={0,0,1,5,1,0,2,1,2,1,3,5};
Font["v"]={0,1,1,5,1,0,2,1,2,1,3,5};
Font["w"]={0,0,1,5,2,0,3,5,1,1,2,2};
Font["x"]={0,0,1,2,0,3,1,5,2,0,3,2,2,3,3,5,1,2,2,3};
Font["y"]={0,3,1,5,2,3,3,5,1,0,2,3};
Font["z"]={0,0,3,1,0,4,3,5,0,1,1,2,1,2,2,3,2,3,3,4};
Font["0"]={0,0,1,5,2,0,3,5,1,0,2,1,1,4,2,5};
Font["1"]={1,0,2,5,0,3,1,4};
Font["2"]={0,0,1,3,2,2,3,5,1,0,3,1,1,2,2,3,0,4,2,5};
Font["3"]={2,0,3,5,0,0,2,1,0,2,2,3,0,4,2,5};
Font["4"]={0,2,1,5,2,0,3,5,1,2,2,3};
Font["5"]={0,2,1,5,0,0,3,1,1,2,3,3,1,4,3,5,2,1,3,2};
Font["6"]={0,0,1,5,1,0,3,1,1,2,3,3,1,4,3,5,2,1,3,2};
Font["7"]={0,4,3,5,2,0,3,4};
Font["8"]={0,0,1,5,2,0,3,5,1,0,2,1,1,2,2,3,1,4,2,5};
Font["9"]={0,0,3,1,2,1,3,5,0,2,1,5,1,2,2,3,1,4,2,5};
Font["."]={1,0,2,1};
Font[":"]={1,1,2,2,1,3,2,4};
Font["?"]={1,0,2,1,1,2,2,3,2,2,3,5,0,4,2,5};
Font["!"]={1,0,2,1,1,2,2,5};
Font["+"]={1,1,2,4,0,2,3,3};
Font["-"]={0,2,3,3};
Font["("]={0,1,1,4,1,0,2,1,1,4,2,5};
Font["("]={2,1,3,4,1,0,2,1,1,4,2,5};
Font[">"]={0,0,1,1,1,1,2,2,2,2,3,3,0,4,1,5,1,3,2,4};
Font["<"]={0,2,1,3,1,1,2,2,0,2,1,3,1,3,2,4,2,4,3,5};
Font["="]={0,1,3,2,0,3,3,4};
Font["\'"]={1,3,2,5};
Font["\\"]={0,3,1,5,1,2,2,3,2,0,3,2};
Font["/"]={0,0,1,2,1,2,2,3,2,3,3,5};

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

    function Graphics:getTextSize(text,fontsize,letterspacing)
        local width = (text.length - 1) * letterspacing + 3 * fontsize;
        local height = 5 * fontsize;
        return width,height;
    end

    function Graphics:clean()
        for i = 1, #self.root, 1 do
            self.root[i] = nil;
        end
        self.root = {};
        collectgarbage("collect");
    end

    IKit.Create(Graphics,"Graphics");
end)();


(function()
    local Frame = {};
    function Frame:constructor(width,height)
        self.x=0;
        self.y=0;
        self.width = width or UI.ScreenSize().width;
        self.height = height or UI.ScreenSize().height;
        self.graphics = IKit.New("Graphics");
        self.children = {};
        self.focused = 0;

        local OnKeyDownEventId = 0;
        local OnKeyUpEventId = 0;
        
        function self:show()
            OnKeyDownEventId = Event:addEventListener("OnKeyDown",function(inputs)
                self:onKeyDown(inputs);
            end);
            OnKeyUpEventId = Event:addEventListener("OnKeyUp",function(inputs)
                self:onKeyUp(inputs);
            end);
            self:repaint();
        end

        function self:hide()
            Event:detachEventListener("OnKeyDown",OnKeyDownEventId);
            Event:detachEventListener("OnKeyUp",OnKeyUpEventId);
            self:repaint();
        end

    end


    function Frame:add(...)
        local components = {...};
        for i = 1, #components, 1 do
            components[i].father = self;
            table.insert(self.children,components[i]);
        end
        return self;
    end

    function Frame:setFocus(component)
        if self.focused ~= 0 then
            self.focused:onBlur();
        end
        self.focused = component;
        self.focused:onFocus();
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
            end

            for i = 1, #components,1 do
                self:reset(components[i].children);
            end
    end

    function Frame:paint()
        self:forEach(function(component)
            if component.visible == true then
                component:paint(self.graphics);
            end
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

    IKit.Create(Frame,"Frame");
end)();

(function()
    local Component = {};
    function Component:constructor(id)
        self.id = id;
        self.tag = self.type;
        self.visible = true;
        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
        self.style = {
            left = 0,
            top = 0,
            width = 0,
            height = 0,
            position = "relative",
            backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
            border = {top = 1,left = 1,right = 1,bottom = 1},
            bordercolor = {red = 0,green = 0,blue=0,alpha=255},
            newline = false,
        };
        self.father = 0;
        self.children = {};
    end

    function Component:getIndex()
        for i = 1, #self.father.children, 1 do
            if self.father.children[i] == self then
                return i;
            end
        end
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

    function Component:onBlur()
        self.style.backgroundcolor.red = self.style.backgroundcolor.red - 128;
        self.style.backgroundcolor.green = self.style.backgroundcolor.green - 128;
        self.style.backgroundcolor.blue = self.style.backgroundcolor.blue - 128;
        self:repaint();
    end

    function Component:onFocus()
        self.style.backgroundcolor.red = self.style.backgroundcolor.red + 128;
        self.style.backgroundcolor.green = self.style.backgroundcolor.green + 128;
        self.style.backgroundcolor.blue = self.style.backgroundcolor.blue + 128;
        self:repaint();
    end

    function Component:onKeyDown(inputs)

    end

    function Component:onKeyUp(inputs)

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

    function Plane:constructor(id)
        self.super(id);
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
        self.style.border.left = self.style.border.left + 5;
        self.style.border.right = self.style.border.right + 5;
        self.style.border.top = self.style.border.top + 5;
        self.style.border.bottom = self.style.border.bottom + 5;
        self:repaint();
    end

    function Plane:onBlur()
        if #self.children > 0 then
            self.children[self.index]:onBlur();
        end
        self.style.border.left = self.style.border.left - 5;
        self.style.border.right = self.style.border.right - 5;
        self.style.border.top = self.style.border.top - 5;
        self.style.border.bottom = self.style.border.bottom - 5;
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
            self.children[self.index]:onKeyDown(inputs);
        end
    end

    function Plane:onKeyUp(inputs)
        if #self.children == 0 then
            return;
        end
        self.children[self.index]:onKeyUp(inputs);
    end

    function Plane:paint(graphics)
        self.super:paint(graphics);
    end

    IKit.Create(Plane,"Plane","Component");
end)();


(function()
    local Lable = {};

    function Lable:constructor(id,text)
        self.super(id);
        self.text = IKit.New("String",text);
        self.style.fontsize = 5;
        self.style.letterspacing = 25;
        self.style.textalign = "center";
        self.style.color = {red = 0,green = 0,blue=0,alpha=255};
    end

    function Lable:paint(graphics)
        self.super:paint(graphics);
        graphics.color = self.style.color;
        local w,h = graphics:getTextSize(self.text,self.style.fontsize,self.style.letterspacing);
        if self.style.textalign == "center" then
            graphics:drawText(self.x + (self.width - w)/2,self.y + (self.height + h) / 2,self.style.fontsize,self.style.letterspacing,self.text);
        elseif self.style.textalign == "left" then
            graphics:drawText(self.x,self.y + (self.height + h) / 2,self.style.fontsize,self.style.letterspacing,self.text);
        elseif self.style.textalign == "rigth" then
            graphics:drawText(self.x + (self.width - w),self.y + (self.height + h) / 2,self.style.fontsize,self.style.letterspacing,self.text);
        end
    end

    IKit.Create(Lable,"Lable","Component");
end)();

(function()
    local Edit = {};

    function Edit:constructor(id)
        self.super(id);
        self.cursor = 1;
    end

    function Edit:paint(graphics)
        self.super:paint(graphics);
        local w,h = graphics:getTextSize(self.text,self.style.fontsize,self.style.letterspacing);

        if self.style.textalign == "center" then
            graphics:drawRect(self.x + (self.width - w)/2 + (self.cursor - 1) * self.style.letterspacing - (self.style.letterspacing - self.style.fontsize * 3)/2 ,
            self.y + (self.height - h) / 2,
            self.style.fontsize / 2,
            self.style.fontsize * 5);
        elseif self.style.textalign == "left" then
            graphics:drawRect(self.x + (self.cursor - 1) * self.style.letterspacing - (self.style.letterspacing - self.style.fontsize * 3)/2 ,
            self.y + (self.height - h) / 2,
            self.style.fontsize / 2,
            self.style.fontsize * 5);
        elseif self.style.textalign == "rigth" then
            graphics:drawRect(self.x + (self.cursor - 1) * self.style.letterspacing + (self.width - w) - (self.style.letterspacing - self.style.fontsize * 3)/2 ,
            self.y + (self.height - h) / 2,
            self.style.fontsize / 2,
            self.style.fontsize * 5);
        end
    end

    function Edit:onKeyDown(inputs)
        self.super:onKeyDown(inputs);
        for key, value in pairs(inputs) do
            if value == true then
                if key >=0 and key <= 8 then
                    self.text:insert(string.char(key+49),self.cursor);
                    self.cursor = self.cursor + 1;
                end
                if key == 9 then
                    self.text:insert('0',self.cursor);
                    self.cursor = self.cursor + 1;
                end
                if key >= 10 and key <= 35 then
                    self.text:insert(string.char(key+87),self.cursor);
                    self.cursor = self.cursor + 1;
                end
                if key == 37 then
                    self.text:insert(' ',self.cursor);
                    self.cursor = self.cursor + 1;
                end
                if key == 41 then
                    if self.cursor > 1 then
                        self.cursor = self.cursor - 1;
                    end
                end
                if key == 42 then
                    if self.cursor < self.text.length + 1 then
                        self.cursor = self.cursor + 1;
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

    function Button:constructor(id,text)
        self.super(id,text);
    end

    function Button:paint(graphics)
        self.super:paint(graphics);
    end

    function Button:onKeyDown(inputs)
        if inputs[UI.KEY.MOUSE1] == true then
            self:onMouseClick();
        end
    end

    function Button:onMouseClick()

    end

    IKit.Create(Button,"Button","Lable");
end)();

(function()
    local SelectBox = {};
    
    function SelectBox:constructor(id)
        self.super(id);
        self.list = {};
    end
    
    function SelectBox:addItem()
        
    end
    
    function SelectBox:paint(graphics)
    
    end
    
    IKit.Create(SelectBox,"SelectBox","Plane");
end)();


