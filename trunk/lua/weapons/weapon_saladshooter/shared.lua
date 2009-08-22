

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "SALAD SHOOTER"
	SWEP.Author				= "Nathaniel Anderson"
	SWEP.IconLetter			= "/"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_smg1"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

function SWEP:SecondaryAttack()
end
