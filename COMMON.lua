Common.UseWeaponInven(true) -- 무기 인벤토리 기능 사용
Common.SetSaveCurrentWeapons(true) -- 현재 장착중인 무기들을 저장하도록 설정
Common.SetSaveWeaponInven(true) -- 무기 인벤토리 내용을 저장하도록 설정(UseWeaponInven이 먼저 설정되어 있어야한다)
Common.SetAutoLoad(true) -- 저장정보 불러오기를 자동으로 수행한다
Common.DisableWeaponParts(true) -- 웨폰파츠 기능 비활성
Common.DisableWeaponEnhance(true) -- 무기강화 기능 비활성
Common.DontGiveDefaultItems(true) -- 게임시작시 기본무기를 지급하지 않게
Common.DontCheckTeamKill(true) -- 팀킬을해도 정상킬로 처리하게끔
Common.UseScenarioBuymenu(true) -- 상점을 시나리오 상점창을 사용하게
Common.SetNeedMoney(true) -- 총을 구매할때 돈이 필요하도록
Common.UseAdvancedMuzzle(true) -- 발사시 muzzle을 새로운 형태로 그린다(scale 무시)
Common.SetMuzzleScale(1.0) -- 발사시 muzzle 크기 수정
Common.SetBloodScale(2) -- 피격시 피 이펙트 크기 수정
Common.SetGunsparkScale(10) -- 총알이 벽 등에 맞았을 경우 이펙트 크기 수정
Common.SetHitboxScale(2.5) -- 히트박스 크기 수정
Common.SetMouseoverOutline(true, {r = 255, g = 0, b = 0}) -- 몬스터 등의 엔티티에 마우스오버를 할 경우 외곽선이 보이게
Common.SetUnitedPrimaryAmmoPrice(50) -- 모든 주무기의 탄창 한개당 가격을 이 값으로 통일한다
Common.SetUnitedSecondaryAmmoPrice(0) -- 모든 보조무기의 탄창 한개당 가격을 이 값으로 통일한다


--[[ 공통 상수 선언 ]]


-- 실수값 비교시 사용
EPSILON = 0.00001

-- UI에서 Game으로 보내는 Signal
SignalToGame = {
	openWeaponInven = 1,
}

-- Game에서 UI로 보내는 Signal
SignalToUI = {
	reloadStarted = 1,
	reloadFinished = 2
}

-- 게임에서 쓰일 무기 등급
WeaponGrade = {
	normal = 1,
	rare = 2,
	unique = 3,
	legend = 4,
	END = 4
}

-- 상점 무기 리스트
BuymenuWeaponList =	{
	Common.WEAPON.P228,
	Common.WEAPON.DualBeretta,
	Common.WEAPON.FiveSeven,
	Common.WEAPON.Glock18C,
	Common.WEAPON.USP45,
	Common.WEAPON.DesertEagle50C,
	Common.WEAPON.DualInfinity,
	Common.WEAPON.Galil,
	Common.WEAPON.FAMAS,
	Common.WEAPON.M4A1,
	Common.WEAPON.AK47,
	Common.WEAPON.OICW,
	Common.WEAPON.MAC10,
	Common.WEAPON.UMP45,
	Common.WEAPON.MP5,
	Common.WEAPON.TMP,
	Common.WEAPON.P90,
	Common.WEAPON.MP7A1ExtendedMag,
	Common.WEAPON.Needler,
	Common.WEAPON.M3,
	Common.WEAPON.XM1014,
	Common.WEAPON.DoubleBarrelShotgun,
	Common.WEAPON.WinchesterM1887,
	Common.WEAPON.USAS12,
	Common.WEAPON.FireVulcan,
	Common.WEAPON.M249,
	Common.WEAPON.MG3,
	Common.WEAPON.M134Minigun,
	Common.WEAPON.K3,
	Common.WEAPON.QBB95,
	Common.WEAPON.M32MGL,
	Common.WEAPON.Leviathan,
	Common.WEAPON.Salamander,
	Common.WEAPON.RPG7
}

-- 상점 무기 리스트 설정 (UseScenarioBuymenu 설정 필요)
Common.SetBuymenuWeaponList(BuymenuWeaponList)

-- 게임에서 쓰일 모든 무기 리스트
WeaponList = {
	-- 보조무기 리스트
	Common.WEAPON.P228,
	Common.WEAPON.DualBeretta,
	Common.WEAPON.FiveSeven,
	Common.WEAPON.Glock18C,
	Common.WEAPON.USP45,
	Common.WEAPON.DesertEagle50C,
	Common.WEAPON.DualInfinity,
	Common.WEAPON.DualInfinityCustom,
	Common.WEAPON.DualInfinityFinal,
	Common.WEAPON.SawedOffM79,
	Common.WEAPON.Cyclone,
	Common.WEAPON.AttackM950,
	Common.WEAPON.DesertEagle50CGold,
	Common.WEAPON.ThunderGhostWalker,
	Common.WEAPON.PythonDesperado,
	Common.WEAPON.DesertEagleCrimsonHunter,
	Common.WEAPON.DualBerettaGunslinger,
	-- 소총 리스트
	Common.WEAPON.Galil,
	Common.WEAPON.FAMAS,
	Common.WEAPON.M4A1,
	Common.WEAPON.SG552,
	Common.WEAPON.AK47,
	Common.WEAPON.AUG,
	Common.WEAPON.AN94,
	Common.WEAPON.M16A4,
	Common.WEAPON.AK47Custom,
	Common.WEAPON.HK416,
	Common.WEAPON.AK74U,
	Common.WEAPON.AKM,
	Common.WEAPON.L85A2,
	Common.WEAPON.FNFNC,
	Common.WEAPON.TAR21,
	Common.WEAPON.SCAR,
	Common.WEAPON.SKULL4,
	Common.WEAPON.OICW,
	Common.WEAPON.PlasmaGun,
	Common.WEAPON.StunRifle,
	Common.WEAPON.StarChaserAR,
	Common.WEAPON.CompoundBow,
	Common.WEAPON.LightningAR2,
	Common.WEAPON.Ethereal,
	Common.WEAPON.LightningAR1,
	Common.WEAPON.F2000,
	Common.WEAPON.Crossbow,
	Common.WEAPON.CrossbowAdvance,
	Common.WEAPON.M4A1DarkKnight,
	Common.WEAPON.AK47Paladin,
	-- 기관단총 리스트
	Common.WEAPON.MAC10,
	Common.WEAPON.UMP45,
	Common.WEAPON.MP5,
	Common.WEAPON.TMP,
	Common.WEAPON.P90,
	Common.WEAPON.MP7A1ExtendedMag,
	Common.WEAPON.DualKriss,
	Common.WEAPON.KrissSuperV,
	Common.WEAPON.DualMP7A1,
	Common.WEAPON.Tempest,
	Common.WEAPON.TMPDragon,
	Common.WEAPON.P90Lapin,
	Common.WEAPON.DualUZI,
	Common.WEAPON.Needler,
	Common.WEAPON.InfinityLaserFist,
	-- 샷건 리스트
	Common.WEAPON.M3,
	Common.WEAPON.XM1014,
	Common.WEAPON.DoubleBarrelShotgun,
	Common.WEAPON.WinchesterM1887,
	Common.WEAPON.USAS12,
	Common.WEAPON.JackHammer,
	Common.WEAPON.TripleBarrelShotgun,
	Common.WEAPON.SPAS12Maverick,
	Common.WEAPON.FireVulcan,
	Common.WEAPON.BALROGXI,
	Common.WEAPON.BOUNCER,
	Common.WEAPON.FlameJackhammer,
	Common.WEAPON.RailCannon,
	Common.WEAPON.LightningSG1,
	Common.WEAPON.USAS12CAMO,
	Common.WEAPON.WinchesterM1887Gold,
	Common.WEAPON.UTS15PinkGold,
	Common.WEAPON.Volcano,
	-- 기관총 리스트
	Common.WEAPON.M249,
	Common.WEAPON.MG3,
	Common.WEAPON.M134Minigun,
	Common.WEAPON.MG36,
	Common.WEAPON.MK48,
	Common.WEAPON.K3,
	Common.WEAPON.QBB95,
	Common.WEAPON.QBB95AdditionalMag,
	Common.WEAPON.BALROGVII,
	Common.WEAPON.MG3CSOGSEdition,
	Common.WEAPON.CHARGER7,
	Common.WEAPON.ShiningHeartRod,
	Common.WEAPON.Coilgun,
	Common.WEAPON.Aeolis,
	Common.WEAPON.BroadDivine,
	Common.WEAPON.LaserMinigun,
	Common.WEAPON.M249Phoenix,
	-- 장비무기 리스트
	Common.WEAPON.M32MGL,
	Common.WEAPON.PetrolBoomer,
	Common.WEAPON.Slasher,
	Common.WEAPON.Eruptor,
	Common.WEAPON.Leviathan,
	Common.WEAPON.Salamander,
	Common.WEAPON.RPG7,
	Common.WEAPON.M32MGLVenom,
	Common.WEAPON.Stinger,
	Common.WEAPON.MagnumDrill,
	Common.WEAPON.GaeBolg,
	Common.WEAPON.Ripper,
	Common.WEAPON.BlackDragonCannon,
	Common.WEAPON.Guillotine
}


--[[ 무기종류별 속성 수정 ]]


-- 보조무기 속성
option = Common.GetWeaponOption(Common.WEAPON.P228)
option.price = 100 -- 무기 구매가격
option.damage = 1.0 -- Weapon 클래스와 함께 설정할 경우 둘다 곱연산
option.penetration = 1.0 -- 관통력
option.rangemod = 1.0 -- 거리에 따른 데미지 감쇠율
option.cycletime = 1.0 -- 연사 속도
option.reloadtime = 1.0 -- 장전 속도
option.accuracy = 1.0 -- 정확도
option.spread = 1.0 -- 동작을 수행할때 정확도가 떨어지는 정도
option:SetBulletColor({r = 255, g = 255, b = 50}); -- 총 발사시 지정한 색상의 발사 경로가 나온다
option.user.grade = WeaponGrade.normal  -- 무기종류별 최소 등급을 미리 정의
option.user.level = 1 -- 무기 구매시 레벨 제한

-- 무기 속성 상세 설정 무기id, 가격, 등급, 사용가능 레벨, R, G, B
function SetOption(weaponid, price, grade, level, red, green, blue)
	option = Common.GetWeaponOption(weaponid)
	option.price = price
	option.user.grade = grade
	option.user.level = level

	if red ~= nil then
		option:SetBulletColor({r = red, g = green, b = blue});
	end
end

SetOption(Common.WEAPON.DualBeretta,		100, WeaponGrade.normal, 3, 255, 255, 50)
SetOption(Common.WEAPON.FiveSeven,			100, WeaponGrade.normal, 1, 255, 255, 50)
SetOption(Common.WEAPON.Glock18C,			100, WeaponGrade.normal, 1, 255, 255, 50)
SetOption(Common.WEAPON.USP45,				100, WeaponGrade.normal, 1, 255, 255, 50)
SetOption(Common.WEAPON.DesertEagle50C,		500, WeaponGrade.normal, 5, 255, 255, 50)
SetOption(Common.WEAPON.DualInfinity,		500, WeaponGrade.normal, 3, 255, 255, 50)
SetOption(Common.WEAPON.DualInfinityCustom,	800, WeaponGrade.normal, 4, 255, 255, 50)
SetOption(Common.WEAPON.DualInfinityFinal,	1500, WeaponGrade.normal, 7, 255, 255, 50)
SetOption(Common.WEAPON.SawedOffM79,		1000, WeaponGrade.normal, 5)
SetOption(Common.WEAPON.Cyclone,			2000, WeaponGrade.unique, 8)
SetOption(Common.WEAPON.AttackM950,			700, WeaponGrade.unique, 5, 255, 255, 50)
SetOption(Common.WEAPON.DesertEagle50CGold,	700, WeaponGrade.unique, 5, 255, 255, 50)
SetOption(Common.WEAPON.ThunderGhostWalker,			5000, WeaponGrade.legend, 7)
SetOption(Common.WEAPON.PythonDesperado,			8000, WeaponGrade.legend, 15, 255, 255, 50)
SetOption(Common.WEAPON.DesertEagleCrimsonHunter,	7000, WeaponGrade.legend, 12, 255, 255, 50)
SetOption(Common.WEAPON.DualBerettaGunslinger,		20000, WeaponGrade.legend, 30, 255, 255, 50)

-- 소총 속성
SetOption(Common.WEAPON.Galil,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.FAMAS,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.M4A1,		700, WeaponGrade.normal, 5, 255, 128, 0)
SetOption(Common.WEAPON.SG552,		700, WeaponGrade.normal, 5, 255, 128, 0)
SetOption(Common.WEAPON.AK47,		700, WeaponGrade.normal, 5, 255, 128, 0)
SetOption(Common.WEAPON.AUG,		700, WeaponGrade.normal, 5, 255, 128, 0)
SetOption(Common.WEAPON.AN94,		500, WeaponGrade.normal, 1, 255, 128, 0)
SetOption(Common.WEAPON.M16A4,		500, WeaponGrade.normal, 1, 255, 128, 0)
SetOption(Common.WEAPON.AK47Custom,	15000, WeaponGrade.normal, 20, 255, 128, 0)
SetOption(Common.WEAPON.HK416,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.AK74U,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.AKM,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.L85A2,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.FNFNC,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.TAR21,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.SCAR,		500, WeaponGrade.normal, 2, 255, 128, 0)
SetOption(Common.WEAPON.SKULL4,				5000, WeaponGrade.rare, 10, 255, 128, 0)
SetOption(Common.WEAPON.OICW,				1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.PlasmaGun,			1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.StunRifle,			7000, WeaponGrade.unique, 15, 255, 128, 0)
SetOption(Common.WEAPON.StarChaserAR,		8000, WeaponGrade.unique, 20, 255, 128, 0)
SetOption(Common.WEAPON.CompoundBow,		1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.LightningAR2,		1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.Ethereal,			1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.LightningAR1,		1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.F2000,				1000, WeaponGrade.unique, 5, 255, 128, 0)
SetOption(Common.WEAPON.Crossbow,			1000, WeaponGrade.legend, 8, 255, 128, 0)
SetOption(Common.WEAPON.CrossbowAdvance,	2600, WeaponGrade.legend, 8, 255, 128, 0)
SetOption(Common.WEAPON.M4A1DarkKnight,		20000, WeaponGrade.legend, 25, 255, 128, 0)
SetOption(Common.WEAPON.AK47Paladin,		20000, WeaponGrade.legend, 25, 255, 128, 0)

-- 기관단총 속성
SetOption(Common.WEAPON.MAC10,					300, WeaponGrade.normal, 2, 128, 255, 255)
SetOption(Common.WEAPON.UMP45,					300, WeaponGrade.normal, 2, 128, 255, 255)
SetOption(Common.WEAPON.MP5,					300, WeaponGrade.normal, 3, 128, 255, 255)
SetOption(Common.WEAPON.TMP,					300, WeaponGrade.normal, 1, 128, 255, 255)
SetOption(Common.WEAPON.P90,					300, WeaponGrade.normal, 1, 128, 255, 255)
SetOption(Common.WEAPON.MP7A1ExtendedMag,		2000, WeaponGrade.normal, 10, 128, 255, 255)
SetOption(Common.WEAPON.DualKriss,				500, WeaponGrade.normal, 5, 128, 255, 255)
SetOption(Common.WEAPON.KrissSuperV,			300, WeaponGrade.normal, 3, 128, 255, 255)
SetOption(Common.WEAPON.DualMP7A1,				500, WeaponGrade.normal, 5, 128, 255, 255)
SetOption(Common.WEAPON.Tempest,				1000, WeaponGrade.unique, 6, 128, 255, 255)
SetOption(Common.WEAPON.TMPDragon,				800, WeaponGrade.unique, 3, 128, 255, 255)
SetOption(Common.WEAPON.P90Lapin,				800, WeaponGrade.unique, 3, 128, 255, 255)
SetOption(Common.WEAPON.DualUZI,				1200, WeaponGrade.unique, 4, 128, 255, 255)
SetOption(Common.WEAPON.Needler,				1000, WeaponGrade.unique, 3, 128, 255, 255)
SetOption(Common.WEAPON.InfinityLaserFist,		20000, WeaponGrade.legend, 25)

-- 샷건 속성
SetOption(Common.WEAPON.M3,						300, WeaponGrade.normal, 3, 50, 255, 50)
SetOption(Common.WEAPON.XM1014,					500, WeaponGrade.normal, 4, 50, 255, 50)
SetOption(Common.WEAPON.DoubleBarrelShotgun,	200, WeaponGrade.normal, 1, 50, 255, 50)
SetOption(Common.WEAPON.WinchesterM1887,		500, WeaponGrade.normal, 4, 50, 255, 50)
SetOption(Common.WEAPON.USAS12,					700, WeaponGrade.normal, 5, 50, 255, 50)
SetOption(Common.WEAPON.JackHammer,				500, WeaponGrade.normal, 3, 50, 255, 50)
SetOption(Common.WEAPON.TripleBarrelShotgun,	600, WeaponGrade.normal, 4, 50, 255, 50)
SetOption(Common.WEAPON.SPAS12Maverick,			1200, WeaponGrade.rare, 7, 50, 255, 50)
SetOption(Common.WEAPON.FireVulcan,				3000, WeaponGrade.rare, 5, 50, 255, 50)
SetOption(Common.WEAPON.BALROGXI,				10000, WeaponGrade.rare, 12, 50, 255, 50)
SetOption(Common.WEAPON.BOUNCER,				20000, WeaponGrade.unique, 14)
SetOption(Common.WEAPON.FlameJackhammer,		3000, WeaponGrade.unique, 5, 50, 255, 50)
SetOption(Common.WEAPON.RailCannon,				3000, WeaponGrade.unique, 5, 50, 255, 50)
SetOption(Common.WEAPON.LightningSG1,			3000, WeaponGrade.unique, 5, 50, 255, 50)
SetOption(Common.WEAPON.USAS12CAMO,				3000, WeaponGrade.unique, 5, 50, 255, 50)
SetOption(Common.WEAPON.WinchesterM1887Gold,	3000, WeaponGrade.unique, 5, 50, 255, 50)
SetOption(Common.WEAPON.UTS15PinkGold,			3000, WeaponGrade.unique, 5, 50, 255, 50)
SetOption(Common.WEAPON.Volcano,				15000, WeaponGrade.legend, 14, 50, 255, 50)


-- 기관총 속성
SetOption(Common.WEAPON.M249,			600, WeaponGrade.normal, 3, 255, 50, 255)
SetOption(Common.WEAPON.MG3,			1500, WeaponGrade.normal, 7, 255, 50, 255)
SetOption(Common.WEAPON.M134Minigun,	1000, WeaponGrade.normal, 3, 255, 50, 255)
SetOption(Common.WEAPON.MG36,			1000, WeaponGrade.normal, 5, 255, 50, 255)
SetOption(Common.WEAPON.MK48,			1000, WeaponGrade.normal, 5, 255, 50, 255)
SetOption(Common.WEAPON.K3,				600, WeaponGrade.normal, 5, 255, 50, 255)
SetOption(Common.WEAPON.QBB95,			800, WeaponGrade.normal, 7, 255, 50, 255)
SetOption(Common.WEAPON.QBB95AdditionalMag,		1000, WeaponGrade.normal, 7, 255, 50, 255)
SetOption(Common.WEAPON.BALROGVII,				2500, WeaponGrade.rare, 7, 255, 50, 255)
SetOption(Common.WEAPON.MG3CSOGSEdition,		2500, WeaponGrade.rare, 7, 255, 50, 255)
SetOption(Common.WEAPON.CHARGER7,				5000, WeaponGrade.rare, 7, 255, 50, 255)
SetOption(Common.WEAPON.ShiningHeartRod,		8000, WeaponGrade.unique, 12, 255, 50, 255)
SetOption(Common.WEAPON.Coilgun,				5000, WeaponGrade.unique, 7, 255, 50, 255)
SetOption(Common.WEAPON.Aeolis,					5000, WeaponGrade.unique, 7, 255, 50, 255)
SetOption(Common.WEAPON.BroadDivine,			7000, WeaponGrade.unique, 10, 255, 50, 255)
SetOption(Common.WEAPON.LaserMinigun,			7000, WeaponGrade.unique, 10)
SetOption(Common.WEAPON.M249Phoenix,			30000, WeaponGrade.legend, 25, 255, 50, 255)


-- 장비무기 속성
SetOption(Common.WEAPON.M32MGL,			3000, WeaponGrade.normal, 5)
SetOption(Common.WEAPON.PetrolBoomer,	3000, WeaponGrade.normal, 5)
SetOption(Common.WEAPON.Slasher,		3000, WeaponGrade.normal, 5)
SetOption(Common.WEAPON.Eruptor,		300, WeaponGrade.normal, 1)
SetOption(Common.WEAPON.Leviathan,		2000, WeaponGrade.normal, 7)
SetOption(Common.WEAPON.Salamander,		2000, WeaponGrade.normal, 7)
SetOption(Common.WEAPON.RPG7,			1200, WeaponGrade.normal, 3)
SetOption(Common.WEAPON.M32MGLVenom,	5000, WeaponGrade.unique, 15)
SetOption(Common.WEAPON.Stinger,		3000, WeaponGrade.unique, 3)
SetOption(Common.WEAPON.MagnumDrill,	20000, WeaponGrade.legend, 25, 50, 50, 255)
SetOption(Common.WEAPON.GaeBolg,		10000, WeaponGrade.legend, 15)
SetOption(Common.WEAPON.Ripper,			15000, WeaponGrade.legend, 20)
SetOption(Common.WEAPON.BlackDragonCannon,		10000, WeaponGrade.legend, 7)
SetOption(Common.WEAPON.Guillotine,		10000, WeaponGrade.legend, 10)