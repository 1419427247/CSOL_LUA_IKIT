
Frame = IKit.New("Frame");
Frame:add(
    IKit.New("Plane",1):add(
        IKit.New("Plane",2):add(
            IKit.New("Button",4,"帮的"),
            IKit.New("Edit",4,"帮的"),
            IKit.New("Button",4,"文阿")
        )
    )
);
Component1 = Frame:findByTag(1);
Component1.style.top = 20;
Component1.style.left = 20;
Component1.style.width = 60;
Component1.style.height = 30;

Component2 = Frame:findByTag(2);
Component2.style.width = 100;
Component2.style.height = 50;

Component4 = Frame:findByTag(4);
for i = 1, #Component4, 1 do
    Component4[i].style.left = 5;
    Component4[i].style.top =5;
    Component4[i].style.width = 25;
    Component4[i].style.height = 80;
    Component4[i].style.backgroundcolor.blue = 0;

    -- Component4[i].onMouseClick = function(table)
    --     print(table.text:toString());
    -- end
end


Frame:reset();
Frame:setFocus(Component1);

Frame:repaint();

-- Component1:animate({"style.left",0,"style.top",0,"style.width",0,"style.height",0},100);
