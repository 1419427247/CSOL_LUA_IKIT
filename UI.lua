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
    if ShowKeyInfo == true then
        local keyInfo = {"KeyInfo "};
        for key, value in pairs(inputs) do
            if value == true then
                keyInfo[#keyInfo+1] = key .. " ";
            end
        end
        Command:sendMessage(table.concat(keyInfo));
    end
end);
