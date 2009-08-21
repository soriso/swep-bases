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

//-----------------------------------------------------------------------------
// Normalization
//-----------------------------------------------------------------------------

// FIXME: Can't use until we're un-macroed in mathlib.h
function VectorNormalize( v )
	local l = v:Length();
	if (l != 0.0) then
		v = v / l;
	else
		// FIXME:
		// Just copying the existing implemenation; shouldn't res.z == 0?
		v.x = 0.0;
		v.y = 0.0; v.z = 1.0;
	end
	return l;
end


function CrossProduct(a, b)
	return Vector( a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x );
end

function RandomAngle( minVal, maxVal )
	local random = vec3_angle;
	random.pitch = math.Rand( minVal, maxVal );
	random.yaw   = math.Rand( minVal, maxVal );
	random.roll  = math.Rand( minVal, maxVal );
	local ret = Angle( random.pitch, random.yaw, random.roll );
	return ret;
end

