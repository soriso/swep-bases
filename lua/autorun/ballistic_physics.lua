
local meta = FindMetaTable( "Entity" )
if (!meta) then return end

meta.FireMelee	= meta.g_FireBullets || meta.FireBullets

function util.ImpactTrace( traceHit, pPlayer )

	if ( traceHit.MatType == MAT_GRATE ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local info			= {};
	info.Src			= vecSrc;
	info.Dir			= vecDirection;
	info.Num			= 1;
	info.Damage			= 0;
	info.Force			= 0;
	info.Tracer			= 0;

	return pPlayer:FireMelee( info );

end
