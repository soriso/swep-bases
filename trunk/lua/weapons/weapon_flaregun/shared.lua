

// Variables that are used on both client and server

SWEP.Author			= "VALVe"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_357.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.AnimPrefix		= "python"
SWEP.HoldType		= "pistol"

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
SWEP.Category			= "Base Examples"

FLARE_DURATION		= 30.0
FLARE_DECAY_TIME	= 10.0
FLARE_BLIND_TIME	= 6.0

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound			= Sound( "Weapon_FlareGun.Single" )
SWEP.Primary.ClipSize		= 1					// Size of a clip
SWEP.Primary.DefaultClip	= 6					// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"



/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	self.BaseClass:Precache();

	util.PrecacheSound( "Flare.Touch" );

	util.PrecacheSound( "Weapon_FlareGun.Burn" );

end


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

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		return;
	end

	self:TakePrimaryAmmo( 1 );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
	self.Weapon:SetNextSecondaryFire( CurTime() + 1 );

	if ( !CLIENT ) then

		local pFlare = ents.Create( "env_flare" );
		pFlare:SetPos( pOwner:GetShootPos() );
		pFlare:SetAngles( pOwner:EyeAngles() );
		pFlare:SetOwner( pOwner );
		pFlare:SetKeyValue( "duration", FLARE_DURATION );
		pFlare:Spawn();

		if ( pFlare == NULL ) then
			return;
		end

		local forward;
		forward = pOwner:GetAimVector();

		pFlare:SetVelocity( forward * 1500 );
		pFlare:SetMoveType( MOVETYPE_FLYGRAVITY );
		pFlare:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE );

	end

	self.Weapon:EmitSound( self.Primary.Sound );

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 ) then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		return;
	end

	self:TakePrimaryAmmo( 1 );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
	self.Weapon:SetNextSecondaryFire( CurTime() + 1 );

	if ( !CLIENT ) then

		local pFlare = ents.Create( "env_flare" );
		pFlare:SetPos( pOwner:GetShootPos() );
		pFlare:SetAngles( pOwner:EyeAngles() );
		pFlare:SetOwner( pOwner );
		pFlare:SetKeyValue( "duration", FLARE_DURATION );
		pFlare:Spawn();

		if ( pFlare == NULL ) then
			return;
		end

		local forward;
		forward = pOwner:GetAimVector();

		pFlare:SetVelocity( forward * 500 );
		pFlare:SetGravity(1.0);
		pFlare:SetFriction( 0.85 );
		pFlare:SetMoveType( MOVETYPE_FLYGRAVITY );
		pFlare:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE );

	end

	self.Weapon:EmitSound( self.Primary.Sound );

end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	return true

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

