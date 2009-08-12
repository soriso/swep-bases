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


function VectorAdd( a, b, c )
	if ( !IsValid(a) ) then return end;
	if ( !IsValid(b) ) then return end;
	local c = c || vec3_origin
	c.x = a.x + b.x;
	c.y = a.y + b.y;
	c.z = a.z + b.z;
	return c
end

function VectorSubtract( a, b, c )
	if ( !IsValid(a) ) then return end;
	if ( !IsValid(b) ) then return end;
	local c = c || vec3_origin
	c.x = a.x - b.x;
	c.y = a.y - b.y;
	c.z = a.z - b.z;
	return c
end

function VectorMultiply( a, b, c )
	if ( !IsValid(a) ) then return end;
	if ( !IsValid(b) ) then return end;
	local c = c || vec3_origin
	c.x = a.x * b.x;
	c.y = a.y * b.y;
	c.z = a.z * b.z;
	return c
end

// for backwards compatability
function VectorScale ( input, scale, result )
	return VectorMultiply( input, scale, result );
end

function RandomAngle( minVal, maxVal )
	local random = vec3_angle;
	random.pitch = math.Rand( minVal, maxVal );
	random.yaw   = math.Rand( minVal, maxVal );
	random.roll  = math.Rand( minVal, maxVal );
	local ret = Angle( random.pitch, random.yaw, random.roll );
	return ret;
end

