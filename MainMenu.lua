if UI~=nil then
    -- Class("Circle",function(Circle)
    --     function Circle:constructor(x,y,radius)
    --         self.super(x,y);
    --         self.radius = radius;
    --         self.backgroundcolor[4] = 0;
    --     end

    --     function Circle:paint()
    --         self.super:paint();
    --         for i = -self.radius,self.radius do
    --             local x = (math.sqrt(self.radius*self.radius - i * i));
    --             Graphics:drawRect(self,self.x + x,self.y + i,-2 * x,1);
    --         end
    --     end
    -- end,Component);
    -- b = Circle:New(300,300,400)
    -- b:show();

    -- Tickeys = Font:New();
    -- Tickeys:load('11015011104112411 200212112131204112411 30031211312110421 420151111021213113311 51021012122120421 610210114122123121411 7003121121312 80031011121111211031223121411 900310112211312110421 01011011321131411 ');

    -- edit = Edit:New(400,400,200,100);
    -- edit.font = Tickeys;
-- edit:show();

    MainMenu:add({
    "更多设置",{
        "改变颜色",function() 
            MainMenu.fontcolor = {math.random(255),math.random(255),math.random(255),255};
            return true;
        end,
        "字号加大",function()
             MainMenu.fontsize = MainMenu.fontsize + 1; 
             return true;
            end,
        "字号减小",function() 
            if MainMenu.fontsize > 1 then 
                MainMenu.fontsize = MainMenu.fontsize - 1; 
            end 
            return true;
        end,
        "左移",function() 
            MainMenu.x = MainMenu.x - 10;
            return true;
        end,
        "右移",function()
            MainMenu.x = MainMenu.x + 10;
            return true;
        end,
        "加大行距",function()
            MainMenu.lineheight = MainMenu.lineheight + 5;
            return true;
        end,
        "缩小行距",function()
            MainMenu.lineheight = MainMenu.lineheight - 5;
            return true;
        end,
        "关闭",function() end,
    },
    "动画效果",
    {
        "改变颜色",function()
            MainMenu:animate({
                {table = MainMenu.fontcolor,key=1,value = math.random(255)},
                {table = MainMenu.fontcolor,key=2,value = math.random(255)},
                {table = MainMenu.fontcolor,key=3,value = math.random(255)}},
            120,function() Toast:makeText("变色动画结束了") end);
            return true;
        end,
        "x=300",function()
            MainMenu:animate({
                {key="x",value = 300}},
            120,function() Toast:makeText("x=300动画结束了") end);
            return true;
        end,            
        "x=0",function()
            MainMenu:animate({
                {key="x",value = 0}},
            120,function() Toast:makeText("x=0动画结束了") end);
            return true;
        end,
        "行高",function()
            MainMenu:animate({
                {key="lineheight",value = math.random(50)}},
            120,function() Toast:makeText("改变了行高") end);
            return true;
        end,
        "随机字号",function()
            local ran =  math.floor(math.random(5));
            print(ran);
            MainMenu:animate({
                {key="fontsize",value = ran}},
            80,function() Toast:makeText("改变了字号") end);
            return true;
        end,
    },

    "帮助",function() Toast:makeText("作者:@iPad水晶"); end
},1);
DIV = Container:New();
DIV:add(Lable:New(0,0,0,0,"text"));
DIV:add(Lable:New(88,88,0,0,"QWQ"));
DIV:show();

Event:addEventListener(Event.OnKeyDown,function(self,inputs)
    if inputs[UI.KEY.U] == true then
        print("QWQ")
        DIV:hide();
    end
end);

end


if UI ~= nil then
    -- com1 = '0y0y0w8201010901010201080a0201010b030101040405010c04010104050104090501010d0501010a0601010e0601010b0701010f0701010c0801010g080101050901010d0901010h090101020a0101060a01010e0a01010i0a0101030b0101070b01010f0b01010j0b0101040c0101080c01010g0c01010k0c01010q0c01040r0c0201050d0101090d01010h0d01010l0d01010t0d0101060e01010a0e01010i0e01010m0e01010u0e0101070f01010b0f01010j0f01010n0f01010v0f0101080g01010c0g01010k0g01010o0g02010w0g0103090h01010d0h01010l0h01020a0i01010e0i01010b0j01010f0j01010m0j02010v0j01010c0k01010g0k01010o0k01010u0k01010d0l01010h0l02010t0l01010e0m01010j0m01020s0m01010f0n01010r0n01030g0o01020k0o01010c0q04010s0q01010c0r01020n0r03010t0r01010m0s01010q0s01010u0s01020d0t01010l0t01010r0t01010e0u01010k0u01010s0u02010f0v01010j0v01010g0w0301 26jD0202080102030107090302010a0402010b0502010c0602010d0702010e080201030901020f090201040a01020g0a0201050b01020h0b0201060c01020j0c0101070d01020k0d01010s0d0101080e01020l0e01010t0e0101090f01020m0f01010u0f01010a0g01020n0g01010q0g01010v0g01030b0h01020c0j01010d0k01010q0k01020e0l01010p0l01020f0m01010o0m01010g0n01010m0o01020q0o01010l0p01020g0q01010k0q01020o0q01010r0q01010q0r01010s0r01010d0s01010r0s01010t0s01020e0t01010s0t01010f0u01010g0v0301 3WL>0303010107030201030701020r0d01040s0e01030t0f01030m0g01010u0g01040n0h04010o0j01010n0k01010t0k01010s0l01010g0m01010r0m01010h0n01040k0n01010q0n01010j0o01010n0q01010d0r04010m0r01010e0s03010l0s01010f0t03010k0t01010g0u0401 Au3>0403030103040103090401010a0501010b0601010c0701010d080101040901010e090101050a01010f0a0101060b01010g0b0101070c01010h0c0101080d01010i0d0101090e01010j0e01010a0f01010k0f01010b0g01010l0g01010c0h01010m0h01020r0h02010d0i01010n0i04010t0i01010e0j01010f0k01010g0l01010n0l01010h0m02010m0m01010i0n01040l0n01010h0r01020i0t0101 YfzX050504010506020108060201090702010a0802010b0902010c0a02010d0b02010e0c02010f0d02010g0e02010h0f02010i0g02010j0h02010k0i01010l0j01010m0k0101 PsTd0706010105070102080701050608020109080101060902010a090105070a0101090a01030b0a01010c0b01050b0c01030d0c01010e0d01010d0e01030f0e01010e0f01030h0g01010f0h02010f0i02010g0j01010h0k02010j0l0101 DpSt06070201090901010b0b01010d0d01010e0e01010f0f02010f0g02010h0h01030i0h01030j0i01010k0j01010j0k01010k0m0101 nFj>0i0c01010j0d01010k0e01010l0f01010c0i01010d0j01010e0k01010f0l0101 7gOp0r0i02010p0j02010t0j01010s0k01010o0l01010r0l01010n0m01010q0m01010m0n01010p0n01020l0o01010j0p01020n0p02010m0q01010i0r01020l0r01010k0s01010j0t0101 uTJX0j0j01010k0k02010k0l0201 dOfb0r0j02010r0k01010n0n02010n0o02010p0p02010p0q02010j0r01020r0r01010s0s0101 C6L>0p0k01010k0p0101 07Xo0m0l01010l0m0101 ';
    -- b = Bitmap:New(com1);
    -- b.size = 5;
    -- p1 = PictureBox:New(0,0,1000,1000,b);
    -- p2 = PictureBox:New(80,0,1000,1000,b);
    -- p3 = PictureBox:New(444,21,1000,1000,b);
    -- p4 = PictureBox:New(33,43,1000,1000,b);
    
    -- p1:show();
    -- p2:show();
    -- p3:show();
    -- p4:show();

end