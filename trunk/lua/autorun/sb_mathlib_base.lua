//===== Copyright © 1996-2005, Valve Corporation, All rights reserved. ======//
//
// Purpose: Math primitives.
//
//===========================================================================//

s_bMathlibInitialized = false;

vec3_origin = Vector(0,0,0);
vec3_angle = Angle(0,0,0);
vec3_invalid = Vector( FLT_MAX, FLT_MAX, FLT_MAX );
nanmask = 255<<23;

//-----------------------------------------------------------------------------
// Purpose:
// Input  :
//-----------------------------------------------------------------------------

function Catmull_Rom_Spline(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	assert( s_bMathlibInitialized );
	local tSqr = t*t*0.5;
	local tSqrSqr = t*tSqr;
	t = t * 0.5;

	assert( output != p1 );
	assert( output != p2 );
	assert( output != p3 );
	assert( output != p4 );

	local a, b, c, d;

	// matrix row 1
	a = VectorScale( p1, -tSqrSqr, a );		// 0.5 t^3 * [ (-1*p1) + ( 3*p2) + (-3*p3) + p4 ]
	b = VectorScale( p2, tSqrSqr*3, b );
	c = VectorScale( p3, tSqrSqr*-3, c );
	d = VectorScale( p4, tSqrSqr, d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 2
	a = VectorScale( p1, tSqr*2,  a );		// 0.5 t^2 * [ ( 2*p1) + (-5*p2) + ( 4*p3) - p4 ]
	b = VectorScale( p2, tSqr*-5, b );
	c = VectorScale( p3, tSqr*4,  c );
	d = VectorScale( p4, -tSqr,    d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 3
	a = VectorScale( p1, -t, a );			// 0.5 t * [ (-1*p1) + p3 ]
	b = VectorScale( p3, t,  b );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );

	// matrix row 4
	output = VectorAdd( p2, output, output );	// p2

	return output;
end

function Catmull_Rom_Spline_Tangent(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	assert( s_bMathlibInitialized );
	local tOne = 3*t*t*0.5;
	local tTwo = 2*t*0.5;
	local tThree = 0.5;

	assert( output != p1 );
	assert( output != p2 );
	assert( output != p3 );
	assert( output != p4 );

	local a, b, c, d;

	// matrix row 1
	a = VectorScale( p1, -tOne, a );		// 0.5 t^3 * [ (-1*p1) + ( 3*p2) + (-3*p3) + p4 ]
	b = VectorScale( p2, tOne*3, b );
	c = VectorScale( p3, tOne*-3, c );
	d = VectorScale( p4, tOne, d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 2
	a = VectorScale( p1, tTwo*2,  a );		// 0.5 t^2 * [ ( 2*p1) + (-5*p2) + ( 4*p3) - p4 ]
	b = VectorScale( p2, tTwo*-5, b );
	c = VectorScale( p3, tTwo*4,  c );
	d = VectorScale( p4, -tTwo,    d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 3
	a = VectorScale( p1, -tThree, a );			// 0.5 t * [ (-1*p1) + p3 ]
	b = VectorScale( p3, tThree,  b );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );

	return output;
end

// area under the curve [0..t]
function Catmull_Rom_Spline_Integral(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	output = p2*t
			-0.25*(p1 - p3)*t*t
			+ (1.0/6.0)*(2.0*p1 - 5.0*p2 + 4.0*p3 - p4)*t*t*t
			- 0.125*(p1 - 3.0*p2 + 3.0*p3 - p4)*t*t*t*t;

	return output;
end


function Catmull_Rom_Spline_Normalize(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
	local dt = p3:Distance(p2);

	local p1n, p4n;
	p1n = VectorSubtract( p1, p2, p1n );
	p4n = VectorSubtract( p4, p3, p4n );

	p1n = VectorNormalize( p1n );
	p4n = VectorNormalize( p4n );

	p1n = VectorMA( p2, dt, p1n, p1n );
	p4n = VectorMA( p3, dt, p4n, p4n );

	output = Catmull_Rom_Spline( p1n, p2, p3, p4n, t, output );

	return output;
end


function Catmull_Rom_Spline_Integral_Normalize(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	// Normalize p2->p1 and p3->p4 to be the same length as p2->p3
	local dt = p3:Distance(p2);

	local p1n, p4n;
	p1n = VectorSubtract( p1, p2, p1n );
	p4n = VectorSubtract( p4, p3, p4n );

	p1n = VectorNormalize( p1n );
	p4n = VectorNormalize( p4n );

	p1n = VectorMA( p2, dt, p1n, p1n );
	p4n = VectorMA( p3, dt, p4n, p4n );

	output = Catmull_Rom_Spline_Integral( p1n, p2, p3, p4n, t, output );

	return output;
end


//-----------------------------------------------------------------------------
// Purpose: basic hermite spline.  t = 0 returns p1, t = 1 returns p2,
//			d1 and d2 are used to entry and exit slope of curve
// Input  :
//-----------------------------------------------------------------------------

function Hermite_Spline(
	p1,
	p2,
	d1,
	d2,
	t )
	assert( s_bMathlibInitialized );
	local output;
	local tSqr = t*t;
	local tCube = t*tSqr;

	local b1 = 2.0*tCube-3.0*tSqr+1.0;
	local b2 = 1.0 - b1; // -2*tCube+3*tSqr;
	local b3 = tCube-2*tSqr+t;
	local b4 = tCube-tSqr;

	output = p1 * b1;
	output = output + p2 * b2;
	output = output + d1 * b3;
	output = output + d2 * b4;

	return output;
end


// See http://en.wikipedia.org/wiki/Kochanek-Bartels_curves
//
// Tension:  -1 = Round -> 1 = Tight
// Bias:     -1 = Pre-shoot (bias left) -> 1 = Post-shoot (bias right)
// Continuity: -1 = Box corners -> 1 = Inverted corners
//
// If T=B=C=0 it's the same matrix as Catmull-Rom.
// If T=1 & B=C=0 it's the same as Cubic.
// If T=B=0 & C=-1 it's just linear interpolation
//
// See http://news.povray.org/povray.binaries.tutorials/attachment/%3CXns91B880592482seed7@povray.org%3E/Splines.bas.txt
// for example code and descriptions of various spline types...
//
function Kochanek_Bartels_Spline(
	tension,
	bias,
	continuity,
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	assert( s_bMathlibInitialized );

	local ffa, ffb, ffc, ffd;

	ffa = ( 1.0 - tension ) * ( 1.0 + continuity ) * ( 1.0 + bias );
	ffb = ( 1.0 - tension ) * ( 1.0 - continuity ) * ( 1.0 - bias );
	ffc = ( 1.0 - tension ) * ( 1.0 - continuity ) * ( 1.0 + bias );
	ffd = ( 1.0 - tension ) * ( 1.0 + continuity ) * ( 1.0 - bias );

	local tSqr = t*t*0.5;
	local tSqrSqr = t*tSqr;
	t = t * 0.5;

	assert( output != p1 );
	assert( output != p2 );
	assert( output != p3 );
	assert( output != p4 );

	local a, b, c, d;

	// matrix row 1
	a = VectorScale( p1, tSqrSqr * -ffa, a );
	b = VectorScale( p2, tSqrSqr * ( 4.0 + ffa - ffb - ffc ), b );
	c = VectorScale( p3, tSqrSqr * ( -4.0 + ffb + ffc - ffd ), c );
	d = VectorScale( p4, tSqrSqr * ffd, d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 2
	a = VectorScale( p1, tSqr* 2 * ffa,  a );
	b = VectorScale( p2, tSqr * ( -6 - 2 * ffa + 2 * ffb + ffc ), b );
	c = VectorScale( p3, tSqr * ( 6 - 2 * ffb - ffc + ffd ),  c );
	d = VectorScale( p4, tSqr * -ffd,    d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 3
	a = VectorScale( p1, t * -ffa,  a );
	b = VectorScale( p2, t * ( ffa - ffb ), b );
	c = VectorScale( p3, t * ffb,  c );
	// p4 unchanged

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );

	// matrix row 4
	// p1, p3, p4 unchanged
	// p2 is multiplied by 1 and added, so just added it directly

	output = VectorAdd( p2, output, output );

	return output;
end

function Cubic_Spline(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	assert( s_bMathlibInitialized );

	local tSqr = t*t;
	local tSqrSqr = t*tSqr;

	assert( output != p1 );
	assert( output != p2 );
	assert( output != p3 );
	assert( output != p4 );

	local a, b, c, d;

	// matrix row 1
	b = VectorScale( p2, tSqrSqr * 2, b );
	c = VectorScale( p3, tSqrSqr * -2, c );

	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );

	// matrix row 2
	b = VectorScale( p2, tSqr * -3, b );
	c = VectorScale( p3, tSqr * 3,  c );

	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );

	// matrix row 3
	// no influence
	// p4 unchanged

	// matrix row 4
	// p1, p3, p4 unchanged
	output = VectorAdd( p2, output, output );

	return output;
end

function BSpline(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	assert( s_bMathlibInitialized );

	local oneOver6 = 1.0 / 6.0;

	local tSqr = t * t * oneOver6;
	local tSqrSqr = t*tSqr;
	t = t * oneOver6;

	assert( output != p1 );
	assert( output != p2 );
	assert( output != p3 );
	assert( output != p4 );

	local a, b, c, d;

	// matrix row 1
	a = VectorScale( p1, -tSqrSqr, a );
	b = VectorScale( p2, tSqrSqr * 3.0, b );
	c = VectorScale( p3, tSqrSqr * -3.0, c );
	d = VectorScale( p4, tSqrSqr, d );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );
	output = VectorAdd( d, output, output );

	// matrix row 2
	a = VectorScale( p1, tSqr * 3.0,  a );
	b = VectorScale( p2, tSqr * -6.0, b );
	c = VectorScale( p3, tSqr * 3.0,  c );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );

	// matrix row 3
	a = VectorScale( p1, t * -3.0,  a );
	c = VectorScale( p3, t * 3.0,  c );
	// p4 unchanged

	output = VectorAdd( a, output, output );
	output = VectorAdd( c, output, output );

	// matrix row 4
	// p1 and p3 scaled by 1.0, so done below
	a = VectorScale( p1, oneOver6, a );
	b = VectorScale( p2, 4.0 * oneOver6, b );
	c = VectorScale( p3, oneOver6, c );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );

	return output;
end

function Parabolic_Spline(
	p1,
	p2,
	p3,
	p4,
	t,
	output )
	assert( s_bMathlibInitialized );

	local tSqr = t*t*0.5;
	t = t * 0.5;

	assert( output != p1 );
	assert( output != p2 );
	assert( output != p3 );
	assert( output != p4 );

	local a, b, c, d;

	// matrix row 1
	// no influence from t cubed

	// matrix row 2
	a = VectorScale( p1, tSqr,  a );
	b = VectorScale( p2, tSqr * -2.0, b );
	c = VectorScale( p3, tSqr,  c );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );
	output = VectorAdd( c, output, output );

	// matrix row 3
	a = VectorScale( p1, t * -2.0,  a );
	b = VectorScale( p2, t * 2.0,  b );
	// p4 unchanged

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );

	// matrix row 4
	a = VectorScale( p1, 0.5,  a );
	b = VectorScale( p2, 0.5,  b );

	output = VectorAdd( a, output, output );
	output = VectorAdd( b, output, output );

	return output;
end

s_bMathlibInitialized = true;
