local windows = IKit.New("Windows")
local button = IKit.New("Component");
button.style.left = "35%";
button.style.top = "15%";
button.style.width = "15%";
button.style.height = "15%";
button.style.backgroundcolor.red = 123;
button.onfouce = function()
    button.style.backgroundcolor.red = 0;
    windows:repaint();
    print("ww哦多的")
end
windows:add(button);

local button = IKit.New("Edit","你好");
button.style.left = "35%";
button.style.top = "15%";
button.style.width = "15%";
button.style.height = "15%";
button.style.backgroundcolor.red = 123;
button.onfouce = function()
    print("QWQ")
end
windows:add(button);

windows:enable();
windows:reset();
windows:repaint();