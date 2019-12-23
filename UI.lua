
-- Frame = IKit.New("Frame");
-- Frame:add(
--     IKit.New("Plane",1):add(
--         IKit.New("Lable",2,"你好啊，亲爱的冒险者"),
--         IKit.New("Edit",3,"3"),
--         IKit.New("Button",4,"4")
--     )
-- );
-- Component1 = Frame:findByTag(1);
-- Component1.style.top = 0;
-- Component1.style.left = 25;
-- Component1.style.width = 50;
-- Component1.style.height = 100;


-- Component2 = Frame:findByTag(2);
-- Component2.style.left = 0;
-- Component2.style.top =0;
-- Component2.style.width = 25;
-- Component2.style.height = 10;
-- Component2.style.newline = true;

-- Component3 = Frame:findByTag(3);
-- Component3.style.left = 0;
-- Component3.style.top =0;
-- Component3.style.width = 25;
-- Component3.style.height = 10;
-- Component3.style.newline = true;

-- Component4 = Frame:findByTag(4);
-- Component4.style.left = 0;
-- Component4.style.top =0;
-- Component4.style.width = 25;
-- Component4.style.height = 10;
-- function Component4:onClick()
--     print("你点击了我QWQ");
-- end


-- Frame:setFocus(Component1);

-- Frame:show();

IKit.New("MessageBox","标题","你好啊,亲爱的冒险者,欢迎来到我的世界");
