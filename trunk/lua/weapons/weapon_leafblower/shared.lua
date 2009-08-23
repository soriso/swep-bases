

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "LEAFBLOWER"
	SWEP.Author				= "Andrew McWatters"
	SWEP.DrawAmmo			= false

end


SWEP.Base				= "swep_smg1"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound			= Sound( "ambient/wind/wind_hit2.wav" )
SWEP.Primary.NumAmmo		= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0
SWEP.Primary.DefaultClip	= -1

SWEP.Secondary.Ammo			= "None"

function SWEP:SecondaryAttack()
end

function SWEP:ShootBullet( damage, num_bullets, aimcone )

	local trace = self.Owner:GetEyeTrace()

	if ( CLIENT ) then return end

	if ( trace.Entity:IsValid() ) then

		if ( trace.Entity:GetPhysicsObject():IsValid() ) then

			local phys = trace.Entity:GetPhysicsObject()		// The physics object
			local direction = trace.StartPos - trace.HitPos		// The direction of the force
			local force = 32					// The ideal amount of force
			local distance = direction:Length()			// The distance the phys object is from the gun
			local maxdistance = 512					// The max distance the gun should reach

			// Lessen the force from a distance
			local ratio = math.Clamp( (1 - (distance/maxdistance)), 0, 1 )

			// Set up the 'real' force and the offset of the force
			local vForce = -1*direction * (force * ratio)
			local vOffset = trace.HitPos

			// Apply it!
			phys:ApplyForceOffset( vForce, vOffset )

		end

	end

end
