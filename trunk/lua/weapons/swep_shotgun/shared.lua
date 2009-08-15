

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel		= "models/weapons/w_shotgun.mdl"
SWEP.AnimPrefix		= "shotgun"
SWEP.HoldType		= "shotgun"

SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Empty			= Sound( "Weapon_Shotgun.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_Shotgun.Single" )
SWEP.Primary.Reload			= Sound( "Weapon_Shotgun.Reload" )
SWEP.Primary.Special1		= Sound( "Weapon_Shotgun.Special1" )
SWEP.Primary.Damage			= 4
SWEP.Primary.NumShots		= 7
SWEP.Primary.NumAmmo		= 1
SWEP.Primary.Cone			= VECTOR_CONE_10DEGREES
SWEP.Primary.ClipSize		= 6					// Size of a clip
SWEP.Primary.Delay			= 0.7
SWEP.Primary.DefaultClip	= 6					// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "Buckshot"

SWEP.Secondary.Sound		= Sound( "Weapon_Shotgun.Double" )
SWEP.Secondary.Damage		= SWEP.Primary.Damage
SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"



function SWEP:GetBulletSpread()

	local cone = self.Primary.Cone;
	return cone;

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


//-----------------------------------------------------------------------------
// Purpose:
//
//
//-----------------------------------------------------------------------------
function SWEP:DryFire()

	self.Weapon:EmitSound(self.Primary.Empty);
	self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );

	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();

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

	// MUST call sound before removing a round from the clip of a CMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);

	pPlayer:MuzzleFlash();

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	// Don't fire again until fire animation has completed
	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();
	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );


	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self:GetBulletSpread() );

	local punch;
	punch = Angle( math.Rand( -2, -1 ), math.Rand( -2, 2 ), 0 );
	pPlayer:ViewPunch( punch );

	self.m_bNeedPump = true;

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	return false
end

//-----------------------------------------------------------------------------
// Purpose: Override so only reload one shell at a time
// Input  :
// Output :
//-----------------------------------------------------------------------------
function SWEP:StartReload()

	if ( self.m_bNeedPump ) then
		return false;
	end

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return false;
	end

	if (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
		return false;
	end

	if (self.Weapon:Clip1() >= self.Primary.ClipSize) then
		return false;
	end


	local j = math.min(1, pOwner:GetAmmoCount(self.Primary.Ammo));

	if (j <= 0) then
		return false;
	end

	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START );

	// Make shotgun shell visible
	self.Weapon:SetBodygroup(1,0);

	self.m_flNextAttack = CurTime();
	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();

	self.m_bInReload = true;
	return true;

end

//-----------------------------------------------------------------------------
// Purpose: Override so only reload one shell at a time
// Input  :
// Output :
//-----------------------------------------------------------------------------
function SWEP:Reload()

	// Check that StartReload was called first
	if (!self.m_bInReload) then
		if ( SERVER ) then
			ErrorNoHalt("ERROR: Shotgun Reload called incorrectly!\n");
		end
	end

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return false;
	end

	if (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
		return false;
	end

	if (self.Weapon:Clip1() >= self.Primary.ClipSize) then
		return false;
	end

	local j = math.min(1, pOwner:GetAmmoCount(self.Primary.Ammo));

	if (j <= 0) then
		return false;
	end

	self:FillClip();
	// Play reload on different channel as otherwise steals channel away from fire sound
	self.Weapon:EmitSound(self.Primary.Reload);
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD );

	self.m_flNextAttack = CurTime();
	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();

	return true;

end

//-----------------------------------------------------------------------------
// Purpose: Play finish reload anim and fill clip
// Input  :
// Output :
//-----------------------------------------------------------------------------
function SWEP:FinishReload()

	// Make shotgun shell invisible
	self.Weapon:SetBodygroup(1,1);

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	self.m_bInReload = false;

	// Finish reload animation
	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH );

	self.m_flNextAttack = CurTime();
	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();

end

//-----------------------------------------------------------------------------
// Purpose: Play finish reload anim and fill clip
// Input  :
// Output :
//-----------------------------------------------------------------------------
function SWEP:FillClip()

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	// Add them to the clip
	if ( pOwner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		if ( self.Weapon:Clip1() < self.Primary.ClipSize ) then
			self.Weapon:SetClip1( self.Weapon:Clip1() + 1 );
			self:TakePrimaryAmmo( 1 );
		end
	end

end

//-----------------------------------------------------------------------------
// Purpose: Play weapon pump anim
// Input  :
// Output :
//-----------------------------------------------------------------------------
function SWEP:Pump()

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	self.m_bNeedPump = false;

	if ( m_bDelayedReload ) then
		self.m_bDelayedReload = false;
		self:StartReload();
	end

	self.Weapon:EmitSound( self.Primary.Special1 );

	// Finish reload animation
	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_PUMP );

	self.m_flNextAttack	= CurTime() + self.Weapon:SequenceDuration();
	self.m_flNextPrimaryAttack	= CurTime() + self.Weapon:SequenceDuration();

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

	return true

end


/*---------------------------------------------------------
   Name: SWEP:ShootBullet( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootBullet( damage, num_bullets, aimcone )

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecAiming		= pPlayer:GetAimVector();

	local info = { Num = num_bullets, Src = vecSrc, Dir = vecAiming, Spread = aimcone, Tracer = 4, Damage = damage };
	info.Attacker = pPlayer;

	info.Callback = function( attacker, trace, dmginfo )
		if ( self.ShootCallback ) then
			return self:ShootCallback( attacker, trace, dmginfo )
		end
	end

	// Fire the bullets, and force the first shot to be perfectly accuracy
	pPlayer:FireBullets( info );

end


/*---------------------------------------------------------
   Name: SWEP:ShootCallback( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootCallback( attacker, trace, dmginfo )
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

