local SIGNAL_NONE = 0;
local SIGNAL_MONSTER_SKILL = {
	FATALBLOW = 111,
    SUPERJUMP = 112,
    GHOSTSTEP = 113,
};
local SIGNAL_HUMAN_SKILL = {
	
};

local Event = (function()
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
    
    
    function Event:detachEventListener(name,id)
        if self.array[name] == nil then
            error("未找到'" .. name .. "'");
        end
        for i = 1, #self.array[name],1 do
            if self.array[name][i][1] == id then
                table.remove(self.array[name],i);
                return;
            end
        end
        error("未找到'" .. id .. "'在Event[" .. name .."]内");
    end

    function Event:run(name,...)
        for i = #self.array[name],1,-1 do
            self.array[name][i][2](...);
        end
    end
    Event.__index = Event;

    return setmetatable({},Event);
end)();

local Timer = (function()
    local Timer = {
        id = 1,
        tasks = {},
        destroyedtasks = {}
    };

    function Timer:OnUpdate(time)
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

local Graphics = (function()
    if UI~=nil then
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
            for i=1,text.length do
                local char = text:charAt(i)
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
        Timer:OnUpdate(time);
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
        SkillsMemory = {},
        LastPosition = {x = 0,y = 0,z = 0},
    };
    Monster.Skills = {
        FatalBlow = function()
            
		end,
        SuperJump = function()
            Monster.Player.velocity = {
                x = Monster.Player.velocity.x,
                y = Monster.Player.velocity.y,
                z = Monster.Player.velocity.z + 300,
            };
		end,
        GhostStep = function()
            local length = math.sqrt(Monster.Player.velocity.x * Monster.Player.velocity.x + 
            Monster.Player.velocity.y * Monster.Player.velocity.y + 
            Monster.Player.velocity.z * Monster.Player.velocity.z);
            Monster.Player.position = {
                x = math.floor(Monster.Player.position.x + 10 * Monster.Player.velocity.x / length),
                y = math.floor(Monster.Player.position.y + 10 * Monster.Player.velocity.y / length),
                z = math.floor(Monster.Player.position.z + 10 * Monster.Player.velocity.z / length),
            };
        end,
    }
    local SyncMonsterIndex = Game.SyncValue.Create("怪物Index");
    local SyncMonsterName = Game.SyncValue.Create("怪物名称");
    local SyncMonsterHealth = Game.SyncValue.Create("怪物血量");

    local SignalState = SIGNAL_NONE;
    Event:addEventListener("OnPlayerSignal",function(player,signal)
        if SignalState == SIGNAL_NONE then
            Monster.SkillsUsed = signal;
            SignalState = signal;
        end
        if SignalState == SIGNAL_MONSTER_SKILL.FATALBLOW then
            SignalState = SIGNAL_NONE;
        elseif SignalState == SIGNAL_MONSTER_SKILL.SUPERJUMP then
            SignalState = SIGNAL_NONE;
        elseif SignalState == SIGNAL_MONSTER_SKILL.GHOSTSTEP then
            SignalState = SIGNAL_NONE;
        end
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
    
    Event:addEventListener("OnUpdate",function(time)

    end);

    Event:addEventListener("OnKeyDown",function(inputs)
        if MonsterIndex == UI.PlayerIndex() then
            if inputs[UI.KEY.SPACE] == true then
                UI.Signal(SIGNAL_MONSTER_SKILL.SUPERJUMP);
            end
            if inputs[UI.KEY.MOUSE2] == true then
                UI.Signal(SIGNAL_MONSTER_SKILL.GHOSTSTEP);
            end
        end
    end);
end