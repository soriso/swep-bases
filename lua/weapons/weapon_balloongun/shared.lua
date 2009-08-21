

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "BALLOON GUN"
	SWEP.Author				= "Nathaniel Anderson"
	SWEP.IconLetter			= "-"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_pistol"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

function SWEP:SecondaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	//Must have ammo
	if ( ( pPlayer:GetAmmoCount( self.Primary.Ammo ) <= 0 ) ) then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );
		return;
	end

	// MUST call sound before removing a round from the clip of a CMachineGun
	self.Weapon:EmitSound( self.Primary.Sound );

	local vecSrc = pPlayer:GetShootPos();
	local	vecThrow;
	// Don't autoaim on balloon tosses
	vecThrow = pPlayer:GetAimVector();
	vecThrow = vecThrow * 1000.0;

if ( !CLIENT ) then
	//Create the balloon
	local pGrenade = ents.Create( "gmod_balloon" );
	pGrenade:SetPos( vecSrc );
	pGrenade:SetOwner( pPlayer );
	pGrenade:SetVelocity( vecThrow );

	pGrenade:Spawn()
	pGrenade:SetAngles( RandomAngle( -400, 400 ) );
	//pGrenade:SetAngleVelocity( RandomAngle( -400, 400 ) );
	pGrenade:SetMoveType( MOVETYPE_FLYGRAVITY );
	pGrenade:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE );
	pGrenade:SetOwner( self.Owner );
end

	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );


	// Decrease ammo
	pPlayer:RemoveAmmo( 1, self.Secondary.Ammo );

	// Can shoot again immediately
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 );

	// Can blow up after a short delay (so have time to release mouse button)
	self.Weapon:SetNextSecondaryFire( CurTime() + 1.0 );

end

function SWEP:ShootCallback( attacker, trace, dmginfo )

	if (!GAMEMODE.IsSandboxDerived) then return true end
	if (CLIENT) then return true end
	local attach = true

	// If there's no physics object then we can't constraint it!
	if ( SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	local ply = attacker
	local length 			= attacker:GetInfo( "balloon_ropelength", 64 )
	local material 			= "cable/rope"
	local force 			= attacker:GetInfo( "balloon_force", 500 )
	local r 				= attacker:GetInfo( "balloon_r", 255 )
	local g 				= attacker:GetInfo( "balloon_g", 0 )
	local b 				= attacker:GetInfo( "balloon_b", 0 )
	local skin 				= attacker:GetInfo( "balloon_skin" )

	if (skin != "models/balloon/balloon" &&
		skin != "models/balloon/balloon_hl2") then

		r = 255
		g = 255
		b = 255

	end

	if	trace.Entity:IsValid() &&
		trace.Entity:GetClass() == "gmod_balloon" &&
		trace.Entity:GetTable().Player == ply
	then
		local force 	= attacker:GetInfo( "balloon_force", 500 )
		trace.Entity:GetTable():SetForce( force )
		trace.Entity:GetPhysicsObject():Wake()
		trace.Entity:SetColor( r, g, b, 255 )
		trace.Entity:GetTable():SetForce( force )
		trace.Entity:SetMaterial( skin )
		return true
	end

	if ( !attacker:CheckLimit( "balloons" ) ) then return false end

	local Pos = trace.HitPos + trace.HitNormal * 10
	local balloon = MakeBalloon( ply, r, g, b, force, skin, { Pos = Pos } )

	undo.Create("Balloon")
	undo.AddEntity( balloon )

	if (attach) then

		// The real model should have an attachment!
		local attachpoint = Pos + Vector( 0, 0, -10 )

		local LPos1 = balloon:WorldToLocal( attachpoint )
		local LPos2 = trace.Entity:WorldToLocal( trace.HitPos )

		if (trace.Entity:IsValid()) then

			local phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
			if (phys:IsValid()) then
				LPos2 = phys:WorldToLocal( trace.HitPos )
			end

		end

		local constraint, rope = constraint.Rope( balloon, trace.Entity,
												0, trace.PhysicsBone,
												LPos1, LPos2,
												0,length,
												0,
												1.5,
												material,
												nil )

		undo.AddEntity( rope )
		undo.AddEntity( constraint )
		ply:AddCleanup( "balloons", rope )
		ply:AddCleanup( "balloons", constraint )
	end

	undo.SetPlayer( ply )
	undo.Finish()


	ply:AddCleanup( "balloons", balloon )

	return true

end
