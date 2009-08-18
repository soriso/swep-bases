

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_grenade.mdl"
SWEP.WorldModel		= "models/weapons/w_grenade.mdl"
SWEP.AnimPrefix		= "Grenade"
SWEP.HoldType		= "grenade"

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category			= "Half-Life 2"
SWEP.m_bFiresUnderwater	= false

local GRENADE_TIMER	= 2.5 //Seconds

local GRENADE_PAUSED_NO				= 0
local GRENADE_PAUSED_PRIMARY		= 1
local GRENADE_PAUSED_SECONDARY		= 2

local GRENADE_RADIUS	= 4.0 // inches

local GRENADE_DAMAGE_RADIUS = 250.0

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Special1		= Sound( "WeaponFrag.Roll" )
SWEP.Primary.Sound			= Sound( "common/null.wav" )
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "grenade"

SWEP.Secondary.Sound		= Sound( "common/null.wav" )
SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"



/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	self.BaseClass:Precache();

	util.PrecacheSound( "WeaponFrag.Throw" );
	util.PrecacheSound( "WeaponFrag.Roll" );

end

if ( !CLIENT ) then
//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pEvent -
//			*pOperator -
//-----------------------------------------------------------------------------
function SWEP:Operator_HandleAnimEvent( pEvent, pOperator )

	local pOwner = self.Owner;
	self.fThrewGrenade = false;

	if( pEvent ) then
		if pEvent == "EVENT_WEAPON_SEQUENCE_FINISHED" then
			self.m_fDrawbackFinished = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW" then
			self:ThrowGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW2" then
			self:RollGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW3" then
			self:LobGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		else
			return;
	end

local RETHROW_DELAY	= self.Primary.Delay
	if( self.fThrewGrenade ) then
		self.m_flNextPrimaryAttack	= CurTime() + RETHROW_DELAY;
		self.m_flNextSecondaryAttack	= CurTime() + RETHROW_DELAY;
		self.m_flTimeWeaponIdle = FLT_MAX; //NOTE: This is set once the animation has finished up!
	end

end

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

	if ( self.m_bRedraw ) then
		return;
	end

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	// Note that this is a primary attack and prepare the grenade attack to pause.
	self.m_AttackPaused = GRENADE_PAUSED_PRIMARY;
	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH );

	// Put both of these off indefinitely. We do not know how long
	// the player will hold the grenade.
	self.m_flTimeWeaponIdle = FLT_MAX;
	self.m_flNextPrimaryAttack = FLT_MAX;

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if ( self.m_bRedraw ) then
		return;
	end

	if ( self:Ammo1() <= 0 ) then
		return;
	end

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	// Note that this is a secondary attack and prepare the grenade attack to pause.
	self.m_AttackPaused = GRENADE_PAUSED_SECONDARY;
	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_LOW );

	// Don't let weapon idle interfere in the middle of a throw!
	self.m_flTimeWeaponIdle = FLT_MAX;
	self.m_flNextSecondaryAttack	= FLT_MAX;

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pOwner -
//-----------------------------------------------------------------------------
function SWEP:DecrementAmmo( pOwner )

	pOwner:RemoveAmmo( 1, self.Primary.Ammo );

end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self:Ammo1() <= 0 ) then
		return false;
	end

	if ( ( self.m_bRedraw ) && ( self.m_flNextPrimaryAttack <= CurTime() ) && ( self.m_flNextSecondaryAttack <= CurTime() ) ) then
		//Redraw the weapon
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW );

		//Update our times
		self.m_flNextPrimaryAttack	= CurTime() + self.Weapon:SequenceDuration();
		self.m_flNextSecondaryAttack	= CurTime() + self.Weapon:SequenceDuration();
		self.m_flTimeWeaponIdle = CurTime() + self.Weapon:SequenceDuration();

		//Mark this as done
		self.m_bRedraw = false;
	end

	return true;

end


/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	if( self.m_fDrawbackFinished ) then
		local pOwner = self.Owner;

		if (pOwner) then
			if( m_AttackPaused ) then
			if m_AttackPaused == GRENADE_PAUSED_PRIMARY then
				if( !(pOwner:KeyDown( IN_ATTACK )) ) then
					self.Weapon:SendWeaponAnim( ACT_VM_THROW );
					pOwner:DoAnimationEvent( "PLAYERANIMEVENT_ATTACK_PRIMARY" );

					//Tony; fire the sequence
					self.m_fDrawbackFinished = false;
				end
				return;

			elseif m_AttackPaused == GRENADE_PAUSED_SECONDARY then
				if( !(pOwner:KeyDown( IN_ATTACK2 )) ) then
					//See if we're ducking
					if ( pOwner:KeyDown( IN_DUCK ) ) then
						//Send the weapon animation
						self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
					else
						//Send the weapon animation
						self.Weapon:SendWeaponAnim( ACT_VM_HAULBACK );
					end
					//Tony; the grenade really should have a secondary anim. but it doesn't on the player.
					pOwner:DoAnimationEvent( "PLAYERANIMEVENT_ATTACK_PRIMARY" );

					self.m_fDrawbackFinished = false;
				end
				return;

			else
				return;
			end
			end
		end
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

	if ( self.m_bRedraw ) then
		self:Reload();
	end

end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.m_bRedraw = false;
	self.m_fDrawbackFinished = false;

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	return true

end


	// check a throw from vecSrc.  If not valid, move the position back along the line to vecEye
function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )

	local tr;

	tr = util.TraceHull( vecEye, vecSrc, -Vector(GRENADE_RADIUS+2,GRENADE_RADIUS+2,GRENADE_RADIUS+2), Vector(GRENADE_RADIUS+2,GRENADE_RADIUS+2,GRENADE_RADIUS+2),
		pPlayer:PhysicsSolidMaskForEntity(), pPlayer, pPlayer:GetCollisionGroup() );

	if ( tr.Hit ) then
		vecSrc = tr.endpos;
	end

end

function SWEP:DropPrimedFragGrenade( pPlayer, pGrenade )

	local pWeaponFrag = pGrenade;

	if ( pWeaponFrag ) then
		self:ThrowGrenade( pPlayer );
		self:DecrementAmmo( pPlayer );
	end

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pPlayer -
//-----------------------------------------------------------------------------
function SWEP:ThrowGrenade( pPlayer )

if ( !CLIENT ) then
	local	vecEye = pPlayer:EyePos();
	local	vForward, vRight;

	vForward = pPlayer:GetAimVector();
	vRight = pPlayer:GetAimVector();
	local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0;
	self:CheckThrowPosition( pPlayer, vecEye, vecSrc );
//	vForward[0] += 0.1f;
	vForward.y = vForward.y + 0.1;

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vForward * 1200;
	local pGrenade = Fraggrenade_Create( vecSrc, vec3_angle, vecThrow, AngularImpulse(600,math.random(-1200,1200),0), pPlayer, GRENADE_TIMER, false );

	if ( pGrenade ) then
		if ( pPlayer && !pPlayer:Alive() ) then
			vecThrow = pPlayer:GetVelocity();

			local pPhysicsObject = pGrenade:GetPhysicsObject();
			if ( pPhysicsObject ) then
				vecThrow = pPhysicsObject:SetVelocity();
			end
		end

		pGrenade:SetDamage( self.Primary.Damage );
		pGrenade:SetDamageRadius( GRENADE_DAMAGE_RADIUS );
	end
end

	self.m_bRedraw = true;

	self.Weapon:EmitSound( self.Primary.Sound );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pPlayer -
//-----------------------------------------------------------------------------
function SWEP:LobGrenade( pPlayer )

if ( !CLIENT ) then
	local	vecEye = pPlayer:EyePos();
	local	vForward, vRight;

	vForward = pPlayer:GetAimVector();
	vRight = pPlayer:GetAimVector();
	local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0 + Vector( 0, 0, -8 );
	self:CheckThrowPosition( pPlayer, vecEye, vecSrc );

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vForward * 350 + Vector( 0, 0, 50 );
	local pGrenade = Fraggrenade_Create( vecSrc, vec3_angle, vecThrow, AngularImpulse(200,math.random(-600,600),0), pPlayer, GRENADE_TIMER, false );

	if ( pGrenade ) then
		pGrenade:SetDamage( self.Primary.Damage );
		pGrenade:SetDamageRadius( GRENADE_DAMAGE_RADIUS );
	end
end

	self.Weapon:EmitSound( self.Secondary.Sound );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.m_bRedraw = true;

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pPlayer -
//-----------------------------------------------------------------------------
function SWEP:RollGrenade( pPlayer )

if ( !CLIENT ) then
	// BUGBUG: Hardcoded grenade width of 4 - better not change the model :)
	local vecSrc;
	vecSrc = pPlayer:CollisionProp():NormalizedToWorldSpace( Vector( 0.5, 0.5, 0.0 ) );
	vecSrc.z = vecSrc.z + GRENADE_RADIUS;

	local vecFacing = pPlayer:BodyDirection2D( );
	// no up/down direction
	vecFacing.z = 0;
	VectorNormalize( vecFacing );
	local tr;
	tr = util.QuickTrace( vecSrc, vecSrc - Vector(0,0,16), MASK_PLAYERSOLID, pPlayer, COLLISION_GROUP_NONE );
	if ( tr.fraction != 1.0 ) then
		// compute forward vec parallel to floor plane and roll grenade along that
		local tangent;
		CrossProduct( vecFacing, tr.plane.normal, tangent );
		CrossProduct( tr.plane.normal, tangent, vecFacing );
	end
	vecSrc = vecSrc + (vecFacing * 18.0);
	self:CheckThrowPosition( pPlayer, pPlayer:WorldSpaceCenter(), vecSrc );

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vecFacing * 700;
	// put it on its side
	local orientation = Angle(0,pPlayer:GetLocalAngles().y,-90);
	// roll it
	local rotSpeed = Vector(0,0,720);
	local pGrenade = Fraggrenade_Create( vecSrc, orientation, vecThrow, rotSpeed, pPlayer, GRENADE_TIMER, false );

	if ( pGrenade ) then
		pGrenade:SetDamage( self.Primary.Damage );
		pGrenade:SetDamageRadius( GRENADE_DAMAGE_RADIUS );
	end

end

	self.Weapon:EmitSound( self.Primary.Special1 );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.m_bRedraw = true;

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

