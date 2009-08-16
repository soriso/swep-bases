

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "Strider Minigun"
	SWEP.Author				= "Andrew McWatters"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", "2", Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_ar2"

SWEP.Primary.Sound			= Sound( "NPC_Strider.FireMinigun" )
SWEP.Primary.Damage			= 15
SWEP.Primary.ClipSize		= 15
SWEP.Primary.Delay			= 0.02
SWEP.Primary.Ammo			= "StriderMinigun"

SWEP.Secondary.Ammo			= "None"

function SWEP:SecondaryAttack()
end
