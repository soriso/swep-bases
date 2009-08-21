

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "BALLOON GUN"
	SWEP.Author				= "Nathaniel Anderson"

end


SWEP.Base				= "swep_pistol"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

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
