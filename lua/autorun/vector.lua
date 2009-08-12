//====== Copyright © 1996-2005, Valve Corporation, All rights reserved. =======//
//
// Purpose:
//
// $NoKeywords: $
//
//=============================================================================//

//-----------------------------------------------------------------------------
//
// Inlined Vector methods
//
//-----------------------------------------------------------------------------


function RandomAngle( minVal, maxVal )
	local random = vec3_angle;
	random.pitch = math.Rand( minVal, maxVal );
	random.yaw   = math.Rand( minVal, maxVal );
	random.roll  = math.Rand( minVal, maxVal );
	local ret = Angle( random.pitch, random.yaw, random.roll );
	return ret;
end

