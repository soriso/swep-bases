
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


FRAG_GRENADE_BLIP_FREQUENCY			= 1.0
FRAG_GRENADE_BLIP_FAST_FREQUENCY	= 0.3

FRAG_GRENADE_GRACE_TIME_AFTER_PICKUP = 1.5
FRAG_GRENADE_WARN_TIME = 1.5

GRENADE_COEFFICIENT_OF_RESTITUTION = 0.2;

local sk_plr_dmg_fraggrenade	= server_settings.Int( "sk_plr_dmg_fraggrenade","0" );
local sk_npc_dmg_fraggrenade	= server_settings.Int( "sk_npc_dmg_fraggrenade","0" );
local sk_fraggrenade_radius		= server_settings.Int( "sk_fraggrenade_radius", "0" );

GRENADE_MODEL = "models/Weapons/w_grenade.mdl"


function		ENT:GetShakeAmplitude() return 25.0; end
function		ENT:GetShakeRadius() return 750.0; end

// Damage accessors.
function ENT:GetDamage()
	return self.m_flDamage;
end
function ENT:GetDamageRadius()
	return self.m_DmgRadius;
end

function ENT:SetDamage(flDamage)
	self.m_flDamage = flDamage;
end

function ENT:SetDamageRadius(flDamageRadius)
	self.m_DmgRadius = flDamageRadius;
end

// Bounce sound accessors.
function ENT:SetBounceSound( pszBounceSound )
	self.m_iszBounceSound = tostring( pszBounceSound );
end

function	ENT:BlipSound() self.Entity:EmitSound( "Grenade.Blip" ); end

// UNDONE: temporary scorching for PreAlpha - find a less sleazy permenant solution.
function ENT:Explode( pTrace, bitsDamageType )

if !( CLIENT ) then

	self.Entity:SetModel( "" );//invisible
	self.Entity:SetSolid( SOLID_NONE );

	self.m_takedamage = DAMAGE_NO;

	local vecAbsOrigin = self.Entity:GetPos();
	local contents = util.PointContents ( vecAbsOrigin );

	if ( pTrace.Fraction != 1.0 ) then
		local vecNormal = pTrace.HitNormal;
		local pdata = pTrace.MatType;

		util.BlastDamage( self.Weapon, // don't apply cl_interp delay
			self:GetOwner(),
			self.Entity:GetPos(),
			self.m_DmgRadius,
			self.m_flDamage );
	else
		util.BlastDamage( self.Weapon, // don't apply cl_interp delay
			self:GetOwner(),
			self.Entity:GetPos(),
			self.m_DmgRadius,
			self.m_flDamage );
	end

	local info = EffectData();
	info:SetEntity( self.Entity );
	info:SetOrigin( self.Entity:GetPos() );

	util.Effect( "Explosion", info );

	local Pos1 = Vector( self.Entity:GetPos().x, self.Entity:GetPos().y, pTrace.HitPos.z ) + pTrace.HitNormal
	local Pos2 = Vector( self.Entity:GetPos().x, self.Entity:GetPos().y, pTrace.HitPos.z ) - pTrace.HitNormal

 	util.Decal( "Scorch", Pos1, Pos2 );

	self.Entity:EmitSound( "BaseGrenade.Explode" );

	self.Touch = NULL;
	self.Entity:SetSolid( SOLID_NONE );

	self.Entity:SetVelocity( vec3_origin );

	// Because the grenade is zipped out of the world instantly, the EXPLOSION sound that it makes for
	// the AI is also immediately destroyed. For this reason, we now make the grenade entity inert and
	// throw it away in 1/10th of a second instead of right away. Removing the grenade instantly causes
	// intermittent bugs with env_microphones who are listening for explosions. They will 'randomly' not
	// hear explosion sounds when the grenade is removed and the SoundEnt thinks (and removes the sound)
	// before the env_microphone thinks and hears the sound.
	SafeRemoveEntityDelayed( self.Entity, 0.1 );

end

end

function ENT:Detonate()

	local		tr;
	local		vecSpot;// trace starts here!

	self.Think = NULL;

	vecSpot = self.Entity:GetPos() + Vector ( 0 , 0 , 8 );
	tr = {};
	tr.startpos = vecSpot;
	tr.endpos = vecSpot + Vector ( 0, 0, -32 );
	tr.mask = MASK_SHOT_HULL;
	tr.filter = self.Entity;
	tr.collision = COLLISION_GROUP_NONE;
	tr = util.TraceLine ( tr);

	if( tr.StartSolid ) then
		// Since we blindly moved the explosion origin vertically, we may have inadvertently moved the explosion into a solid,
		// in which case nothing is going to be harmed by the grenade's explosion because all subsequent traces will startsolid.
		// If this is the case, we do the downward trace again from the actual origin of the grenade. (sjb) 3/8/2007  (for ep2_outland_09)
		tr = {};
		tr.startpos = self.Entity:GetPos();
		tr.endpos = self.Entity:GetPos() + Vector( 0, 0, -32);
		tr.mask = MASK_SHOT_HULL;
		tr.filter = self.Entity;
		tr.collision = COLLISION_GROUP_NONE;
		tr = util.TraceLine( tr );
	end

	tr = self:Explode( tr, DMG_BLAST );

	if ( self:GetShakeAmplitude() ) then
		util.ScreenShake( self.Entity:GetPos(), self:GetShakeAmplitude(), 150.0, 1.0, self:GetShakeRadius() );
	end

end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.m_hThrower			= NULL;
	self.m_hOriginalThrower	= NULL;
	self.m_bIsLive			= false;
	self.m_DmgRadius		= 100;
	self.m_flDetonateTime	= CurTime() + GRENADE_TIMER;
	self.m_flWarnAITime		= CurTime() + GRENADE_TIMER - FRAG_GRENADE_WARN_TIME;
	self.m_bHasWarnedAI		= false;
	self.Owner				= self.Entity:GetOwner() || self.Entity;

	self:Precache( );

	self.Entity:SetModel( GRENADE_MODEL );

	if( self.Owner && self.Owner:IsPlayer() ) then
		self.m_flDamage		= sk_plr_dmg_fraggrenade;
		self.m_DmgRadius	= sk_fraggrenade_radius;
	else
		self.m_flDamage		= sk_npc_dmg_fraggrenade;
		self.m_DmgRadius	= sk_fraggrenade_radius;
	end

	self.m_takedamage	= DAMAGE_YES;
	self.m_iHealth		= 1;

	self.Entity:SetCollisionBounds( -Vector(4,4,4), Vector(4,4,4) );
	// self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	self:CreateVPhysics();

	self:BlipSound();
	self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FREQUENCY;

	self.m_combineSpawned	= false;
	self.m_punted			= false;

	if( self.Owner && self.Owner:IsPlayer() ) then
		self.Weapon = self.Owner:GetActiveWeapon()
	end

	self:CreateEffects();

	self.BaseClass:Initialize();

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:OnRestore()

	// If we were primed and ready to detonate, put FX on us.
	if (self.m_flDetonateTime > 0) then
		self:CreateEffects();
	end

	self.BaseClass:OnRestore();

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function ENT:CreateEffects()

	local	nAttachment = self.Entity:LookupAttachment( "fuse" );

	// Start up the eye trail
	self.m_pGlowTrail	= util.SpriteTrail( self.Entity, nAttachment, Color( 255, 0, 0, 255 ), true, 8.0, 1.0, 0.5, 1 / ( 8.0 + 1.0 ) * 0.5, "sprites/bluelaser1.vmt" );

end

function ENT:CreateVPhysics()

	// Create the object in the physics system
	self.Entity:PhysicsInit( SOLID_VPHYSICS, 0, false );
	return true;

end

function ENT:Precache()

	util.PrecacheModel( GRENADE_MODEL );

	util.PrecacheSound( "Grenade.Blip" );

	util.PrecacheModel( "sprites/redglow1.vmt" );
	util.PrecacheModel( "sprites/bluelaser1.vmt" );

	util.PrecacheSound( "BaseGrenade.Explode" );

end

function ENT:SetTimer( detonateDelay, warnDelay )

	self.m_flDetonateTime = CurTime() + detonateDelay;
	self.m_flWarnAITime = CurTime() + warnDelay;
	self.Entity:NextThink( CurTime() );

	self:CreateEffects();

end

function ENT:Think()

	if( CurTime() > self.m_flDetonateTime ) then
		self:Detonate();
		return;
	end

	if( !self.m_bHasWarnedAI && CurTime() >= self.m_flWarnAITime ) then
		self.m_bHasWarnedAI = true;
	end

	if( CurTime() > self.m_flNextBlipTime ) then
		self:BlipSound();

		if( self.m_bHasWarnedAI ) then
			self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FAST_FREQUENCY;
		else
			self.m_flNextBlipTime = CurTime() + FRAG_GRENADE_BLIP_FREQUENCY;
		end
	end

	self.Entity:NextThink( CurTime() + 0.1 );

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	// React physically when shot/getting blown
	self.Entity:TakePhysicsDamage( dmginfo )

end



