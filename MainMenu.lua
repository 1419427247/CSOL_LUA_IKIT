if UI~=nil then
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
            MainMenu:animate({
                {key="fontsize",value = math.random(5)}},
            80,function() Toast:makeText("改变了字号") end);
            return true;
        end,
    },

    "帮助",function() Toast:makeText("作者:@iPad水晶"); end
});
    
end