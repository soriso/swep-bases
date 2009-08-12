

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_smg1.mdl"
SWEP.AnimPrefix		= "smg2"
SWEP.HoldType		= "smg"

SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= false;
SWEP.m_fFireDuration	= 0.0;

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Reload			= Sound( "Weapon_SMG1.Reload" )
SWEP.Primary.Empty			= Sound( "Weapon_SMG1.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_SMG1.Single" )
SWEP.Primary.Damage			= 12
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= VECTOR_CONE_5DEGREES
SWEP.Primary.ClipSize		= 45				// Size of a clip
SWEP.Primary.Delay			= 0.075
SWEP.Primary.DefaultClip	= 45				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Tracer			= 2
SWEP.Primary.TracerName		= "Tracer"

SWEP.Secondary.Empty		= SWEP.Primary.Empty
SWEP.Secondary.Sound		= Sound( "Weapon_SMG1.Double" )
SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.Delay		= 0.5
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "SMG1_Grenade"



/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
		self:SetNPCMinBurst( 2 )
		self:SetNPCMaxBurst( 5 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

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

	if ( self.Weapon:Clip1() <= 0 ) then
		if ( self:Ammo1() > 0 ) then
			self.Weapon:EmitSound( self.Primary.Empty );
			self:Reload();
		else
			self.Weapon:EmitSound( self.Primary.Empty );
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		end

		return;
	end

	if ( self.IsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );

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
	iBulletsToFire = iBulletsToFire + self.Primary.NumShots;

	// Make sure we don't fire more than the amount in the clip, if this weapon uses clips
	if ( self.Primary.ClipSize > -1 ) then
		if ( iBulletsToFire > self.Weapon:Clip1() ) then
			iBulletsToFire = self.Weapon:Clip1();
		end
		self:TakePrimaryAmmo( self.Primary.NumAmmo );
	end

	self:ShootBullet( self.Primary.Damage, iBulletsToFire, self.Primary.Cone );

	//Factor in the view kick
	if ( !pPlayer:IsNPC() ) then
		self:AddViewKick();
	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:DoMachineGunKick( pPlayer, dampEasy, maxVerticleKickAngle, fireDurationTime, slideLimitTime )

	local	KICK_MIN_X			= 0.2	//Degrees
	local	KICK_MIN_Y			= 0.2	//Degrees
	local	KICK_MIN_Z			= 0.1	//Degrees

	local vecScratch = Vector( 0, 0, 0 );

	//Find how far into our accuracy degradation we are
	local duration;
	if ( fireDurationTime > slideLimitTime ) then
		duration	= slideLimitTime
	else
		duration	= fireDurationTime;
	end
	local kickPerc = duration / slideLimitTime;

	//Apply this to the view angles as well
	vecScratch.x = -( KICK_MIN_X + ( maxVerticleKickAngle * kickPerc ) );
	vecScratch.y = -( KICK_MIN_Y + ( maxVerticleKickAngle * kickPerc ) ) / 3;
	vecScratch.z = KICK_MIN_Z + ( maxVerticleKickAngle * kickPerc ) / 8;

	//Wibble left and right
	if ( math.random( -1, 1 ) >= 0 ) then
		vecScratch.y = vecScratch.y * -1;
	end

	//Wobble up and down
	if ( math.random( -1, 1 ) >= 0 ) then
		vecScratch.z = vecScratch.z * -1;
	end

	//Clip this to our desired min/max
	// vecScratch = UTIL_ClipPunchAngleOffset( vecScratch, vec3_angle, Angle( 24.0, 3.0, 1.0 ) );

	//Add it to the view punch
	// NOTE: 0.5 is just tuned to match the old effect before the punch became simulated
	pPlayer:ViewPunch( vecScratch * 0.5 );

end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	//Must have ammo
	if ( ( pPlayer:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) || ( ( pPlayer:WaterLevel() == 3 ) && !self.m_bFiresUnderwater ) ) then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );
		self.Weapon:EmitSound( self.Secondary.Empty );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay );
		return;
	end

	// MUST call sound before removing a round from the clip of a CMachineGun
	self.Weapon:EmitSound( self.Secondary.Sound );

	local vecSrc = pPlayer:GetShootPos();
	local	vecThrow;
	// Don't autoaim on grenade tosses
	vecThrow = pPlayer:GetAimVector();
	vecThrow = vecThrow * 1000.0;

if ( !CLIENT ) then
	//Create the grenade
	local pGrenade = ents.Create( "grenade_ar2" );
	pGrenade:SetPos( vecSrc );
	pGrenade:SetOwner( pPlayer );
	pGrenade:SetVelocity( vecThrow );

	pGrenade:Spawn()
	pGrenade:SetAngles( RandomAngle( -400, 400 ) );
	//pGrenade:SetAngleVelocity( RandomAngle( -400, 400 ) );
	pGrenade:SetMoveType( MOVETYPE_FLYGRAVITY );
	pGrenade:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE );
	pGrenade:SetOwner( self.Owner );
end

	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );


	// Decrease ammo
	pPlayer:RemoveAmmo( 1, self.Secondary.Ammo );

	// Can shoot again immediately
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 );

	// Can blow up after a short delay (so have time to release mouse button)
	self.Weapon:SetNextSecondaryFire( CurTime() + 1.0 );

end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	local fRet;
	local fCacheTime = self.Secondary.Delay;

	self.m_fFireDuration = 0.0;

	fRet = self.Weapon:DefaultReload( ACT_VM_RELOAD );
	if ( fRet ) then
		// Undo whatever the reload process has done to our secondary
		// attack timer. We allow you to interrupt reloading to fire
		// a grenade.
		self.Weapon:SetNextSecondaryFire( CurTime() + fCacheTime );

		self.Weapon:EmitSound( self.Primary.Reload );

	end

	return fRet;

end


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
function SWEP:AddViewKick()

	local	EASY_DAMPEN			= 0.5
	local	MAX_VERTICAL_KICK	= 1.0	//Degrees
	local	SLIDE_LIMIT			= 2.0	//Seconds

	//Get the view kick
	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	self:DoMachineGunKick( pPlayer, EASY_DAMPEN, MAX_VERTICAL_KICK, self.m_fFireDuration, SLIDE_LIMIT );

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
		self.IsUnderwater = true;
	else
		self.IsUnderwater = false;
	end

	if ( pPlayer:KeyDown( IN_ATTACK ) ) then
		self.m_fFireDuration = self.m_fFireDuration + FrameTime();
	elseif ( !pPlayer:KeyDown( IN_ATTACK ) ) then
		self.m_fFireDuration = 0.0;
	end

end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	self.m_fFireDuration = 0.0;

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
	info.Tracer = self.Primary.Tracer;
	info.TracerName = self.Primary.TracerName;

	info.ShootCallback = self.ShootCallback

	info.Callback = function( attacker, trace, dmginfo )
		if ( info.ShootCallback ) then
			return info:ShootCallback( attacker, trace, dmginfo )
		end
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

