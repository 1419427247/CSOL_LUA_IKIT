if Game then
    Command:register("kill",function(player,args)
        local i = 1;
        while Game.Player:Create(i)~=nil do
            if args[1]:toString() == Game.Player:Create(i).name then
                Game.Player:Create(i):Kill();
                return;
            end
            i = i + 1;
        end
    end)
    Command:register("freeze",function(player,args)
        local i = 1;
        local n = {"freeze "};
        while Game.Player:Create(i)~=nil do
            if args[1]:toString() == Game.Player:Create(i).name then
                n[#n+1] = " " .. args[1]:toString();
                Command:sendMessage(player,table.concat(n));
                return;
            end
            i = i + 1;
        end
    end)

    Command:register("unfreeze",function(player,args)
        local i = 1;
        local n = {"unfreeze "};
        while Game.Player:Create(i)~=nil do
            if args[1]:toString() == Game.Player:Create(i).name then
                n[#n+1] = " " .. args[1]:toString();
                Command:sendMessage(player,table.concat(n));
                return;
            end
            i = i + 1;
        end
    end)

    Command:register("tp",function(player,args)
        local i = 1;
        while Game.Player:Create(i)~=nil do
            if args[1]:toString() == Game.Player:Create(i).name then
                local p = Game.Player:Create(i);
                player.position = p.position;
                return;
            end
            i = i + 1;
        end
    end)
    Command:register("sethome",function(player,args)
        player.user.home = player.position; 
    end)

    Command:register("gohome",function(player,args)
        if not player.user.home then 
            print("未设置家");
            return;
        end
        player.position = player.user.home; 
    end)

    Command:register("ops",function(player,args)
        local i = 1;
        local n = {"ops"};
        while Game.Player:Create(i)~=nil do
            n[#n+1] = " " .. Game.Player:Create(i).name;
            i = i + 1;
        end
        Command:sendMessage(player,table.concat(n));
    end)
elseif UI then
    local Online_players = {};

    Command:register("ops",function(args)
        Online_players = {};
        for i = 1, #args, 1 do
            Online_players[#Online_players+1] = args[i];
        end
    end)

    Command:register("freeze",function()
        UI.StopPlayerControl(true);
    end)

    Command:register("unfreeze",function()
        UI.StopPlayerControl(false);
    end)
    local frame = IKit.New("Frame"):add(
        IKit.New("Plane","root",80,0,20,100):add(
            IKit.New("Plane","0_1",0,0,100,100)
        )
    );
    
    local selectbox2 = IKit.New("SelectBox","1_2",2,2,96,10,{"页数/1","页数/2"});
    local button4 = IKit.New("Button","1_4",2,2,96,10,"杀死");
    local button5 = IKit.New("Button","sethome",2,2,96,10,"设置家");
    local button6 = IKit.New("Button","gohome",2,2,96,10,"回到家");
    local button7 = IKit.New("Button","tp",2,2,96,10,"移动到");
    local button8 = IKit.New("Button","freeze",2,2,96,10,"冻结");
    local button9 = IKit.New("Button","unfreeze",2,2,96,10,"解冻");

    selectbox2.style.newline = true;
    button4.style.newline = true;
    button5.style.newline = true;
    button6.style.newline = true;
    button7.style.newline = true;
    button8.style.newline = true;
    button9.style.newline = true;

    function button4:onClick()
        frame:hide();
        Command:sendMessage("ops");
        Timer:schedule(function()
            SelectBox("请选择玩家",Online_players,function(item)
                Command:sendMessage("kill ".. item:toString());
                frame:show();
            end);
        end,0.2);
    end

    function button5:onClick()
        frame:hide();
        Command:sendMessage("sethome");
        MessageBox("提示","已设置家",function()
            frame:show();
        end)
    end

    function button6:onClick()
        Command:sendMessage("gohome");
    end

    function button7:onClick()
        frame:hide();
        Command:sendMessage("ops");
        Timer:schedule(function()
            SelectBox("请选择玩家",Online_players,function(item)
                Command:sendMessage("tp ".. item:toString());
                frame:show();
            end);
        end,0.2);
    end
    
    function button8:onClick()
        frame:hide();
        Command:sendMessage("ops");
        Timer:schedule(function()
            SelectBox("请选择玩家",Online_players,function(item)
                Command:sendMessage("freeze ".. item:toString());
                frame:show();
            end);
        end,0.2);
    end

    function button8:onClick()
        frame:hide();
        Command:sendMessage("ops");
        Timer:schedule(function()
            SelectBox("请选择玩家",Online_players,function(item)
                Command:sendMessage("unfreeze ".. item:toString());
                frame:show();
            end);
        end,0.2);
    end

    function selectbox2:onChange()

    end
    frame:findByTag("root").style.backgroundcolor.alpha = 0;
    frame:findByTag("0_1"):add(selectbox2,button4,button5,button6,button7,button8,button9);

    frame:setFocus(frame:findByTag("0_1"));

    Event:addEventListener("OnKeyDown",function(inputs)
        if inputs[UI.KEY.K] == true then
            if frame.isvisible then
                frame:findByTag("0_1").isfreeze = true;
                frame:findByTag("0_1"):animate({"style.left",100},50,function()
                frame:hide();
              end);
            else
                frame:findByTag("0_1").isfreeze = false;
                frame:show();
                frame:findByTag("0_1").style.left = 100;
                frame:findByTag("0_1"):repaint();
                frame:findByTag("0_1"):animate({"style.left",0},50);
            end
        end
    end);
    MessageBox("提示","按K键打开工具栏");
end