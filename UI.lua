windows = IKit.New("Windows");
windows.style.backgroundcolor.alpha = 100;

local button = IKit.New("Component");
button.style.left = "33%";
button.style.top = "33%";
button.style.width = "33%";
button.style.height = "33%";

windows:add(button);

local button = IKit.New("Component");
button.style.left = "100px";
button.style.top = "100px";
button.style.width = "100px";
button.style.height = "100px";

windows:add(button);

local button = IKit.New("Component");
button.style.left = "100px";
button.style.top = "100px";
button.style.width = "100px";
button.style.height = "100px";
button.style.newline = true;
windows:add(button);

local button = IKit.New("Component");
button.style.left = "100px";
button.style.top = "100px";
button.style.width = "100px";
button.style.height = "100px";

windows:add(button);

windows:reset();
windows:repaint();

print(button.x,button.y,button.width,button.height)