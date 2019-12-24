
Frame = IKit.New("Frame");
Frame:add(
    IKit.New("Plane",1,25,0,50,100):add(
        IKit.New("Lable",2,0,0,25,10,"你好啊，亲爱的冒险者"),
        IKit.New("Edit",3,0,0,25,10,"3"),
        IKit.New("Button",4,0,0,25,10,"4")
    )
);


Component2 = Frame:findByTag(2);
Component2.style.newline = true;

Component3 = Frame:findByTag(3);
Component3.style.newline = true;

Component4 = Frame:findByTag(4);

function Component4:onClick()
    print("你点击了我QWQ");
end



IKit.New("MessageBox","标题","你好啊,亲爱的冒险者,欢迎来到我的世界",function()
    Frame:setFocus(Frame:findByTag(1));
    Frame:show();
end);
