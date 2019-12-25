Frame = IKit.New("Frame");
Frame:add(
    IKit.New("Plane",1,25,0,50,100):add(
        IKit.New("SelectBox",2,0,0,25,10,{"我对他","QWQ"}),
        IKit.New("Edit",3,0,0,25,10,"3"),
        IKit.New("Button",4,0,0,25,10,"4")
    )
);

Frame:findByTag(3).style.newline = true;
Frame:findByTag(4).onClick = function(self)
    Frame:hide();
    MessageBox("这只是一个测试","你好,亲爱的我大三大四的安慰请问权威玩家,欢迎来到我的世界",function()
        Frame:show();
        Frame:findByTag(1):animate({"style.left",0},150,function()
            Frame:findByTag(1):animate({"style.left",25},150);
        end);
    end);
end

Frame:setFocus(Frame:findByTag(1));

MessageBox("这只是一个测试","你好,亲爱的玩家,欢迎来到我的世界",function()
    Frame:show();
    Frame:findByTag(1):animate({"style.left",0},150,function()
        Frame:findByTag(1):animate({"style.left",25},150);
    end);
end);