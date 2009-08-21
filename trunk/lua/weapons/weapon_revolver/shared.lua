

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "REVOLVER"
	SWEP.Author				= "Andrew McWatters"
	SWEP.WepSelectLetter	= "e"
	SWEP.IconLetter			= "."

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_pistol"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"
SWEP.AnimPrefix			= "python"

SWEP.Primary.Reload			= Sound( "common/null.wav" )
SWEP.Primary.Sound			= Sound( "Weapon_357.Single" )
SWEP.Primary.Damage			= 75
SWEP.Primary.ClipSize		= 6
SWEP.Primary.FastestDelay	= 0.25
SWEP.Primary.Delay			= 0.75

function SWEP:AddViewKick()

	local pPlayer  = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	//Disorient the player
	local angles = pPlayer:EyeAngles();

	angles.pitch = angles.pitch + math.random( -1, 1 );
	angles.yaw   = angles.yaw   + math.random( -1, 1 );
	angles.roll  = 0;

	if ( pPlayer:IsNPC() ) then return end

if ( !CLIENT ) then
	pPlayer:SnapEyeAngles( angles );
end

	pPlayer:ViewPunch( Angle( -8, math.Rand( -2, 2 ), 0 ) );

end
