

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "MELONNADE"
	SWEP.Author				= "Andrew McWatters"
	SWEP.IconLetter			= "4"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_frag"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Primary.AmmoType		= "sent_melonnade"