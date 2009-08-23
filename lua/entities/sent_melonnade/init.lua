
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


local sk_plr_dmg_fraggrenade	= server_settings.Int( "sk_plr_dmg_fraggrenade","0" );
local sk_npc_dmg_fraggrenade	= server_settings.Int( "sk_npc_dmg_fraggrenade","0" );
local sk_fraggrenade_radius		= server_settings.Int( "sk_fraggrenade_radius", "0" );


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
		phys:GetPhysicsObject():SetMass( phys:GetPhysicsObject():GetMass() * self.Weapon.Primary.Damage )
		phys:GetPhysicsObject():SetVelocity( Vector( math.Rand( -Src.x, Src.x ), math.Rand( -Src.y, Src.y ), math.Rand( -Src.y, Src.y ) ) * 1500 )

	end

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

function ENT:Initialize()

	self.m_hThrower			= NULL;
	self.m_hOriginalThrower	= NULL;
	self.m_bIsLive			= false;
	self.m_DmgRadius		= 100;
	self.m_flDetonateTime	= CurTime() + GRENADE_TIMER;
	self.m_flWarnAITime		= CurTime() + GRENADE_TIMER - FRAG_GRENADE_WARN_TIME;
	self.m_bHasWarnedAI		= false;

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
function ENT:CreateEffects()

	local	nAttachment = self.Entity:LookupAttachment( "fuse" );

	// Start up the eye trail
	self.m_pGlowTrail	= util.SpriteTrail( self.Entity, nAttachment, Color( 0, 255, 0, 255 ), true, 8.0, 1.0, 0.5, 1 / ( 8.0 + 1.0 ) * 0.5, "sprites/bluelaser1.vmt" );

end



