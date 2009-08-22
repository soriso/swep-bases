

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

	resource.AddFile( "sound/76_-_hammer.mp3" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "HAMMER"
	SWEP.Author				= "Andrew McWatters"
	SWEP.IconLetter			= "!"

	killicon.AddFont( string.Replace( GetScriptPath(), "weapons/", "" ), "HL2MPTypeDeath", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end


SWEP.Base				= "swep_stunstick"
SWEP.Category			= "Base Examples"
SWEP.m_flNextAttack		= CurTime()

local Weapon_Sound		= Sound( "76_-_hammer.mp3" )

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Force			= 65535
SWEP.Primary.Delay			= 0.4

function SWEP:Swing()

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

		if ( SERVER ) then
			if ( traceHit.Entity && traceHit.Entity:IsPlayer() ) then

				local ply = traceHit.Entity

				ply:SetArmor( 0 )

			end
		end

		self.Weapon:EmitSound( self.Primary.Hit );

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:LagCompensation( true );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.m_flNextAttack = CurTime() + self.Primary.Delay;

		util.ImpactTrace( traceHit, pPlayer );

		if ( SERVER ) then
			pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -16, -16, -40 ), Vector( 16, 16, 16 ), traceHit.Entity:Health(), self.Primary.DamageType, self.Primary.Force * traceHit.Entity:Health(), false );
		end

		self:ImpactEffect( traceHit );

		return

	end

	self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );
	pPlayer:LagCompensation( false );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.m_flNextAttack = CurTime() + self.Primary.Delay;

end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()

	if ((self.m_flNextAttack < CurTime())) then
		self:Swing();
		self.m_flNextAttack = CurTime() + self.Primary.Delay;
	end

end

function SWEP:ImpactEffect( traceHit )

	self.BaseClass:ImpactEffect( traceHit )

	local data = EffectData()
			data:SetNormal( traceHit.HitNormal )
			data:SetOrigin( traceHit.HitPos + ( traceHit.HitNormal * 1.0 ) )
	if (!traceHit.Entity) then return end
	if (!traceHit.Entity:IsValid()) then return end
	util.Effect( "HelicopterMegaBomb", data )

end

function SWEP:Holster( wep )
	return false
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	self.m_flNextAttack = CurTime() + self.Weapon:SequenceDuration();

	if (!self.Sound) then
		self.Sound = CreateSound( self.Weapon, Weapon_Sound )
	end

	self.Sound:Play()

	timer.Simple( 23, function()

		local Weapon = self.Weapon
		local pOwner = self.Owner

		if (!Weapon) then return end
		if (!Weapon:IsValid()) then return end

		if ( !pOwner ) then
			return;
		end

		if ( !CLIENT ) then
			Weapon:Remove()
		end
		pOwner:ConCommand( "lastinv" )

	end )

	return true

end

function SWEP:OnRemove()

	if (self.Sound) then
		self.Sound:Stop()
	end

end

function SWEP:OnDrop()

	if ( ValidEntity( self.Weapon ) ) then
		self.Weapon:Remove()
	end

end
