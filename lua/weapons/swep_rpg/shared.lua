

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_rpg.mdl"
SWEP.WorldModel		= "models/weapons/w_rocket_launcher.mdl"
SWEP.AnimPrefix		= "missile launcher"
SWEP.HoldType		= "rpg"

SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= false;
SWEP.m_bInitialStateUpdate= false;
SWEP.m_bHideGuiding = false;
SWEP.m_bGuiding = false;

SWEP.m_hLaserDot = NULL;
SWEP.m_hMissile = NULL;

SWEP.m_fMinRange1 = 40*12;
SWEP.m_fMinRange2 = 40*12;
SWEP.m_fMaxRange1 = 500*12;
SWEP.m_fMaxRange2 = 500*12;

local	RPG_BEAM_SPRITE		= "effects/laser1.vmt"
local	RPG_BEAM_SPRITE_NOZ	= "effects/laser1_noz.vmt"
local	RPG_LASER_SPRITE	= "sprites/redglow1.vmt"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Empty			= Sound( "Weapon_SMG1.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_RPG.Single" )
SWEP.Primary.Special1		= Sound( "Weapon_RPG.LaserOn" )
SWEP.Primary.Special2		= Sound( "Weapon_RPG.LaserOff" )
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 3					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "rpg_round"

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

if ( !CLIENT ) then
	if ( self.m_hLaserDot != NULL ) then
		self.m_hLaserDot:Remove();
		self.m_hLaserDot = NULL;
	end
end

end


/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	self.BaseClass:Precache();

	util.PrecacheSound( "Missile.Ignite" );
	util.PrecacheSound( "Missile.Accelerate" );

	// Laser dot...
	util.PrecacheModel( "sprites/redglow1.vmt" );
	util.PrecacheModel( RPG_LASER_SPRITE );
	util.PrecacheModel( RPG_BEAM_SPRITE );
	util.PrecacheModel( RPG_BEAM_SPRITE_NOZ );

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if (!pPlayer) then
		return;
	end

	// Can't have an active missile out
	if ( self.m_hMissile != NULL ) then
		return;
	end

	// Can't be reloading
	if ( self.Weapon:GetActivity() == ACT_VM_RELOAD ) then
		return;
	end

	local vecOrigin;
	local vecForward;

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local	vForward, vRight, vUp;

	vForward = pOwner:GetAimVector().x;
	vRight = pOwner:GetAimVector().y;
	vUp = pOwner:GetAimVector().z;

	local	muzzlePoint = pOwner:GetShootPos() + vForward * 12.0 + vRight * 6.0 + vUp * -3.0;

if ( !CLIENT ) then
	local vecAngles;
	vecAngles = vForward:Angle();

	local pMissile = ents.Create( "rpg_missile" );
	pMissile:SetPos( muzzlePoint );
	pMissile:SetAngles( vecAngles );
	pMissile:SetOwner( self.Owner );
	pMissile:Spawn();

	// If the shot is clear to the player, give the missile a grace period
	local	tr;
	local vecEye = pOwner:EyePos();
	tr = util.QuickTrace( vecEye, vecEye + vForward * 128, MASK_SHOT, self.Weapon, COLLISION_GROUP_NONE );
	if ( tr.fraction == 1.0 ) then
		pMissile.m_flGracePeriod = 0.3;
	end

	pMissile.m_iPlayerDamage = self.Primary.Damage;

	self.m_hMissile = pMissile;
end

	self:DecrementAmmo( self.Owner );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Weapon:EmitSound( self.Primary.Sound );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pOwner -
//-----------------------------------------------------------------------------
function SWEP:DecrementAmmo( pOwner )
	// Take away our primary ammo type
	pOwner:RemoveAmmo( 1, self.Primary.Ammo );
end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
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

end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	self.BaseClass:Deploy();

	// Restore the laser pointer after transition
	if ( self.m_bGuiding ) then
		local pOwner = self.Owner;

		if ( pOwner == NULL ) then
			return;
		end

		if ( pOwner:GetActiveWeapon() == self.Weapon ) then
			self:StartGuiding();
		end
	end

	return true

end

//-----------------------------------------------------------------------------
// Purpose: Turn on the guiding laser
//-----------------------------------------------------------------------------
function SWEP:StartGuiding()

	// Don't start back up if we're overriding this
	if ( self.m_bHideGuiding ) then
		return;
	end

	self.m_bGuiding = true;

if ( !CLIENT ) then
	self.Weapon:EmitSound(self.Primary.Special1);

	self:CreateLaserPointer();
end

end

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:CreateLaserPointer()

if ( !CLIENT ) then
	if ( self.m_hLaserDot != NULL ) then
		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( pOwner:GetAmmoCount(self.Primary.Ammo) <= 0 ) then
		return;
	end

	// self:UpdateLaserPosition();
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

