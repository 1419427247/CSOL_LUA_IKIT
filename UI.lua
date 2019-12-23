
Frame = IKit.New("Frame");
Frame:add(
    IKit.New("Plane",1):add(
        IKit.New("Button",2,"2"),
        IKit.New("Edit",3,"3"),
        IKit.New("Button",4,"4")
    )
);
Component1 = Frame:findByTag(1);
Component1.style.top = 0;
Component1.style.left = 25;
Component1.style.width = 50;
Component1.style.height = 100;


Component2 = Frame:findByTag(2);
Component2.style.left = 0;
Component2.style.top =0;
Component2.style.width = 25;
Component2.style.height = 10;
Component2.style.backgroundcolor.red = 15;
Component2.style.newline = true;

Component3 = Frame:findByTag(3);
Component3.style.left = 0;
Component3.style.top =0;
Component3.style.width = 25;
Component3.style.height = 10;
Component3.style.backgroundcolor.red = 15;
Component3.style.newline = true;

Component4 = Frame:findByTag(4);
Component4.style.left = 0;
Component4.style.top =0;
Component4.style.width = 25;
Component4.style.height = 10;
Component4.style.backgroundcolor.red = 15;

Frame:setFocus(Component1);

Frame:show();

