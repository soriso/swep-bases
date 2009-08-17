

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "Tau Cannon"
	SWEP.Author				= "Andrew McWatters"
	SWEP.WepSelectLetter	= "h"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", "/", Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_smg1"

SWEP.Primary.Sound			= Sound( "PropJeep.FireCannon" )
SWEP.Primary.Damage			= 15
SWEP.Primary.Cone			= VECTOR_CONE_1DEGREES
SWEP.Primary.Delay			= 0.2
SWEP.Primary.Ammo			= "GaussEnergy"
SWEP.Primary.Tracer			= 1
SWEP.Primary.TracerName		= "GaussTracer"

SWEP.Secondary.Sound		= Sound( "PropJeep.FireChargedCannon" )
SWEP.Secondary.Delay		= 0.5
SWEP.Secondary.Ammo			= "None"

function SWEP:SecondaryAttack()
end

function SWEP:ShootCallback( attacker, tr, dmginfo )

	local Pos1 = tr.HitPos + tr.HitNormal
	local Pos2 = tr.HitPos - tr.HitNormal

	util.Decal( "RedGlowFade", Pos1, Pos2 );

end
