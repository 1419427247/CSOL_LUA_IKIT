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

    function Component:onFocus()
        
    end

    function Component:onBlur()
        
    end

    IKit.Class(Component,"Component");
end)();

(function()
    local Container = {};

    function Container:constructor()
        self.super();
        self.children = {};
    end

    function Container:add(...)
        local components = {...};
        for i = 1, #components, 1 do
            components[i].father = self;
            self.children[#self.children+1] = components[i];
        end
        return self;
    end

    function Container:remove(index)
        return table.remove(self.children,index);
    end

    IKit.Class(Container,"Container",{extends = "Component"});
end)();

(function()
    local Windows = {};

    function Windows:constructor()
        self.super();
        self.graphics = IKit.New("Graphics");
        self.activecomponent = "nil";

        self.width = UI.ScreenSize().width;
        self.height = UI.ScreenSize().height;
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
        component:paint(self.graphics);
        if component.children ~= nil then
            for i = 1,#component.children,1 do
                self:repaint(component.children[i]);
            end
        end
    end

    function Windows:update()
        self:repaint();
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

    function Lable:constructor(tag,left,top,width,heigth,text)
        self.super(tag,left,top,width,heigth);
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