

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel		= "models/weapons/w_crossbow.mdl"
SWEP.AnimPrefix		= "bow"
SWEP.HoldType		= "crossbow"

SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= true;
SWEP.m_bInZoom			= false;
SWEP.m_bMustReload		= false;

//local	BOLT_MODEL			= "models/crossbow_bolt.mdl"
local	BOLT_MODEL	= "models/weapons/w_missile_closed.mdl"

local	BOLT_AIR_VELOCITY	= 3500
local	BOLT_WATER_VELOCITY	= 1500
local	BOLT_SKIN_NORMAL	= 0
local	BOLT_SKIN_GLOW		= 1

local	CROSSBOW_GLOW_SPRITE	= "sprites/light_glow02_noz.vmt"
local	CROSSBOW_GLOW_SPRITE2	= "sprites/blueflare1.vmt"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_Crossbow.Single" )
SWEP.Primary.Damage			= 100
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= 1					// Size of a clip
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 5					// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "XBowBolt"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"



/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
		self:SetNPCMinBurst( 0 )
		self:SetNPCMaxBurst( 0 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

	self.Weapon:SetNWBool( "m_bInZoom", false );

end


/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	util.PrecacheSound( "Weapon_Crossbow.BoltHitBody" );
	util.PrecacheSound( "Weapon_Crossbow.BoltHitWorld" );
	util.PrecacheSound( "Weapon_Crossbow.BoltSkewer" );

	util.PrecacheModel( CROSSBOW_GLOW_SPRITE );
	util.PrecacheModel( CROSSBOW_GLOW_SPRITE2 );

	self.BaseClass:Precache();

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	if ( self.m_bIsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );

		return;
	end

	if ( self.m_bInZoom && IsMultiplayer() ) then
//		self:FireSniperBolt();
		self:FireBolt();
	else
		self:FireBolt();
	end

	// Signal a reload
	self.m_bMustReload = true;

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	//NOTENOTE: The zooming is handled by the post/busy frames
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self.Weapon:DefaultReload( ACT_VM_RELOAD ) ) then
		self.m_bMustReload = false;
		return true;
	end

	return false;

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:CheckZoomToggle()

	local pPlayer = self.Owner;

	if ( pPlayer:KeyPressed( IN_ATTACK2 ) ) then
		self:ToggleZoom();
	end

end

/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

	// Allow zoom toggling even when we're reloading
	self:CheckZoomToggle();

	if ( self.m_bMustReload ) then
		self:Reload();
	end

	self.BaseClass:Think();

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:FireBolt( void )

	if ( self.Weapon:Clip1() <= 0 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.15 );
			self.m_flNextPrimaryAttack = 0.15;
		end

		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

if ( !CLIENT ) then
	local vecAiming		= pOwner:GetAimVector();
	local vecSrc		= pOwner:GetShootPos();

	local angAiming;
	angAiming = vecAiming:Angle();

	local pBolt = ents.Create( "crossbow_bolt" );
	pBolt:SetPos( vecSrc );
	pBolt:SetAngle( angAiming );
	// pBolt:SetDamage( self.Primary.Damage );
	pBolt:SetOwner( pOwner );
	pBolt:Spawn();

	if ( pOwner:WaterLevel() == 3 ) then
		pBolt:SetVelocity( vecAiming * BOLT_WATER_VELOCITY );
	else
		pBolt:SetVelocity( vecAiming * BOLT_AIR_VELOCITY );
	end

end

	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	pOwner:ViewPunch( Angle( -2, 0, 0 ) );

	self.Weapon:EmitSound( self.Primary.Sound );
	self.Weapon:EmitSound( self.Primary.Special2 );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );
	self.m_flNextPrimaryAttack = CurTime() + self.Primary.Delay;
	self.m_flNextSecondaryAttack = CurTime() + self.Primary.Delay;

	// self:DoLoadEffect();
	// self:SetChargerState( CHARGER_STATE_DISCHARGE );

end


/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )

	if ( self.Weapon:GetNWBool( "m_bInZoom" ) || self.m_bInZoom ) then
		self:ToggleZoom();
	end

	// self:SetChargerState( CHARGER_STATE_OFF );

	return self.BaseClass:Holster( wep );

end

/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	if ( self.Weapon:Clip1() <= 0 ) then
		return self.Weapon:SendWeaponAnim( ACT_CROSSBOW_DRAW_UNLOADED );
	end

	self:SetSkin( BOLT_SKIN_GLOW );

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return self.BaseClass:Deploy();

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:ToggleZoom()

	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

if ( !CLIENT ) then

	if ( self.Weapon:GetNWBool( "m_bInZoom" ) || self.m_bInZoom ) then
		if ( pPlayer:SetFOV( 0, 0.2 ) ) then
			self.Weapon:SetNWBool( "m_bInZoom", false )
			self.m_bInZoom = false;
		end
	else
		if ( pPlayer:SetFOV( 20, 0.1 ) ) then
			self.Weapon:SetNWBool( "m_bInZoom", true )
			self.m_bInZoom = true;
		end
	end
end

end

/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end

