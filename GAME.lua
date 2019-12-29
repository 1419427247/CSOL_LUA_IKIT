----------------------
--这里是我加滴ヾ(≧▽≦*)o
----------------------

Command:register("KeyInfo",function(player,args)
    print(player.name .. ":" .. #args);
    for i = 1, #args,1 do
        print(args[i]:toString());
    end
end);