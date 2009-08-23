
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


/*---------------------------------------------------------
   Name: Explode
---------------------------------------------------------*/
function ENT:Explode( pTrace, bitsDamageType )

	self.BaseClass:Explode( pTrace, bitsDamageType )

	for i = 1, 12 do

		if ( GAMEMODE.IsSandboxDerived ) then

			if ( !self:GetOwner():CheckLimit( "props" ) ) then return false end

		end

		local Src		= VECTOR_CONE_10DEGREES
		local Dir		= self.Entity:GetUp() + Vector( math.Rand( -Src.x, Src.x ), math.Rand( -Src.y, Src.y ), math.Rand( -Src.y, Src.y ) )
		local phys		= ents.Create( "prop_physics_multiplayer" )

		phys:SetPos( self.Entity:GetPos() + ( Dir * 32 ) )
		phys:SetAngles( Dir:Angle() )

		phys:SetModel( "models/props_junk/watermelon01.mdl" )
		phys:SetOwner( self:GetOwner() )
		phys:SetPhysicsAttacker( self:GetOwner() )

		phys:Spawn()

		if ( GAMEMODE.IsSandboxDerived ) then

			DoPropSpawnedEffect( phys )

			undo.Create("Prop")
				undo.AddEntity( phys )
				undo.SetPlayer( self:GetOwner() )
			undo.Finish()

			self:GetOwner():AddCleanup( "props", phys )
			self:GetOwner():AddCount( "props", phys )

		end

		phys:SetPos( self.Entity:GetPos() + ( Dir * phys:BoundingRadius() ) )
		phys:GetPhysicsObject():AddGameFlag( FVPHYSICS_WAS_THROWN )
		phys:GetPhysicsObject():SetMass( phys:GetPhysicsObject():GetMass() * self.Weapon.Damage )
		phys:GetPhysicsObject():SetVelocity( vecAiming * 1500 )

	end

end



