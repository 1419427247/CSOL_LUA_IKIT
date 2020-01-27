function GetType(self)
    print(self.type);
end

local windows = IKit.New("Windows"):add(
    IKit.New("Component",{"style.left","5%","style.top","15%","style.width","15%","style.height","15%"}),
    IKit.New("Br"),
    IKit.New("Edit",{"style.left","5%","style.top","15%","style.width","15%","style.height","15%","onclick",GetType})
);
windows:enable();
windows:reset();
windows:repaint();
