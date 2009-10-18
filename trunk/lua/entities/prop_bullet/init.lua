
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.InvalidEntities = {

	"prop_portal",
	"trigger_"

}


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	// Use the bullet model just for the shadow (because it's about the same size)
	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:DrawShadow( false )

	// Use the model's physics
	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	// Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity( false )
	end

	// Set collision bounds exactly
	self.Entity:SetSolid( SOLID_NONE )

end


/*---------------------------------------------------------
   Name: PhysicsUpdate
---------------------------------------------------------*/
function ENT:PhysicsUpdate()

	if (!self.Num) then return end

	local tr 	= {}
	tr.startpos	= self.Entity:GetPos()
	tr.endpos 	= self.Entity:GetPos() + self.Entity:GetForward() * 32
	tr.filter 	= self.Owner
	tr.mask 	= MASK_SHOT
	local trace = util.TraceLine( tr )
	if (trace.Hit || trace.HitWorld) then
		for k, v in pairs( self.InvalidEntities ) do
			if (string.find( trace.Entity:GetClass(), v)) then
				return;
			end
		end

		local bullet = {}
				bullet.Num                      = 1
				bullet.Src                      = self.Entity:GetPos()
				bullet.Dir                      = self.Entity:GetForward()
				bullet.Spread           = vec3_origin
				bullet.Tracer           = 0
				bullet.TracerName       = self.TracerName
				bullet.Force            = self.Force
				bullet.Damage           = self.Damage
				bullet.Attacker         = self.Attacker
				bullet.Callback         = self.Callback
		self.Entity:Remove()
		pcall( function()
			self.Owner:g_FireBullets( bullet )
		end )
	end

end



