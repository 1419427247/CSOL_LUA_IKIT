-- local frame2 = IKit.New("Frame");
-- frame2:add(
--     IKit.New("Plane","1",25,0,50,80):add(
--         IKit.New("SelectBox","2",5,2,25,10,{"男","女"}),
--         IKit.New("Edit","3",5,2,25,10,"编辑框"),
--         IKit.New("Button","4",5,2,25,10,"弹窗"),

--         IKit.New("Plane","5",2,5,96,55):add(
--             IKit.New("SelectBox","6",5,5,25,20,{"第一","第二","第三"}),
--             IKit.New("Edit","7",5,5,25,20,"3"),
--             IKit.New("Button","8",5,5,25,20,"4")
--         )
--     )
-- );

-- frame2:findByTag("7").style.newline = true;

-- frame2:findByTag("4").onClick = function(self)
--     frame2:hide();
--     MessageBox("这只是一个测试","你好,亲爱的我大三大四的安慰请问权威玩家,欢迎来到我的世界",function()
--         frame2:show();
--         frame2:findByTag("1"):animate({"style.left",0},150,function()
--             frame2:findByTag("1"):animate({"style.left",25},150);
--         end);
--     end);
-- end

-- frame2:findByTag("5").style.newline = true;
-- frame2:setFocus(frame2:findByTag("1"));

-- MessageBox("这只是一个测试","你好,亲爱的玩家,欢迎来到我的世界",function()
--     frame2:show();
--     frame2:findByTag("1"):animate({"style.left",0},150,function()
--         frame2:findByTag("1"):animate({"style.left",25},150);
--     end);
-- end);

Command:register("kill",function(args)
    print(#args[1]);
end)