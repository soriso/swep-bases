

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"
SWEP.AnimPrefix		= "pistol"
SWEP.HoldType		= "pistol"

SWEP.Category					= "Half-Life 2"
SWEP.m_bInHolster				= false;
SWEP.m_bInReload				= false;
SWEP.m_flSoonestPrimaryAttack	= CurTime();
SWEP.m_flAccuracyPenalty		= 0.0;

SWEP.m_flLastAttackTime			= 0.0;
SWEP.viewPunch					= Angle( 0, 0, 0 );

local PISTOL_FASTEST_REFIRE_TIME		= 0.1
local PISTOL_FASTEST_DRY_REFIRE_TIME	= 0.2

local PISTOL_ACCURACY_SHOT_PENALTY_TIME		= 0.2	// Applied amount of time each shot adds to the time we must recover from
local PISTOL_ACCURACY_MAXIMUM_PENALTY_TIME	= 1.5	// Maximum penalty to deal out

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Reload			= Sound( "Weapon_Pistol.Reload" )
SWEP.Primary.Empty			= Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_Pistol.Single" )
SWEP.Primary.Damage			= 12
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.ClipSize		= 18				// Size of a clip
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 18				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.Tracer			= 2
SWEP.Primary.TracerName		= "Tracer"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"



function SWEP:GetBulletSpread()

	local cone;

	local ramp = RemapValClamped(	self.m_flAccuracyPenalty,
										0.0,
										PISTOL_ACCURACY_MAXIMUM_PENALTY_TIME,
										0.0,
										1.0 );

		// We lerp from very accurate to inaccurate over time
	cone = LerpVector( ramp, VECTOR_CONE_1DEGREES, VECTOR_CONE_6DEGREES );

	return cone;

end

/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
		self:SetNPCMinBurst( 1 )
		self:SetNPCMaxBurst( 3 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	self.m_flLastAttackTime = CurTime();
	self.m_flSoonestPrimaryAttack = CurTime() + PISTOL_FASTEST_REFIRE_TIME;

	local pOwner = self.Owner;

	if( pOwner ) then
		// Each time the player fires the pistol, reset the view punch. This prevents
		// the aim from 'drifting off' when the player fires very quickly. This may
		// not be the ideal way to achieve this, but it's cheap and it works, which is
		// great for a feature we're evaluating. (sjb)
		if ( !pOwner:IsNPC() ) then
			// pOwner:ViewPunch( AngleNegate( self.viewPunch ) );
		end
	end

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;
	if (!pPlayer) then
		return;
	end

	if ( self.Weapon:Clip1() <= 0 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:EmitSound( self.Primary.Empty );
			self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );
			timer.Simple( self.Weapon:SequenceDuration(), function()
				self.Weapon:SendWeaponAnim( ACT_VM_IDLE );
			end )

			self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		end

		return;
	end

	// Abort here to handle burst and auto fire modes
	if ( (self.Primary.ClipSize > -1 && self.Weapon:Clip1() == 0) || ( self.Primary.ClipSize <= -1 && !pPlayer:GetAmmoCount(self.Primary.Ammo) ) ) then
		return;
	end

	pPlayer:MuzzleFlash();

	// To make the firing framerate independent, we may have to fire more than one bullet here on low-framerate systems,
	// especially if the weapon we're firing has a really fast rate of fire.
	local iBulletsToFire = 0;
	local fireRate = self.Primary.Delay;

	// MUST call sound before removing a round from the clip of a CHLMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);
	self.Weapon:SetNextPrimaryFire( CurTime() + fireRate );
	self.Weapon:SetNextSecondaryFire( CurTime() + fireRate );
	iBulletsToFire = iBulletsToFire + self.Primary.NumShots;

	// Make sure we don't fire more than the amount in the clip, if this weapon uses clips
	if ( self.Primary.ClipSize > -1 ) then
		if ( iBulletsToFire > self.Weapon:Clip1() ) then
			iBulletsToFire = self.Weapon:Clip1();
		end
		self:TakePrimaryAmmo( self.Primary.NumAmmo );
	end

	self:ShootBullet( self.Primary.Damage, iBulletsToFire, self:GetBulletSpread() );

	//Factor in the view kick
	if ( !pPlayer:IsNPC() ) then
		self:AddViewKick();
	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	// Add an accuracy penalty which can move past our maximum penalty time if we're really spastic
	self.m_flAccuracyPenalty = self.m_flAccuracyPenalty + PISTOL_ACCURACY_SHOT_PENALTY_TIME;

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	return false
end

/*---------------------------------------------------------
   Name: SWEP:FinishReload( )
   Desc: FinishReload
---------------------------------------------------------*/
function SWEP:FinishReload()
	self.m_bInReload = false;
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	local fRet = self.Weapon:DefaultReload( ACT_VM_RELOAD );
	if ( fRet ) then
		self.m_bInReload = true;
		self.Weapon:EmitSound( self.Primary.Reload );
		self.m_flAccuracyPenalty = 0.0;

		timer.Simple( self.Weapon:SequenceDuration(), self.FinishReload, self )
	end
	return fRet;

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:AddViewKick()

	local pPlayer  = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	self.viewPunch = Angle( 0, 0, 0 );

	self.viewPunch.x = math.Rand( 0.25, 0.5 );
	self.viewPunch.y = math.Rand( -.6, .6 );
	self.viewPunch.z = 0.0;

	//Add it to the view punch
	pPlayer:ViewPunch( self.viewPunch );

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:UpdatePenaltyTime( void )

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	// Check our penalty time decay
	if ( ( ( !pOwner:KeyDown( IN_ATTACK ) ) && ( self.m_flSoonestPrimaryAttack < CurTime() ) ) ) then
		self.m_flAccuracyPenalty = self.m_flAccuracyPenalty - FrameTime();
		self.m_flAccuracyPenalty = math.Clamp( self.m_flAccuracyPenalty, 0.0, PISTOL_ACCURACY_MAXIMUM_PENALTY_TIME );
	end

end


/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	self:UpdatePenaltyTime();

	//self.BaseClass:Think();

	if ( self.m_bInReload ) then
		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( pOwner:KeyDown( IN_ATTACK2 ) ) then
		self.m_flLastAttackTime = CurTime() + PISTOL_FASTEST_REFIRE_TIME;
		self.m_flSoonestPrimaryAttack = CurTime() + PISTOL_FASTEST_REFIRE_TIME;
		self.Weapon:SetNextPrimaryFire( CurTime() + PISTOL_FASTEST_REFIRE_TIME );
		self.Weapon:SetNextSecondaryFire( CurTime() + PISTOL_FASTEST_REFIRE_TIME );
	end

	//Allow a refire as fast as the player can click
	if ( ( ( !pOwner:KeyDown( IN_ATTACK ) ) && ( self.m_flSoonestPrimaryAttack < CurTime() ) ) ) then
		if ( !self.m_bInHolster ) then
			self.Weapon:SetNextPrimaryFire( CurTime() - 0.1 );
			self.Weapon:SetNextSecondaryFire( CurTime() - 0.1 );
		end
	end

end


/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )

	self.m_bInHolster	= true;
	self.m_bInReload	= false;

	return true

end

/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	self.m_flSoonestPrimaryAttack	= CurTime() + self.Weapon:SequenceDuration();
	self.m_bInHolster				= true;
	self.m_bInReload				= false;

	timer.Simple( self.Weapon:SequenceDuration(), function()
		self.m_bInHolster = false;
	end )

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

	local pHL2MPPlayer = pPlayer;

		// Fire the bullets
	local info = {};
	info.Num = num_bullets;
	info.Src = pHL2MPPlayer:GetShootPos();
	info.Dir = pPlayer:GetAimVector();
	info.Spread = aimcone;
	info.Damage = damage;
	info.Attacker = pPlayer;
	info.Tracer = self.Primary.Tracer;
	info.TracerName = self.Primary.TracerName;

	info.ShootCallback = self.ShootCallback

	info.Callback = function( attacker, trace, dmginfo )
		return info:ShootCallback( attacker, trace, dmginfo )
	end

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

