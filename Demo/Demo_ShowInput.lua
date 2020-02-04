-- function GetType(self)
--     print(self.type);
-- end

-- local windows = IKit.New("Windows"):add(
--     IKit.New("Component",{"style.left","30%","style.top","25%","style.width","15%","style.height","15%"}),
--     IKit.New("Br"),
--     IKit.New("Component",{"style.left","5%","style.top","15%","style.width","15%","style.height","15%","onclick",GetType})
-- );

-- windows:enable();
-- windows:reset();
-- windows:repaint();

if Game then
    local lplayer = Game.SyncValue.Create("lplayer");
end

if UI then
    local lplayer = UI.SyncValue.Create("lplayer");
    function UI.Event:OnInput (inputs)
        
    end

    Label = {
        
    };

    function Label:Create()
        self.box = UI.Text.Create();
        self.box:Set({
            text = string.format("%5.0f",3.412312),
            font = 'medium',
            align = 'center',
            x = 0,
            y = UI.ScreenSize().height / 9 * 8,
            width = UI.ScreenSize().width,
            height = 40,
            r = 250,
            g = 10,
            b = 10,
            a = 250
        });
    end

    function Label:Show()
        self.box:Show();
    end

    function Label:Hide()
        self.box:Hide();
    end

    Label:Create();
    Label:Hide();

    local i = 0;
    function UI.Event:OnUpdate(time)
        if i == 1 then
            Label:Hide();
            i = 0;
        else
            Label:Show();
            i = 1;
        end
    end
end