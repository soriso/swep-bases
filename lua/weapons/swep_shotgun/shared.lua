

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

SWEP.Category				= "Half-Life 2"
SWEP.m_bFiresUnderwater		= false;
SWEP.m_flNextAttack 		= CurTime();
SWEP.m_flNextPrimaryAttack 	= CurTime();

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
SWEP.Secondary.NumShots		= 12
SWEP.Secondary.NumAmmo		= 2
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

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
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

	if (self.m_bNeedPump) then
		return;
	end

	// MUST call sound before removing a round from the clip of a CMachineGun
	self.Weapon:EmitSound(self.Primary.Sound);

	pPlayer:MuzzleFlash();

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	// Don't fire again until fire animation has completed
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
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

	// Only the player fires this way so we can cast
	local pPlayer = self.Owner;

	if (!pPlayer) then
		return;
	end

	if (self.m_bNeedPump) then
		return;
	end

	// MUST call sound before removing a round from the clip of a CMachineGun
	self.Weapon:EmitSound(self.Secondary.Sound);

	pPlayer:MuzzleFlash();

	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );

	// Don't fire again until fire animation has completed
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.m_flNextPrimaryAttack = CurTime() + self.Weapon:SequenceDuration();
	self:TakePrimaryAmmo( self.Secondary.NumAmmo );	// Shotgun uses same clip for primary and secondary attacks

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );


	self:ShootBullet( self.Secondary.Damage, self.Secondary.NumShots, self:GetBulletSpread() );
	pPlayer:ViewPunch( Angle(math.Rand( -5, 5 ),0,0) );

	self.m_bNeedPump = true;

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

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
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
		return Msg("ERROR: Shotgun Reload called incorrectly!\n");
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

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
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

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
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
			pOwner:RemoveAmmo( 1, self.Primary.Ammo );
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

	if ( self.m_bDelayedReload ) then
		self.m_bDelayedReload = false;
		self:StartReload();
	end

	self.Weapon:EmitSound( self.Primary.Special1 );

	// Finish reload animation
	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_PUMP );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
	self.m_flNextAttack	= CurTime() + self.Weapon:SequenceDuration();
	self.m_flNextPrimaryAttack	= CurTime() + self.Weapon:SequenceDuration();

end

/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	local pOwner = self.Owner;
	if (!pOwner) then
		return;
	end

	if ( self.m_bNeedPump && ( pOwner:KeyDown( IN_RELOAD ) ) ) then
		self.m_bDelayedReload = true;
	end

	if (self.m_bInReload) then
		// If I'm primary firing and have one round stop reloading and fire
		if ((pOwner:KeyDown( IN_ATTACK ) ) && (self.Weapon:Clip1() >=1) && !self.m_bNeedPump ) then
			self.m_bInReload		= false;
			self.m_bNeedPump		= false;
			self.m_bDelayedFire1 	= true;
		// If I'm secondary firing and have two rounds stop reloading and fire
		elseif ((pOwner:KeyDown( IN_ATTACK2 ) ) && (self.Weapon:Clip1() >=2) && !self.m_bNeedPump ) then
			self.m_bInReload		= false;
			self.m_bNeedPump		= false;
			self.m_bDelayedFire2 	= true;
		elseif (self.m_flNextPrimaryAttack <= CurTime()) then
			// If out of ammo end reload
			if (pOwner:GetAmmoCount(self.Primary.Ammo) <=0) then
				self:FinishReload();
				return;
			end
			// If clip not full reload again
			if (self.Weapon:Clip1() < self.Primary.ClipSize) then
				self:Reload();
				return;
			// Clip full, stop reloading
			else
				self:FinishReload();
				return;
			end
		end
	else
		// Make shotgun shell invisible
		self.Weapon:SetBodygroup(1,1);
	end

	if ((self.m_bNeedPump) && (self.m_flNextPrimaryAttack <= CurTime())) then
		self:Pump();
		return;
	end

	// Shotgun uses same timing and ammo for secondary attack
	if ((self.m_bDelayedFire2 || pOwner:KeyDown( IN_ATTACK2 ))&&(self.m_flNextPrimaryAttack <= CurTime())) then
		self.m_bDelayedFire2 = false;

		if ( (self.Weapon:Clip1() <= 1 && self.Primary.ClipSize != -1)) then
			// If only one shell is left, do a single shot instead
			if ( self.Weapon:Clip1() == 1 ) then
				self:PrimaryAttack();
			elseif (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
				self:DryFire();
			else
				self:StartReload();
			end

		// Fire underwater?
		elseif (self.Owner:WaterLevel() == 3 && self.m_bFiresUnderwater == false) then
			self.Weapon:EmitSound(self.Primary.Empty);
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );
			self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
			self.m_flNextPrimaryAttack = CurTime() + 0.2;
			return;
		else
			// If the firing button was just pressed, reset the firing time
			if ( pOwner:KeyPressed( IN_ATTACK ) ) then
				 self.Weapon:SetNextPrimaryFire( CurTime() );
				 self.Weapon:SetNextSecondaryFire( CurTime() );
				 self.m_flNextPrimaryAttack = CurTime();
			end
			self:SecondaryAttack();
		end
	elseif ( (self.m_bDelayedFire1 || pOwner:KeyDown( IN_ATTACK )) && self.m_flNextPrimaryAttack <= CurTime()) then
		self.m_bDelayedFire1 = false;
		if ( (self.Weapon:Clip1() <= 0 && self.Primary.ClipSize != -1) || ( self.Primary.ClipSize == -1 && pOwner:GetAmmoCount(self.Primary.Ammo) <= 0 ) ) then
			if (pOwner:GetAmmoCount(self.Primary.Ammo) <= 0) then
				self:DryFire();
			else
				self:StartReload();
			end
		// Fire underwater?
		elseif (pOwner:WaterLevel() == 3 && self.m_bFiresUnderwater == false) then
			self.Weapon:EmitSound(self.Primary.Empty);
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );
			self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
			self.m_flNextPrimaryAttack = CurTime() + 0.2;
			return;
		else
			// If the firing button was just pressed, reset the firing time
			local pPlayer = self.Owner;
			if ( pPlayer && pPlayer:KeyPressed( IN_ATTACK ) ) then
				 self.Weapon:SetNextPrimaryFire( CurTime() );
				 self.Weapon:SetNextSecondaryFire( CurTime() );
				 self.m_flNextPrimaryAttack = CurTime();
			end
			self:PrimaryAttack();
		end
	end

	if ( pOwner:KeyPressed( IN_RELOAD ) && self.Primary.ClipSize != -1 && !self.m_bInReload ) then
		// reload when reload is pressed, or if no buttons are down and weapon is empty.
		self:StartReload();
	else
		// no fire buttons down
		self.m_bFireOnEmpty = false;

		if ( self:Ammo1() <= 0 && self.m_flNextPrimaryAttack < CurTime() ) then
			return;
		else
			// weapon is useable. Reload if empty and weapon has waited as long as it has to after firing
			if ( self.Weapon:Clip1() <= 0 && self.m_flNextPrimaryAttack < CurTime() ) then
				if (self:StartReload()) then
					// if we've successfully started to reload, we're done
					return;
				end
			end
		end

		return;
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
	self.m_flNextAttack = CurTime() + speed;
	self.m_flNextPrimaryAttack = CurTime() + speed;

end

