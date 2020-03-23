local NONE = 0;

local SKILL = {
    WORLD = {
        TOBEMONSTER = {NAME = "变身怪物",SIGNAL = 101,ISFREEZE = false,COOLDOWNTIME = 0,MEMORY = {}},
        TOBEHUMAN = {NAME = "变身人类",SIGNAL = 102,ISFREEZE = false,COOLDOWNTIME = 0,MEMORY = {}},
    },
    MONSTER = {
        FATALBLOW = {NAME = "致命打击",SIGNAL = 101,ISFREEZE = false,COOLDOWNTIME = 60,MEMORY = {}},
        SUPERJUMP = {NAME = "火箭跳跃",SIGNAL = 102,ISFREEZE = false,COOLDOWNTIME = 10,MEMORY = {}},
        GHOSTSTEP = {NAME = "鬼影步",SIGNAL = 103,ISFREEZE = false,COOLDOWNTIME = 5,MEMORY = {}},
        LIGHTWEIGHT = {NAME = "轻如鸿毛",SIGNAL = 104,ISFREEZE = false,COOLDOWNTIME = 25,MEMORY = {}},
        GRAVITY = {NAME = "地心引力",SIGNAL = 105,ISFREEZE = false,COOLDOWNTIME = 20,MEMORY = {}},
        HITGROUND = {NAME = "撼地一击",SIGNAL = 106,ISFREEZE = false,COOLDOWNTIME = 15,MEMORY = {}},
        LISTEN = {NAME = "聆听",SIGNAL = 107,ISFREEZE = false,COOLDOWNTIME = 20,MEMORY = {}},
	},
    HUMAN = {
        STEEL = {NAME = "铜头铁臂",SIGNAL = 201,ISFREEZE = false,COOLDOWNTIME = 45,MEMORY = {}},
        SPRINTBURST = {NAME = "冲刺爆发",SIGNAL = 202,ISFREEZE = false,COOLDOWNTIME = 30,MEMORY = {}},
        CURE = {NAME = "自我愈合",SIGNAL = 203,ISFREEZE = false,COOLDOWNTIME = 60,MEMORY = {}},
        FIRESTRIKE = {NAME = "火力打击",SIGNAL = 204,ISFREEZE = false,COOLDOWNTIME = 90,MEMORY = {}},
        ADRENALHORMONE = {NAME = "肾上腺素",SIGNAL = 205,ISFREEZE = false,COOLDOWNTIME = 90,MEMORY = {}},
	},
}

local State = {
    Ready = 1,
    Start = 2,
};

Event = (function()
    local Event = {
        array = {},
        id = 1,
    };

    function Event:__add(name)
        if not self.array[name] then
            self.array[name] = {};
            return self;
        end
        error("事件:''" ..name.. "'已经存在,请勿重复添加");
    end

    function Event:__sub(name)
        if self.array[name] then
            self.array[name] = nil;
            return self;
        end
        error("事件:'" ..name.."'不存在");
    end

    function Event:addEventListener(name,event)
        if self.array[name] == nil then
            error("未找到事件'" .. name .. "'");
        end
        if type(event) == "function" then
            self.array[name][#self.array[name] + 1] = {self.id,event};
            self.id = self.id + 1;
            return self.id - 1;
        else
            error("它应该是一个函数");
        end
    end
    
    
    function Event:detachEventListener(id)
        for name,_ in pairs(self.array) do
            for i = 1, #self.array[name],1 do
                if self.array[name][i][1] == id then
                    table.remove(self.array[name],i);
                    return;
                end
            end
        end
        error("未找到'" .. id .. "'");
    end

    function Event:run(name,...)
        for i = #self.array[name],1,-1 do
            self.array[name][i][2](...);
        end
    end
    Event.__index = Event;

    return setmetatable({},Event);
end)();

Timer = (function()
    local Timer = {
        id = 1,
        tasks = {},
        destroyedtasks = {}
    };

    function Timer:onUpdate(time)
        for i = 1 , #self.destroyedtasks do
            self.tasks[i] = nil;
        end
        self.destroyedtasks = {};
        for key, value in pairs(self.tasks) do
            if value.time < time then
                if not pcall(value.func) then
                    self.tasks[key] = nil;
                    print("Timer:ID为:[" .. key .. "]的函数发生了异常");
                elseif value.period == nil then
                    self.tasks[key] = nil;
                else
                    value.time = time + value.period;
                end
            end
        end
    end

    function Timer:schedule(fun,delay,period)
        if Game ~= nil then
            self.tasks[self.id] = {func = fun,time = Game.GetTime() + delay,period = period};
        end
        if UI ~= nil then
            self.tasks[self.id] = {func = fun,time = UI.GetTime() + delay,period = period};
        end
        self.id = self.id + 1;
        return self.id - 1;
    end

    function Timer:cancel(id)
        self.destroyedtasks[#self.destroyedtasks + 1] = id;
    end
   
    function Timer:purge()
        self.tasks = {}
    end

    return Timer;
end)();

Graphics = (function()
    if UI==nil then
        return nil;
    end
    local Graphics = {
        root = {},
        color = {red = 255,green = 255,blue=255,alpha=255},
        opacity = 1
    };
        
    function Graphics:drawRect(x,y,width,height,rect)
        local box = UI.Box.Create();
        if box == nil then
                error("无法绘制矩形:已超过最大限制");
        end
        if rect~=nil then
                if x > rect.x + rect.width then
                    return;
                end
                if y > rect.y + rect.height then
                    return;
                end
                if x + width < rect.x or y + height < rect.y then
                    return;
                end
                if x < rect.x then
                     x = rect.x;
                end
                if y < rect.y then
                     y = rect.y;
                end
                if x + width > rect.x + rect.width then
                    width = rect.x + rect.width - x;
                end
                if y + height > rect.y + rect.height then
                    height = rect.y + rect.height - y;
                end
                box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha * self.opacity});
        else
                box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha * self.opacity});
        end
        box:Show();
        self.root[#self.root+1] = box;
    end
    
    function Graphics:drawText(x,y,size,letterspacing,text,rect)
        local str = {
                array = {},
                length = 0,
                charAt = function(self,index)
                    if index > 0 and index <= self.length then
                        return self.array[index];
                    end
                    error("数组下标越界");    
                end,
        };
        local currentIndex = 1;
        while currentIndex <= #text do
                local cs = 1;
                local seperate = {0, 0xc0, 0xe0, 0xf0};
                for i = #seperate, 1, -1 do
                    if string.byte(text, currentIndex) >= seperate[i] then 
                        cs = i;
                        break;
                    end
                end
                str.array[#str.array+1] = string.sub(text,currentIndex,currentIndex+cs-1);
                currentIndex = currentIndex + cs;
                str.length = str.length + 1;
        end
        for i=1,str.length do
                local char = str:charAt(i)
                if Font[char] == nil then
                    char = '?';
                end
                for j = 1,#Font[char],4 do
                    local x1 = Font[char][j];
                    local y1 = Font[char][j+1];
                    local x2 = Font[char][j+2];
                    local y2 = Font[char][j+3];
                    if i == 1 then
                        self:drawRect(x + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                    else
                        self:drawRect(x + (i-1) * letterspacing + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                    end
                end
        end
    end
    
    function Graphics:getTextSize(text,fontsize,letterspacing)
        if IKit.TypeOf(text) == "string" then
            text = IKit.New("String",text);
        end
        if text.length == 0 then
            return 0,12 * fontsize;
        end
        local width = (text.length - 1) * letterspacing + 11 * fontsize;
        local height = 12 * fontsize;
        return width,height;
    end
    
    function Graphics:clean()
        for i = 1, #self.root, 1 do
            self.root[i] = nil;
        end
        self.root = {};
        collectgarbage("collect");
    end

    return Graphics;
end)();

(function()
    if Game~=nil then
        Event = Event
        + "OnPlayerConnect"
        + "OnPlayerDisconnect"
        + "OnRoundStart"
        + "OnRoundStartFinished"
        + "OnPlayerSpawn"
        + "OnPlayerJoiningSpawn"
        + "OnPlayerKilled"
        + "OnKilled"
        + "OnPlayerSignal"
        + "OnUpdate"
        + "OnPlayerAttack"
        + "OnTakeDamage"
        + "CanBuyWeapon"
        + "CanHaveWeaponInHand"
        + "OnGetWeapon"
        + "OnReload"
        + "OnReloadFinished"
        + "OnSwitchWeapon"
        + "PostFireWeapon"
        + "OnGameSave"
        + "OnLoadGameSave"
        + "OnClearGameSave";

        function Game.Rule:OnPlayerConnect (player)
            Event:run("OnPlayerConnect",player);
        end
    
        function Game.Rule:OnPlayerDisconnect (player)
            Event:run("OnPlayerDisconnect",player);
        end
    
        function Game.Rule:OnRoundStart ()
            Event:run("OnRoundStart");
        end
    
        function Game.Rule:OnRoundStartFinished ()
            Event:run("OnRoundStartFinished");
        end
    
        function Game.Rule:OnPlayerSpawn (player)
            Event:run("OnPlayerSpawn",player);
        end
    
        function Game.Rule:OnPlayerJoiningSpawn (player)
            Event:run("OnPlayerJoiningSpawn",player);
        end
    
        function Game.Rule:OnPlayerKilled (victim, Monster, weapontype, hitbox)
            Event:run("OnPlayerKilled",victim, Monster, weapontype, hitbox);
        end
    
        function Game.Rule:OnKilled (victim, Monster)
            Event:run("OnKilled",victim,Monster);
        end
    
        function Game.Rule:OnPlayerSignal (player,signal)
            Event:run("OnPlayerSignal",player,signal);
        end
    
        function Game.Rule:OnUpdate (time)
            Event:run("OnUpdate",time);
        end
    
        function Game.Rule:OnPlayerAttack (victim, attacker, damage, weapontype, hitbox)
            Event:run("OnPlayerAttack",victim, attacker, damage, weapontype, hitbox);
        end
    
        function Game.Rule:OnTakeDamage (victim, attacker, damage, weapontype, hitbox)	
            Event:run("OnTakeDamage",victim, attacker, damage, weapontype, hitbox);
        end
    
        function Game.Rule:CanBuyWeapon (player, weaponid)
            Event:run("CanBuyWeapon",player,weaponid);
        end
    
        function Game.Rule:CanHaveWeaponInHand (player, weaponid, weapon)
            Event:run("CanHaveWeaponInHand",player, weaponid, weapon);
        end
    
        function Game.Rule:OnGetWeapon (player, weaponid, weapon)
            Event:run("OnGetWeapon",player, weaponid, weapon);
        end
    
        function Game.Rule:OnReload (player, weapon, time)
            Event:run("OnReload",player, weapon, time);
        end
    
        function Game.Rule:OnReloadFinished (player, weapon)
            Event:run("OnReloadFinished",player, weapon);
        end
    
        function Game.Rule:OnSwitchWeapon (player)
            Event:run("OnSwitchWeapon",player);
        end
    
        function Game.Rule:PostFireWeapon (player, weapon, time)
            Event:run("PostFireWeapon",player, weapon, time);
        end
    
        function Game.Rule:OnGameSave (player)
            Event:run("OnGameSave",player);
        end
    
        function Game.Rule:OnLoadGameSave (player)
            Event:run("OnLoadGameSave",player);
        end
    
        function Game.Rule:OnClearGameSave (player)
            Event:run("OnClearGameSave",player);
        end
    end

    if UI~=nil then
        Event = Event
        + "OnRoundStart"
        + "OnSpawn"
        + "OnKilled"
        + "OnInput"
        + "OnUpdate"
        + "OnChat"
        + "OnSignal"
        + "OnKeyDown"
        + "OnKeyUp";
    
        function UI.Event:OnRoundStart()
            Event:run("OnRoundStart");
        end

        function UI.Event:OnSpawn()
            Event:run("OnSpawn");
        end

        function UI.Event:OnKilled()
            Event:run("OnKilled");
        end

        function UI.Event:OnInput (inputs)
            Event:run("OnInput",inputs);
        end

        function UI.Event:OnUpdate(time)
            Event:run("OnUpdate",time);
        end

        function UI.Event:OnChat (text)
            Event:run("OnChat",text);
        end

        function UI.Event:OnSignal(signal)
            Event:run("OnSignal",signal);
        end

        function UI.Event:OnKeyDown(inputs)
            Event:run("OnKeyDown",inputs);
        end

        function UI.Event:OnKeyUp (inputs)
            Event:run("OnKeyUp",inputs);
        end
    end

    Event:addEventListener("OnUpdate",function(time)
        Timer:onUpdate(time);
    end);
end)();

if Game ~= nil then
    local GameState = State.Ready;

    local Players = {};

    local Monster = {
        Players = {},
        SkillsUsed = {},
    };

    local Human = {
        Players = {},
        SkillsUsed = {},
    };

    function SKILL.MONSTER.FATALBLOW:CALL(monster)
        self.MEMORY.Id = self.MEMORY.Id or -1;
        if self.MEMORY.Id == -1 then
            self.MEMORY.Id = Event:addEventListener("OnTakeDamage",function(victim, attacker, damage, weapontype, hitbox)
                if attacker:IsPlayer() and attacker:ToPlayer().name == monster.name then
                    victim.health = 0;
                end
            end);
            Timer:schedule(function()
                Event:detachEventListener(self.MEMORY.Id);
                self.MEMORY.Id = -1;
            end,30);
        end
    end;

    function SKILL.MONSTER.SUPERJUMP:CALL(monster)
        monster.velocity = {
            x = monster.velocity.x,
            y = monster.velocity.y,
            z = monster.velocity.z + self.MEMORY.VALUE * 5,
        };
    end

    function SKILL.MONSTER.GHOSTSTEP:CALL(monster)
        local length = math.sqrt(monster.velocity.x * monster.velocity.x + 
        monster.velocity.y * monster.velocity.y + 
        monster.velocity.z * monster.velocity.z);
        monster.position = {
            x = math.floor(monster.position.x + self.MEMORY.VALUE * self.MEMORY.VALUE / 400 * monster.velocity.x / length),
            y = math.floor(monster.position.y + self.MEMORY.VALUE * self.MEMORY.VALUE / 400 * monster.velocity.y / length),
            z = math.floor(monster.position.z),
        };
        monster.velocity = {
            x = 0,
            y = 0,
            z = 0,
        };
    end;

    function SKILL.MONSTER.LIGHTWEIGHT:CALL(monster)
        local value1 = self.MEMORY.Value;
        local value2 = self.MEMORY.Value;
        self.MEMORY.Id = self.MEMORY.Id or -1;
        if self.MEMORY.Id == -1 then
            self.MEMORY.Id = Event:addEventListener("OnUpdate",function(time)
                    if monster.velocity.z > 0 then
                        monster.velocity = {
                            x = monster.velocity.x,
                            y = monster.velocity.y,
                            z = monster.velocity.z + 1.5 * value2,   
                        };
                        value2 = value2 / 2;
                    else
                        value2 = value1;
                        monster.velocity = {
                            x = monster.velocity.x,
                            y = monster.velocity.y,
                            z = monster.velocity.z * 0.75,
                        };
                    end
            end);
            Timer:schedule(function()
                Event:detachEventListener(self.MEMORY.LightWeight.Id);
                self.MEMORY.LightWeight.Id = -1;
            end,10);
        end
    end

    function SKILL.MONSTER.GRAVITY:CALL(monster)
        
    end

    function SKILL.MONSTER.HITGROUND:CALL(monster)
        for i=1,#Human.Players do
	        local length = (monster.position.x - Human.Players[i].position.x) * (monster.position.x - Human.Players[i].position.x) + 
            (monster.position.y - Human.Players[i].position.y) * (monster.position.y - Human.Players[i].position.y) +
            (monster.position.z - Human.Players[i].position.z) * (monster.position.z - Human.Players[i].position.z);
        end
    end

    local SignalState = NONE;
    Event:addEventListener("OnPlayerSignal",function(player,signal)
        if SignalState == NONE then
            SignalState = signal;
            return;
        end

        for key,value in pairs(SKILL.MONSTER) do
            if SignalState == value.SIGNAL then
                value.MEMORY.VALUE = signal;
                Monster.SkillsUsed[#Monster.SkillsUsed + 1] = {player,value};
                SignalState = NONE;
                return;
            end
        end

        for key,value in pairs(SKILL.HUMAN) do
            if SignalState == value.SIGNAL then
                value.MEMORY.VALUE = signal;
                Human.SkillsUsed[#Human.SkillsUsed + 1] = {player,value};
                SignalState = NONE;
                return;
            end
        end
    end);

    local SyncGameState = Game.SyncValue.Create("游戏状态");

    Event:addEventListener("OnUpdate",function(time)
        SyncGameState.value = GameState;

        if GameState == State.Ready then
            if #Players > 1 then
                GameState = State.Start;

                Monster.Players[#Monster.Players + 1] = Players[1];
                Monster.Players[1].model = Game.MODEL.BLOTTER_ZOMBIE_HOST;
                Monster.Players[1].health = 10000;
                Monster.Players[1].flinch = 0;
                Monster.Players[1].knockback = 0;
                Monster.Players[1]:SetFirstPersonView();

                Monster.Players[1]:Signal(SKILL.WORLD.TOBEMONSTER.SIGNAL);
                Monster.Players[1]:Signal(0);
            end
        elseif GameState == State.Start then
            for i=1,#Monster.SkillsUsed do
	            Monster.SkillsUsed[i][2]:CALL(Monster.SkillsUsed[i][1]);
            end

            for i=1,#Human.SkillsUsed do
	            Human.SkillsUsed[i][2]:CALL(Human.SkillsUsed[i][1]);
            end
            Monster.SkillsUsed = {};
            Human.SkillsUsed = {};
        end
    end);

    Event:addEventListener("OnPlayerJoiningSpawn",function(player)
        Players[#Players + 1] = player;
        player.flinch = 0;
        player.knockback = 0;
        player:SetThirdPersonView(90,90);
    end);

    Event:addEventListener("OnPlayerDisconnect",function(player)
        for i=1,#Players do
            if Players[i] == player then
                table.remove(Players,i)
                break;
            end
        end
    end);

    Event:addEventListener("OnPlayerDisconnect",function(player)
        for i=1,#Players do
            if Players[i] == player then
                table.remove(Players,i)
                break;
            end
        end
    end);

    Event:addEventListener("OnTakeDamage",function(victim, attacker, damage, weapontype, hitbox)
        for i=1,#Monster.Players do
            if attacker.name == Monster.Players[i].name then
                victim.velocity = {
                    x = 700 * (victim.position.x - attacker.position.x),
                    y = 700 * (victim.position.y - attacker.position.y),
                    z = 300,
                };
                attacker.velocity = {
                    x = 0,
                    y = 0,
                    z = 0,
                };
            end
        end
    end);
end

if UI ~= nil then
    local OnInputs = {};
    local InputsOnKeyDown = {};
    local InputsOnKeyUp = {};

    local GameState = "未知";
    local SelfType = "人类";

    local SyncGameState = UI.SyncValue.Create("游戏状态");

    function SKILL.WORLD.TOBEMONSTER:CALL()
        SelfType = "怪物";
    end

    function SKILL.WORLD.TOBEHUMAN:CALL()
        SelfType = "人类";
    end



    function SyncGameState:OnSync()
        GameState = self.value;
    end
    

    local MonsterSkillList = {SKILL.MONSTER.HITGROUND,SKILL.MONSTER.SUPERJUMP,SKILL.MONSTER.GHOSTSTEP};
    local SkillIndex = 1;

    local Bar = 0;

    Event:addEventListener("OnUpdate",function(time)
        Graphics:clean();
        if GameState == State.Ready then
            Graphics.color = {red = 255,green = 255,blue=255,alpha=255};
            Graphics:drawText(40,25,2,30,"等待开始");
        elseif GameState == State.Start then
            if SelfType == "怪物" then
                Graphics.color = {red = 25,green = 25,blue=25,alpha=255};
                Graphics:drawRect(36,30,120,24);
                Graphics.color = {red = 222,green = 222,blue=222,alpha=255};
                if MonsterSkillList[SkillIndex].ISFREEZE == false then
                    Graphics:drawText(40,30,2,30,MonsterSkillList[SkillIndex].NAME);
                else
                    Graphics.color = {red = 222,green = 30,blue=30,alpha=255};
                    Graphics:drawText(40,30,2,30,MonsterSkillList[SkillIndex].NAME);
                end
                if OnInputs[UI.KEY.NUM1] == true then
                    SkillIndex = 1;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM2] == true then
                    SkillIndex = 2;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM3] == true then
                    SkillIndex = 3;
                    Bar = 0;
                end
                if MonsterSkillList[SkillIndex].ISFREEZE == false then
                    if OnInputs[UI.KEY.SHIFT] == true then
                        Graphics.color = {red = 25,green = 25,blue=25,alpha=255};
                        Graphics:drawRect(18,28,14,102);
                        Graphics.color = {red = 255,green = 255,blue=255,alpha=255};
                        Graphics:drawRect(20,30,10,Bar);
                        if Bar < 100 then
                            Bar = Bar + 1;
                        else
                        
                        end
                    elseif InputsOnKeyUp[UI.KEY.SHIFT] == true then
                        UI.Signal(MonsterSkillList[SkillIndex].SIGNAL);
                        UI.Signal(Bar);

                        Bar = 0;
                        MonsterSkillList[SkillIndex].ISFREEZE = true;
                        local i = SkillIndex;
                        Timer:schedule(function()
                            MonsterSkillList[i].ISFREEZE = false;
                            print(MonsterSkillList[i].NAME,"冷却完成")
                        end,MonsterSkillList[i].COOLDOWNTIME);
                    end
                end
            elseif SelfType == "人类" then
                
            end
        end
    end);

    Event:addEventListener("OnUpdate",function(time)
        OnInputs = {};
        InputsOnKeyDown = {};
        InputsOnKeyUp = {};
    end);

    local SignalState = NONE;
    Event:addEventListener("OnSignal",function(signal)
        if SignalState == NONE then
            SignalState = signal;
            return;
        end

        for key,value in pairs(SKILL.WORLD) do
            if SignalState == value.SIGNAL then
                value.MEMORY.VALUE = signal;
                value:CALL();
                SignalState = NONE;
                return;
            end
        end
    end);

    Event:addEventListener("OnInput",function(inputs)
        OnInputs = inputs;
    end);

    Event:addEventListener("OnKeyDown",function(inputs)
        InputsOnKeyDown = inputs;
    end);

    Event:addEventListener("OnKeyUp",function(inputs)
        InputsOnKeyUp = inputs;
    end);

end




