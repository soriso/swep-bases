
local meta = FindMetaTable( "Entity" )
if (!meta) then return end
if (meta.g_FireBullets && meta.FireMelee) then return end

meta.g_FireBullets		= meta.FireBullets
meta.FireMelee			= meta.FireBullets

local phys_bullets		= CreateConVar( "phys_bullets", 0, { FCVAR_REPLICATED } )

function meta:FireBullets( data )

	if ( !phys_bullets:GetBool() ) then return self:g_FireBullets( data ) end
	if ( CLIENT ) then return end

	if ( !data.Num ) then
		data.Num = 1
	end

	for i = 1, data.Num do

		local Src		= data.Spread || vec3_origin
		local Dir		= data.Dir + Vector( math.Rand( -Src.x, Src.x ), math.Rand( -Src.y, Src.y ), math.Rand( -Src.y, Src.y ) )
		local info		= ents.Create( "prop_bullet" )

		info:SetPos( data.Src + ( Dir * 32 ) )
		info:SetAngles( Dir:Angle() )

		info.Attacker	= data.Attacker
		info.Dir		= Dir
		info.Damage		= data.Damage
		info.Force		= data.Force
		info.Callback	= data.Callback
		info.Num		= data.Num
		info.Owner		= self

		info:Spawn()

		local phys = info:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetVelocity( info:GetForward() * server_settings.Int( "bulletspeed", 6000 ) )
		end

	end

end

local function phys_bullets_clear( player )

	if ( !player:IsAdmin() ) then return end

	if ( CLIENT ) then return end

	for k, v in pairs( ents.FindByClass( "prop_bullet" ) ) do

		v:Remove()

	end

end

concommand.Add( "phys_bullets_clear", phys_bullets_clear )

function meta:FirePenetratingBullets( attacker, trace, dmginfo )

	/*
	// Don't go through metal
	if ( trace.MatType == MAT_METAL	||
		 trace.MatType == MAT_SAND ) then return end
	*/

	local Penetration	= self.Penetration	|| 1

	// Direction (and length) that we are gonna penetrate
	local Dir			= trace.Normal * 16;

	if ( trace.MatType == MAT_ALIENFLESH	||
		 trace.MatType == MAT_DIRT			||
		 trace.MatType == MAT_FLESH			||
		 trace.MatType == MAT_WOOD ) then -- dirt == plaster, and wood should be easier to penetrate so increase the distance
		Dir = trace.Normal * ( 16 * Penetration );
	end

	if ( !attacker:IsValid() ) then return end
	if ( !dmginfo:IsBulletDamage() ) then return end

	local t				= {}
	t.start				= trace.HitPos + Dir
	t.endpos			= trace.HitPos
	t.filter			= self.Owner
	t.mask				= MASK_SHOT

	local tr			= util.TraceLine( t )

	// Bullet didn't penetrate.
	if ( tr.StartSolid			||
		 tr.Fraction	>= 1.0	||
		 trace.Fraction	<= 0.0 ) then return end

	// Fire bullet from the exit point using the original tradjectory
	local info		= {}
	info.Src		= tr.HitPos
	info.Attacker	= attacker
	info.Dir		= trace.Normal
	info.Spread		= vec3_origin
	info.Num		= 1
	info.Damage		= dmginfo:GetDamage()

	info.Callback = function( attacker, trace, dmginfo )
		return self:FirePenetratingBullets( attacker, trace, dmginfo )
	end;

	info.Tracer		= 0

	self:FireBullets( info )

	return {

		damage	= true,
		effects	= true

	}

end

function util.ImpactTrace( traceHit, pPlayer )

	if ( traceHit.MatType == MAT_GRATE ) then
		return;
	end

	local vecSrc		= traceHit.StartPos;
	local vecDirection	= traceHit.Normal;

	if ( pPlayer && pPlayer:IsPlayer() ) then
		vecSrc			= pPlayer:GetShootPos();
		vecDirection	= pPlayer:GetAimVector();
	else
		pPlayer			= GetWorldEntity()
	end

	local info			= {};
	info.Src			= vecSrc;
	info.Dir			= vecDirection;
	info.Num			= 1;
	info.Damage			= 0;
	info.Force			= 0;
	info.Tracer			= 0;

	return pPlayer:g_FireBullets( info );

end
