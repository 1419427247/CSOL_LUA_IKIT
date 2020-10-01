if Game~=nil then
    Class("ZombieEscape",function(ZombieEscape)
        local Status = {
            Ready = 0,
            Run = 1,
            End = 2,
        };
        function ZombieEscape:constructor(recordPointNumber)
            self.index = 0;
            self.recordPointNumber = recordPointNumber;
            self.destinationEntityBlocks = NULL;
            self.status = Status.Ready;

            self.recordPoints = Game.SyncValue:Create("ZombieEscape_recordPoints");
            self.allCTPositions = Game.SyncValue:Create("ZombieEscape_allCTPositions");
            self.allTRPositions = Game.SyncValue:Create("ZombieEscape_allTRPositions");

            self.recordPoints.value = recordPointNumber;
            
            Event:addEventListener(Event.OnPlayerConnect,function(player)
                player.user.ZombieEscape = {};
            end);
            Event:addEventListener(Event.OnPlayerSpawn,function(player)
                player.position = player.user.ZombieEscape.archivePoint or player.position;
            end);
            Event:addEventListener(Event.OnPlayerAttack,function(victim,attacker,damage,weapontype,hitbox)
                if attacker == nil then
                    return;
                end
                if attacker:IsPlayer() and victim:IsPlayer() then
                    attacker = attacker:ToPlayer();
                    victim = attacker:ToPlayer();
                else
                    return;
                end
                if attacker.team == Game.TEAM.TR and victim.team == Game.Team.CT then
                    victim.team = Game.TEAM.TR;
                    victim.model = Game.MODEL.NORMAL_ZOMBIE;
                end
            end);

            Timer:schedule(function()
                local ct = {};
                local tr = {};

                for __,player in pairs(NetServer.players) do
                    if player.team == Game.TEAM.CT then
                        ct[#ct+1] = player.user.ZombieEscape.index or 0;
                    else
                        tr[#tr+1] = player.user.ZombieEscape.index or 0;
                    end
                end
                self.allCTPositions.value = table.concat(ct," ");
                self.allTRPositions.value = table.concat(tr," ");
            end,0,5);
        end
    
        function ZombieEscape:CreateRecordPoint(entityBlock)
            self.index = self.index + 1;
            local index = self.index;
            if self.index == self.recordPointNumber then
                self.destinationEntityBlocks = entityBlock;
                self.destinationEntityBlocks.OnTouch = function(self,player)
                    player.user.ZombieEscape.index = index;
                    player.user.ZombieEscape.archivePoint = entityBlock.position;
                    Game.SetTrigger("GameOver",true);
                end
            else
                entityBlock.OnTouch = function(self,player)
                    player.user.ZombieEscape.index = index;
                    player.user.ZombieEscape.archivePoint = entityBlock.position;
                end
            end
        end
    



        function ZombieEscape:startNewGame()
    
        end
    end);


    NetServer = NetServer:New();

    ZombieEscape = ZombieEscape:New(20);

    function CreateRecordPoint(__,args)
        if args == nil then
            local entity =  Game.GetScriptCaller();

            local entityBlock;
            for i = -1,1 do
                if i ~= 0 then 
                    entityBlock = entityBlock or Game.EntityBlock:Create({x = entity.position.x + i,y = entity.position.y,z = entity.position.z});
                    entityBlock = entityBlock or Game.EntityBlock:Create({x = entity.position.x,y = entity.position.y + i,z = entity.position.z});
                    entityBlock = entityBlock or Game.EntityBlock:Create({x = entity.position.x,y = entity.position.y,z = entity.position.z + i});
                end
            end
            ZombieEscape:CreateRecordPoint(entityBlock);
        else
            local iterator = string.gmatch(args,"-*%d+");
            local x,y,z = tonumber(iterator()),tonumber(iterator()),tonumber(iterator());
            local entityBlock = Game.EntityBlock:Create({x = x,y = y,z = z})
            ZombieEscape:CreateRecordPoint(entityBlock);
        end
    end
end

if UI ~= nil then

    Class("Scoreboard",function(Scoreboard)
        function Scoreboard:constructor()
            self.super(0,0,400,140);
            self.style.backgroundcolor = {255,255,255,160};
            self.style.border = {1,1,1,1};


            self:repaint();
            local id = Timer:schedule(function()
                self:repaint();
            end,300,5);

            Timer:schedule(function()
                Timer:cancel(id);
                self:clear();
            end,800);
        end

        function Scoreboard:paint()
            self.super:paint();
            Song.size = 3;
            Graphics:drawText(self,self.x,self.y,Song,"总回合:"..45,{0,0,self.width,self.height});
            Graphics:drawText(self,self.x,self.y + 40,Song,"僵尸胜利:"..123,{0,0,self.width,self.height});
            Graphics:drawText(self,self.x,self.y + 80,Song,"人类胜利:"..44,{0,0,self.width,self.height});
        end

        function Scoreboard:repaint()
            self.width = self.width - 5;
            self:clear();
            self:paint();
        end

    end,Component);

    Class("PoisitionBar",function(PoisitionBar)
        function PoisitionBar:constructor(positionPoints)
            self.super(Graphics.width*0.1,Graphics.height*0.2,Graphics.width * 0.8,Graphics.height*0.01);
            self.style.border = {1,1,1,1};

            self.recordPoints = 20;
            self.ctPositionPoints = {};
            self.trPositionPoints = {};
        end

        function PoisitionBar:paint()
            self:clear();
            self.super:paint();

            local space = self.width / self.recordPoints;

            local x = 0;
            Graphics.color = {0,0,0,255};
            for i = 1, self.recordPoints/2 do
                Graphics:drawRect(self,self.x + x,self.y,space,self.height);
                x = x + 2 * space;
            end

            Graphics.color = {0,0,255,255};
            for i = 1,#self.ctPositionPoints do
                Graphics:drawRect(self,self.x + space * self.ctPositionPoints[i] + space * ((i - 1) / self.recordPoints),self.y,space / 5,self.height + 20);
            end

            for i = 1,#self.trPositionPoints do
                Graphics.color = {255,0,0,255};
                Graphics:drawRect(self,self.x + space * self.trPositionPoints[i] + space * ((i - 1) / self.recordPoints),self.y,space / 5,-(self.height + 20));

            end
        end

        function PoisitionBar:repaint(recordPoints,ctPositionPoints,trPositionPoints)
            self.recordPoints = recordPoints;
            self.ctPositionPoints = ctPositionPoints;
            self.trPositionPoints = trPositionPoints;
            self:clear();
            self:paint();
        end

    end,Component);


    Class("ZombieEscape",function(ZombieEscape)
        local Status = {
            Ready = 0,
            Run = 1,
            End = 2,
        };
        function ZombieEscape:constructor(maxIndex)
            self.recordPoints = UI.SyncValue:Create("ZombieEscape_recordPoints");
            self.allCTPositions = UI.SyncValue:Create("ZombieEscape_allCTPositions");
            self.allTRPositions = UI.SyncValue:Create("ZombieEscape_allTRPositions");
            
            self.poisitionBar = PoisitionBar:New();
            self.scoreboard = Scoreboard:New();

            
            Timer:schedule(function()
                local ctp = {};
                local trp = {};

                local iterator = string.gmatch(self.allCTPositions.value or "","%d+");
                for value in iterator do
                    ctp[#ctp+1] = tonumber(value);
                end

                iterator = string.gmatch(self.allTRPositions.value or "","%d+");
                for value in iterator do
                    trp[#trp+1] = tonumber(value);
                end
                self.poisitionBar:repaint(self.recordPoints.value,ctp,trp);

            end,0,99);
        end
    end);

    NetClient = NetClient:New();
    ZombieEscape = ZombieEscape:New();
end

