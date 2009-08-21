

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "REVOLVER"
	SWEP.Author				= "Andrew McWatters"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), SWEP.IconFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_pistol"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound			= Sound( "NPC_Strider.FireMinigun" )
SWEP.Primary.Damage			= 15
SWEP.Primary.ClipSize		= 15
SWEP.Primary.Delay			= 0.2
SWEP.Primary.Ammo			= "StriderMinigun"
SWEP.Primary.Tracer			= 1

SWEP.Secondary.Ammo			= "None"

function SWEP:SecondaryAttack()
end
