

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "HAMMER"
	SWEP.Author				= "Andrew McWatters"
	SWEP.IconLetter			= "!"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_stunstick"
SWEP.Category			= "Base Examples"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Primary.Delay			= 0.4

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
		pPlayer:LagCompensation( true );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

		self.m_flNextAttack = CurTime() + self.Primary.Delay;

		util.ImpactTrace( traceHit, pPlayer );

		if ( SERVER ) then
			pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -40 ), Vector( 16, 16, 16 ), traceHit.Entity:Health(), self.Primary.DamageType, self.Primary.Force, false );
		end

		self:ImpactEffect( traceHit );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:LagCompensation( false );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	self.m_flNextAttack = CurTime() + self.Primary.Delay;

end
