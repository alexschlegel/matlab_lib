function [u,v] = PointConvertHyperbolic(u,v,strFrom,strTo)
% POINTCONVERTHYPERBOLIC
%
% Description:	convert between euclidean and hyperbolic spaces using a number
%				of methods
%
% Syntax:	[u,v] = PointConvertHyperbolic(u,v,strFrom,strTo)
%
% In:
%	u		- u-coordinates of the from space
%	v		- v-coordinates of the from space
%	strFrom	- a string denoting the space of the from coordinates.  can be:
%				'euclidean_cartesian'
%				'euclidean_polar'
%				'hyperbolic_axial'
%				'hyperbolic_polar'
%				'hyperbolic_lobachevsky'
%				'hyperbolic_beltrami'
%	strTo	- a string denoting the space of the to coordinates
%
% Out:
%	u	- u-coordinates of the to space
%	v	- v-coordinates of the to space
%
% Notes:	"euclidean coordinates" are the euclidean coordinates of points on
%			the hyperbolic circle.  so any euclidean point with radius 1 is on the
%			edge of hyperbolic space.
%			This isn't very efficient for some conversions
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
%first convert to euclidean polar
switch lower(strFrom)
	case 'euclidean_cartesian'
		r	= sqrt(u.^2 + v.^2);
		a	= atan2Sym(v,u);
	case 'euclidean_polar'
		r	= u;
		a	= v;
	case 'hyperbolic_axial'
		r	= frad(atanh(sqrt(tanh(u).^2 + tanh(v).^2)));
		a	= atan2Sym(tanh(v),tanh(u));
	case 'hyperbolic_polar'
		r	= frad(u);
		a	= v;
	case 'hyperbolic_lobachevsky'
		%first convert to axial
			sgnU	= signSym(u);
			sgnV	= signSym(v);
			
			u	= tanh(abs(u));
			v	= tanh(abs(v));
			u2	= u.^2;
			v2	= v.^2;
			c1	= 2.*u2.*v2-1;
			c2	= u.*v;
			c2	= (c2+1).*(c2-1);
			c3	= (u-1).*(v+1);
			c4	= (u+1).*(v-1);
			
			u	= -sgnU .* log((c1-u2 + 2*sqrt(u2.*c4.*c2))./c3)/2;
			v	= -sgnV .* log((c1-v2 + 2*sqrt(u2.*c3.*c2))./c4)/2;
		%now convert to euclidean polar
			[r,a]	= PointConvertHyperbolic(u,v,'hyperbolic_axial','euclidean_polar');
	case 'hyperbolic_beltrami'
		r	= frad(atanh(sqrt(u.^2 + v.^2)));
		a	= atan2Sym(v,u);
	otherwise
		error([strFrom ' is not a valid space!']);
end

%now convert to the to space
switch lower(strTo)
	case 'euclidean_cartesian'
		u	= r.*cos(a);
		v	= r.*sin(a);
	case 'euclidean_polar'
		u	= r;
		v	= a;
	case 'hyperbolic_axial'
		r	= tanh(hrad(r));
		u	= atanh(r.*cos(a));
		v	= atanh(r.*sin(a));
	case 'hyperbolic_polar'
		u	= hrad(r);
		v	= a;
	case 'hyperbolic_lobachevsky'
		r		= tanh(hrad(r));
		
		tanhU	= r.*cos(a);
		tanhV	= r.*sin(a);
		
		c1		= sqrt((1+tanhV)./(1-tanhV));
		c2		= sqrt((1+tanhU)./(1-tanhU));
		u		= atanh(tanhU.*(c1+1./c1)/2);
		v		= atanh(tanhV.*(c2+1./c2)/2);
	case 'hyperbolic_beltrami'
		r	= tanh(hrad(r));
		u	= r.*cos(a);
		v	= r.*sin(a);
	otherwise
		error([strTo ' is not a valid space!']);
end
