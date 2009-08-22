

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "MELONGUN"
	SWEP.Author				= "Andrew McWatters"

end


SWEP.Base				= "swep_shotgun"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

function SWEP:ShootBullet( damage, num_bullets, aimcone )

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecAiming		= pPlayer:GetAimVector();

	local info = { Num = num_bullets, Src = vecSrc, Dir = vecAiming, Spread = aimcone, Damage = damage };
	info.Attacker = pPlayer;

	if ( CLIENT ) then return end

	// Fire the melons, and force the first shot to be perfectly juicy
	for i = 1, info.Num do

		if ( GAMEMODE.IsSandboxDerived ) then

			if ( !pPlayer:CheckLimit( "props" ) ) then return false end

		end

		local Src		= info.Spread || vec3_origin
		local Dir		= info.Dir + Vector( math.Rand( -Src.x, Src.x ), math.Rand( -Src.y, Src.y ), math.Rand( -Src.y, Src.y ) )
		local phys		= ents.Create( "prop_physics_multiplayer" )

		phys:SetPos( info.Src + ( Dir * 32 ) )
		phys:SetAngles( Dir:Angle() )

		phys:SetModel( "models/props_junk/watermelon01.mdl" )
		phys:SetOwner( pPlayer )
		phys:SetPhysicsAttacker( pPlayer )

		phys:Spawn()

		if ( GAMEMODE.IsSandboxDerived ) then

			DoPropSpawnedEffect( phys )

			undo.Create("Prop")
				undo.AddEntity( phys )
				undo.SetPlayer( pPlayer )
			undo.Finish()

			pPlayer:AddCleanup( "props", phys )
			pPlayer:AddCount( "props", phys )

		end

		phys:SetPos( info.Src + ( Dir * phys:BoundingRadius() ) )
		phys:GetPhysicsObject():AddGameFlag( FVPHYSICS_WAS_THROWN )
		phys:GetPhysicsObject():SetMass( phys:GetPhysicsObject():GetMass() * info.Damage )
		phys:GetPhysicsObject():SetVelocity( vecAiming * 1500 )

	end

end
