
Frame = IKit.New("Frame");
Frame:show(Event);
Frame:add(
    IKit.New("Plane",1):add(
        IKit.New("Plane",2):add(
            IKit.New("Edit",4,"qwq")
        ),
        IKit.New("Plane",3)
    )
);
Component1 = Frame:findById(1);
Component1.style.top = 20;
Component1.style.left = 20;
Component1.style.width = 60;
Component1.style.height = 30;

Component2 = Frame:findById(2);
Component2.style.width = 50;
Component2.style.height = 20;

Component3 = Frame:findById(3);
Component3.style.width = 50;
Component3.style.height = 20;

Component4 = Frame:findById(4);
Component4.style.left = 10;
Component4.style.top =10;
Component4.style.width = 80;
Component4.style.height = 80;
Component4.style.backgroundcolor.blue = 0;



Frame:reset();
Frame:setFocus(Component1);

Frame:repaint();

Timer:schedule(function()
    Component4.x = Component4.x + 0.5;
    Component3.height = Component3.height + 0.5;
    Frame:repaint();
end,1,0.03);