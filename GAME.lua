function Game.Rule:OnPlayerConnect(player)

end


function Game.Rule:OnRoundStartFinished()
	print(Game.Weapon.CreateAndDrop(Common.WEAPON.M134Minigun, {x=46,y=20,z=8}));
end

