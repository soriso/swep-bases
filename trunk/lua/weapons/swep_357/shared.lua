

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_357.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.AnimPrefix		= "python"
SWEP.HoldType		= "pistol"

SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Empty			= Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_357.Single" )
SWEP.Primary.Damage			= 75
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= 6					// Size of a clip
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 6					// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "357"

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

	if ( self.m_bIsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:EmitSound( self.Primary.Empty );
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );

		return;
	end

	self.Weapon:EmitSound( self.Primary.Sound );
	pPlayer:MuzzleFlash();

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	self:TakePrimaryAmmo( 1 );

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone );

	//Disorient the player
	local angles = pPlayer:EyeAngles();

	angles.pitch = angles.pitch + math.random( -1, 1 );
	angles.yaw   = angles.yaw   + math.random( -1, 1 );
	angles.roll  = 0;

	if ( pPlayer:IsNPC() ) then return end

if ( !CLIENT ) then
	pPlayer:SnapEyeAngles( angles );
end

	pPlayer:ViewPunch( Angle( -8, math.Rand( -2, 2 ), 0 ) );

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

