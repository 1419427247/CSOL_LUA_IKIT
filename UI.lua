
Frame = IKit.New("Frame");
Frame:show(Event);
Frame:add(
    IKit.New("Plane",1):add(
        IKit.New("Plane",2):add(
            IKit.New("Lable",4,"34512345")
        ),
        IKit.New("Plane",3)
    )
);
Component1 = Frame:findByTag(1);
Component1.style.top = 20;
Component1.style.left = 20;
Component1.style.width = 60;
Component1.style.height = 30;

Component2 = Frame:findByTag(2);
Component2.style.width = 50;
Component2.style.height = 20;

Component3 = Frame:findByTag(3);
Component3.style.width = 50;
Component3.style.height = 20;

Component4 = Frame:findByTag(4);
Component4.style.left = 10;
Component4.style.top =10;
Component4.style.width = 80;
Component4.style.height = 80;
Component4.style.backgroundcolor.blue = 0;



Frame:reset();
Frame:setFocus(Component1);

Frame:repaint();