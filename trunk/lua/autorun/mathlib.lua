//===== Copyright © 1996-2005, Valve Corporation, All rights reserved. ======//
//
// Purpose:
//
//===========================================================================//

function RemapValClamped( val, A, B, C, D)
	if ( A == B ) then
		if ( val >= B ) then
			return D;
		else
			return C;
		end
	end
	local cVal = (val - A) / (B - A);
	cVal = math.Clamp( cVal, 0.0, 1.0 );

	return C + (D - C) * cVal;
end



// MATH_BASE_H

