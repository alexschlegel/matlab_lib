function c = PointConvertComplex(u,v,strFrom)
% POINTCONVERTCARTESIANPOLAR
%
% Description:	convert coordinates to their equivalent coordinates on the
%				complex plane
%
% Syntax:	c = PointConvertComplex(u,v,strFrom)
%
% In:
%	u		- the u-coordinate of the from space
%	v		- the v-coordinate of the from space
%	strFrom	- a string denoting the space of the from coordinates.  can be:
%				'euclidean_cartesian'
%				'euclidean_polar'
%				'hyperbolic_axial'
%				'hyperbolic_polar'
%				'hyperbolic_lobachevsky'
%				'hyperbolic_beltrami'
%
% Out:
%	c	- the complex-number equivalents of (u,v)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

switch lower(strFrom)
	case 'euclidean_cartesian'
		x	= u;
		y	= v;
	case 'euclidean_polar'
		x	= u.*cos(v);
		y	= u.*sin(v);
	case 'hyperbolic_axial'
		x	= u;
		y	= v;
	case 'hyperbolic_polar'
		x	= u.*cos(v);
		y	= u.*sin(v);
	case 'hyperbolic_lobachevsky'
		x	= u;
		y	= v;
	case 'hyperbolic_beltrami'
		x	= u.*cos(v);
		y	= u.*sin(v);
	otherwise
		error([strFrom ' is not a valid space!']);
end

c	= x + i*y;
