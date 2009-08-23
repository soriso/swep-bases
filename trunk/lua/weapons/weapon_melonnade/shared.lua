

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "FRAG GRENADE"
	SWEP.Author				= "Andrew McWatters"
	SWEP.IconLetter			= "4"

	killicon.AddFont( "sent_grenade_frag", "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_frag"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Primary.AmmoType		= "sent_grenade_frag"
