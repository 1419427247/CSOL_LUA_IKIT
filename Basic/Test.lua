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
            border = {top = 0,left = 0,right = 0,bottom = 0},
            bordercolor = {red = 0,green = 0,blue=0,alpha=255},
        };
    end

    IKit.New(Component,"Component");
end)();

(function()
    local Container = {};
    
    function Container:constructor()
        self.father = "nil";
        self.children = {};
    end

    function Container:add()

    end

    function Container:remove()

    end

    IKit.New(Container,"Container",{extends = "Component"});
end)();

(function()
    local Div = {};
    
    function Div:constructor()
        
    end

    IKit.New(Div,"Div",{extends = "Container"});
end)();

(function()
    local Windows = {};
    
    function Windows:constructor()
        
    end

    IKit.New(Windows,"Windows",{extends = "Container"});
end)();