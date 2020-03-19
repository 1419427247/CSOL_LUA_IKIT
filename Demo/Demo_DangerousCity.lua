local SIGNAL_NONE = 0;
local SIGNAL_MONSTER_SKILL = {
	FATALBLOW = 111, -- 致命打击
    SUPERJUMP = 112, -- 火箭跳跃
    GHOSTSTEP = 113, -- 鬼影步
    LIGHTWEIGHT = 114, -- 轻如鸿毛
    GRAVITY = 115, -- 地心引力
    HITGROUND = 116, -- 撼地一击
    LISTEN = 117, -- 聆听
};
local SIGNAL_HUMAN_SKILL = {
	STEEL = 211, -- 铜头铁臂
    SPRINTBURST = 212, -- 冲刺爆发
    CURE = 213, -- 自我愈合
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
        Font = {};
        Font["a"]={0,0,2,8,4,0,6,8,2,2,4,4,2,8,4,10};
        Font["b"]={0,0,2,10,2,0,4,2,2,4,4,6,2,8,4,10,4,2,6,4,4,6,6,8};
        Font["c"]={0,2,2,8,2,0,6,2,2,8,6,10};
        Font["d"]={0,0,2,10,2,0,4,2,2,8,4,10,4,2,6,8};
        Font["e"]={0,2,2,8,2,0,6,2,2,4,6,6,2,8,6,10};
        Font["f"]={0,0,2,8,2,4,6,6,2,8,6,10};
        Font["g"]={0,2,2,8,2,0,4,2,4,0,6,6,2,8,6,10};
        Font["h"]={0,0,2,10,4,0,6,10,2,4,4,6};
        Font["i"]={2,0,4,10};
        Font["j"]={0,2,2,6,2,0,4,2,4,2,6,10};
        Font["k"]={0,0,2,10,4,0,6,4,4,6,6,10,2,4,4,6};
        Font["l"]={0,2,2,10,2,0,6,2};
        Font["m"]={0,0,2,10,4,0,6,10,2,6,4,8};
        Font["n"]={0,0,2,10,2,8,4,10,4,0,6,8};
        Font["o"]={0,2,2,8,4,2,6,8,2,0,4,2,2,8,4,10};
        Font["p"]={0,0,2,8,2,2,4,4,2,8,4,10,4,4,6,8};
        Font["q"]={0,4,2,8,4,4,6,8,2,0,4,4,2,8,4,10};
        Font["r"]={0,0,2,8,2,2,4,4,2,8,4,10,4,4,6,8,4,0,6,2};
        Font["s"]={0,0,4,2,4,2,6,4,2,4,4,6,0,6,2,8,2,8,6,10};
        Font["t"]={0,8,6,10,2,0,4,8};
        Font["u"]={0,0,2,10,2,0,4,2,4,2,6,10};
        Font["v"]={0,2,2,10,2,0,4,2,4,2,6,10};
        Font["w"]={0,0,2,10,4,0,6,10,2,2,4,4};
        Font["x"]={0,0,2,4,0,6,2,10,4,0,6,4,4,6,6,10,2,4,4,6};
        Font["y"]={0,6,2,10,4,6,6,10,2,0,4,6};
        Font["z"]={0,0,6,2,0,8,6,10,0,2,2,4,2,4,4,6,4,6,6,8};

        Font["A"]={0,0,2,8,4,0,6,8,2,2,4,4,2,8,4,10};
        Font["B"]={0,0,2,10,2,0,4,2,2,4,4,6,2,8,4,10,4,2,6,4,4,6,6,8};
        Font["C"]={0,2,2,8,2,0,6,2,2,8,6,10};
        Font["D"]={0,0,2,10,2,0,4,2,2,8,4,10,4,2,6,8};
        Font["E"]={0,2,2,8,2,0,6,2,2,4,6,6,2,8,6,10};
        Font["F"]={0,0,2,8,2,4,6,6,2,8,6,10};
        Font["G"]={0,2,2,8,2,0,4,2,4,0,6,6,2,8,6,10};
        Font["H"]={0,0,2,10,4,0,6,10,2,4,4,6};
        Font["I"]={2,0,4,10};
        Font["J"]={0,2,2,6,2,0,4,2,4,2,6,10};
        Font["K"]={0,0,2,10,4,0,6,4,4,6,6,10,2,4,4,6};
        Font["L"]={0,2,2,10,2,0,6,2};
        Font["M"]={0,0,2,10,4,0,6,10,2,6,4,8};
        Font["N"]={0,0,2,10,2,8,4,10,4,0,6,8};
        Font["O"]={0,2,2,8,4,2,6,8,2,0,4,2,2,8,4,10};
        Font["P"]={0,0,2,8,2,2,4,4,2,8,4,10,4,4,6,8};
        Font["Q"]={0,4,2,8,4,4,6,8,2,0,4,4,2,8,4,10};
        Font["R"]={0,0,2,8,2,2,4,4,2,8,4,10,4,4,6,8,4,0,6,2};
        Font["S"]={0,0,4,2,4,2,6,4,2,4,4,6,0,6,2,8,2,8,6,10};
        Font["T"]={0,8,6,10,2,0,4,8};
        Font["U"]={0,0,2,10,2,0,4,2,4,2,6,10};
        Font["V"]={0,2,2,10,2,0,4,2,4,2,6,10};
        Font["W"]={0,0,2,10,4,0,6,10,2,2,4,4};
        Font["X"]={0,0,2,4,0,6,2,10,4,0,6,4,4,6,6,10,2,4,4,6};
        Font["Y"]={0,6,2,10,4,6,6,10,2,0,4,6};
        Font["Z"]={0,0,6,2,0,8,6,10,0,2,2,4,2,4,4,6,4,6,6,8};

        Font["0"]={3,0,5,10,7,0,9,10,5,0,7,2,5,8,7,10};
        Font["1"]={5,0,7,10,3,6,5,8};
        Font["2"]={3,0,5,6,7,4,9,10,5,0,9,2,5,4,7,6,3,8,7,10};
        Font["3"]={7,0,9,10,3,0,7,2,3,4,7,6,3,8,7,10};
        Font["4"]={3,4,5,10,7,0,9,10,5,4,7,6};
        Font["5"]={3,4,5,10,3,0,9,2,5,4,9,6,5,8,9,10,7,2,9,4};
        Font["6"]={3,0,5,10,5,0,9,2,5,4,9,6,5,8,9,10,7,2,9,4};
        Font["7"]={3,8,9,10,7,0,9,8};
        Font["8"]={3,0,5,10,7,0,9,10,5,0,7,2,5,4,7,6,5,8,7,10};
        Font["9"]={3,0,9,2,7,2,9,10,3,4,5,10,5,4,7,6,5,8,7,10};
        Font["<"]={7,0,9,2,5,2,7,4,3,4,5,6,5,6,7,8,7,8,9,10};
        Font[">"]={3,0,5,2,5,2,7,4,7,4,9,6,3,8,5,10,5,6,7,8};
        Font[":"]={5,2,7,4,5,6,7,8};
        Font["?"]={5,0,7,2,5,4,7,6,7,4,9,10,3,8,7,10};
        Font["!"]={5,0,7,2,5,4,7,10};
        Font["+"]={5,2,7,8,3,4,9,6};
        Font[","]={5,0,7,2};
        Font["-"]={3,4,9,6};
        Font["."]={5,0,7,2};
        Font["'"]={5,6,7,10};
        Font["("]={3,2,5,8,5,0,7,2,5,8,7,10};
        Font[")"]={7,2,9,8,5,0,7,2,5,8,7,10};
        Font["\\"]={3,6,5,10,5,4,7,6,7,0,9,4};
        Font["/"]={3,0,5,4,5,4,7,6,7,6,9,10};

        Font["▶"] = {3,0,5,10,5,2,7,8,7,4,9,6};
        Font["◀"] = {3,4,5,6,7,8,5,2,7,10,9,0};

        Font[" "] = {};

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


if Game~=nil then
    local State = {
        Ready = 1,
        Start = 2,
    };

    local GameState = State.Ready;

    local Players = {};

    local Monster = {
        Player = { name = "" },
        SkillsUsed = SIGNAL_NONE,
        SkillsMemory = {
            SuperJump = 10,
            GhostStep = 100,
            LightWeight = {
                Id = -1,
                Value = 0,
            },
        },
    };
    Monster.Skills = {
        FatalBlow = function()
            Event:addEventListener()
		end,
        SuperJump = function()
            Monster.Player.velocity = {
                x = Monster.Player.velocity.x,
                y = Monster.Player.velocity.y,
                z = Monster.Player.velocity.z + Monster.SkillsMemory.SuperJump * 10,
            };
		end,
        GhostStep = function()
            local length = math.sqrt(Monster.Player.velocity.x * Monster.Player.velocity.x + 
            Monster.Player.velocity.y * Monster.Player.velocity.y + 
            Monster.Player.velocity.z * Monster.Player.velocity.z);
            Monster.Player.position = {
                x = math.floor(Monster.Player.position.x + Monster.SkillsMemory.GhostStep * Monster.SkillsMemory.GhostStep / 400 * Monster.Player.velocity.x / length),
                y = math.floor(Monster.Player.position.y + Monster.SkillsMemory.GhostStep * Monster.SkillsMemory.GhostStep / 400 * Monster.Player.velocity.y / length),
                z = math.floor(Monster.Player.position.z),
            };
        end,
        LightWeight = function() 
            local value1 = Monster.SkillsMemory.LightWeight.Value;
            local value2 = Monster.SkillsMemory.LightWeight.Value;
            if Monster.SkillsMemory.LightWeight.Id == -1 then
                Monster.SkillsMemory.LightWeight.Id = Event:addEventListener("OnUpdate",function(time)
                    if Monster.Player.velocity.z > 0 then
                        Monster.Player.velocity = {
                            x = Monster.Player.velocity.x,
                            y = Monster.Player.velocity.y,
                            z = Monster.Player.velocity.z + 1.5 * value2,
                        };
                        value2 = value2 / 2;
                    else
                        value2 = value1;
                        Monster.Player.velocity = {
                            x = Monster.Player.velocity.x,
                            y = Monster.Player.velocity.y,
                            z = Monster.Player.velocity.z * 0.75,
                        };
                    end
                end);
                Timer:schedule(function()
                    Event:detachEventListener(Monster.SkillsMemory.LightWeight.Id);
                    Monster.SkillsMemory.LightWeight.Id = -1;
                end,10);
            end
        end
    }
    local SyncMonsterIndex = Game.SyncValue.Create("怪物Index");
    local SyncMonsterName = Game.SyncValue.Create("怪物名称");
    local SyncMonsterHealth = Game.SyncValue.Create("怪物血量");

    local SignalState = SIGNAL_NONE;
    Event:addEventListener("OnPlayerSignal",function(player,signal)
        if SignalState == SIGNAL_NONE then
            SignalState = signal;
            if SignalState == SIGNAL_MONSTER_SKILL.FATALBLOW then
                Monster.SkillsUsed = SignalState;
                SignalState = SIGNAL_NONE;
            end
            return;
        end
        if SignalState == SIGNAL_MONSTER_SKILL.SUPERJUMP then
            Monster.SkillsMemory.SuperJump = signal;
        elseif SignalState == SIGNAL_MONSTER_SKILL.GHOSTSTEP then
            Monster.SkillsMemory.GhostStep = signal;
        elseif SignalState == SIGNAL_MONSTER_SKILL.LIGHTWEIGHT then
            Monster.SkillsMemory.LightWeight.Value = signal;
        end
        Monster.SkillsUsed = SignalState;
        SignalState = SIGNAL_NONE;
    end);

    Event:addEventListener("OnUpdate",function(time)
        if GameState == State.Ready then
            Monster.Player = Players[1];
            if Monster.Player ~= nil then
                GameState = State.Start;
                Monster.Player.model = Game.MODEL.DEIMOS_ZOMBIE;
                Monster.Player.health = 10000;
                SyncMonsterIndex.value = Monster.Player.index;
                SyncMonsterName.value = Monster.Player.name;
            end
        elseif GameState == State.Start then
            SyncMonsterHealth.value = Monster.Player.health;

            if Monster.SkillsUsed == SIGNAL_MONSTER_SKILL.FATALBLOW then 
                Monster.Skills.FatalBlow();
            elseif Monster.SkillsUsed == SIGNAL_MONSTER_SKILL.SUPERJUMP then
                Monster.Skills.SuperJump();
            elseif Monster.SkillsUsed == SIGNAL_MONSTER_SKILL.GHOSTSTEP then
                Monster.Skills.GhostStep();
            elseif Monster.SkillsUsed == SIGNAL_MONSTER_SKILL.LIGHTWEIGHT then
                Monster.Skills.LightWeight();
            end
            Monster.SkillsUsed = SIGNAL_NONE;
        end
    end);

    Event:addEventListener("OnPlayerConnect",function(player)
        Players[#Players + 1] = player;
    end);

    Event:addEventListener("OnPlayerDisconnect",function(player)
        for i=1,#Players do
            if Players[i] == player then
                table.remove(Players,i)
                break;
            end
        end
    end);

end

if UI~=nil then
    local OnInputs = {};

    local InputsOnKeyDown = {};
    local InputsOnKeyUp = {};

    local MonsterName = "未知";
    local MonsterHealth = "未知";
    local MonsterIndex = "未知";

    local SyncMonsterIndex = UI.SyncValue.Create("怪物Index");
    local SyncMonsterName = UI.SyncValue.Create("怪物名称");
    local SyncMonsterHealth = UI.SyncValue.Create("怪物血量");

    function SyncMonsterIndex:OnSync()
        MonsterIndex = self.value;
    end

    function SyncMonsterName:OnSync()
        MonsterName = self.value;
    end

    function SyncMonsterHealth:OnSync()
        MonsterHealth = self.value;
    end
    

    local SkillList = {};
    local CoolingTime = 15;
    local Bar = 0;

    Event:addEventListener("OnUpdate",function(time)
        if MonsterIndex == UI.PlayerIndex() then
            if OnInputs[UI.KEY.SHIFT] == true then
                if Bar < 100 then
                    Bar = Bar + 1;
                    Graphics:clean();
                    Graphics.color = {red = 25,green = 25,blue=25,alpha=255};
                    Graphics:drawRect(18,18,14,102);
                    Graphics.color = {red = 255,green = 255,blue=255,alpha=255};
                    Graphics:drawRect(20,20,10,Bar);
                else
                    
                end
            elseif InputsOnKeyUp[UI.KEY.SHIFT] == true then
                UI.Signal(SIGNAL_MONSTER_SKILL.LIGHTWEIGHT);
                UI.Signal(Bar);
                Graphics:clean();
                Bar = 0;
                --UI.Signal(SIGNAL_MONSTER_SKILL.GHOSTSTEP);
            end
        else
            
        end
        OnInputs = {};
        InputsOnKeyDown = {};
        InputsOnKeyUp = {};
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