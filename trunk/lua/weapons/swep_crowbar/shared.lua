

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.AnimPrefix		= "crowbar"
SWEP.HoldType		= "melee"

SWEP.Category			= "Half-Life 2"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound			= Sound( "Weapon_Crowbar.Single" )
SWEP.Primary.Hit			= Sound( "Weapon_Crowbar.Melee_Hit" )
SWEP.Primary.Damage			= 25.0
SWEP.Primary.Force			= 0.75
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= 0.4
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= true				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "None"

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
	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * 75.0 )
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		self.Weapon:EmitSound( self.Primary.Hit );

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

		util.ImpactTrace( traceHit, pPlayer );

		if ( SERVER ) then
			pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -16 ), Vector( 36, 36, 36 ), self.Primary.Damage, DMG_CLUB, self.Primary.Force );
		end

		// self:AddViewKick();

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

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
	return false
end

//-----------------------------------------------------------------------------
// Purpose: Add in a view kick for this weapon
//-----------------------------------------------------------------------------
function SWEP:AddViewKick( void )

	local pPlayer  = self:GetOwner();

	if ( pPlayer == NULL ) then
		return;
	end

	if ( pPlayer:IsNPC() ) then
		return;
	end

	local punchAng = Angle( 0, 0 ,0 );

	punchAng.pitch = math.Rand( 1.0, 2.0 );
	punchAng.yaw   = math.Rand( -2.0, -1.0 );
	punchAng.roll  = 0.0;

	pPlayer:ViewPunch( punchAng );

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

