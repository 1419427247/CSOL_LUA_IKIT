------------------------
--这里是我加滴ヾ(≧▽≦*)o
----------------------
local ShowKeyInfo = true;
Command:register("ShowKeyInfo",function(args)
    if args[1] == "true" then
        ShowKeyInfo = true;
    else
        ShowKeyInfo = false;
    end
end);

Event:addEventListener("OnKeyDown",function(inputs)
    Command:sendMessage("KeyInfo qwq 1 ");
end);
