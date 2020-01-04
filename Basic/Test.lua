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
            elseif string.find(value,"%")  ~= nil then
                return "%",tonumber(string.sub(value,1,#value - 1));
            end
        end
        return "unkonw",0;
    end

    function Component:paint(graphics)
        graphics.color = self.style.backgroundcolor;
        graphics.opacity = self.opacity;
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

    IKit.New(Component,"Component");
end)();

(function()
    local Container = {};

    function Container:constructor()
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

    IKit.New(Container,"Container",{extends = "Component"});
end)();

(function()
    local Windows = {};

    function Windows:constructor()
        self.graphics = IKit.New("Graphics");
        self.activecomponent = "nil";
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
    
    function Windows:paint(graphics)
        self.super:paint(graphics);
    end

    function Windows:repaint(component)
        local component = component or self;
        component:paint(self.graphics);
        for i = 1,#component.children,1 do
            component[i]:paint();
        end
    end

    function Windows:update()
        self:repaint();
    end

    IKit.New(Windows,"Windows",{extends = "Container"});
end)();

(function()
    local Div = {};

    function Div:constructor()

    end

    IKit.New(Div,"Div",{extends = "Container"});
end)();
