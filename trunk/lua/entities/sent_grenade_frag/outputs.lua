
ENT.Model				= GRENADE_MODEL

ENT.Explosion			= {}
ENT.Explosion.Damage	= ENT.Damage
ENT.Explosion.Effect	= "Explosion"
ENT.Explosion.Radius	= 100

ENT.Sound				= {}
ENT.Sound.Blip			= "Grenade.Blip"
ENT.Sound.Explode		= "BaseGrenade.Explode"

ENT.Trail				= {}
ENT.Trail.Color			= Color( 255, 0, 0, 255 )
ENT.Trail.Material		= "sprites/bluelaser1.vmt"
ENT.Trail.StartWidth	= 8.0
ENT.Trail.EndWidth		= 1.0
ENT.Trail.LifeTime		= 0.5

// Nice helper function, this does all the work.

/*---------------------------------------------------------
   Name: DoExplodeEffect
---------------------------------------------------------*/
function ENT:DoExplodeEffect()

	local info = EffectData();
	info:SetEntity( self.Entity );
	info:SetOrigin( self.Entity:GetPos() );

	util.Effect( self.Explosion.Effect, info );

end

/*---------------------------------------------------------
   Name: OnExplode
   Desc: The grenade has just exploded.
---------------------------------------------------------*/
function ENT:OnExplode( pTrace )

	local Pos1 = Vector( self.Entity:GetPos().x, self.Entity:GetPos().y, pTrace.HitPos.z ) + pTrace.HitNormal
	local Pos2 = Vector( self.Entity:GetPos().x, self.Entity:GetPos().y, pTrace.HitPos.z ) - pTrace.HitNormal

 	util.Decal( "Scorch", Pos1, Pos2 );

end

/*---------------------------------------------------------
   Name: OnInitialize
---------------------------------------------------------*/
function ENT:OnInitialize()

	self:SetDamage( self.Explosion.Damage )
	self:SetDamageRadius( self.Explosion.Radius )

end

/*---------------------------------------------------------
   Name: OnThink
---------------------------------------------------------*/
function ENT:OnThink()
end