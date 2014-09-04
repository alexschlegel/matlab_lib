function d = distAngle(x,y,varargin)
% distAngle
% 
% Description:	calculates the distance between points on a circle
% 
% Syntax:	d = distAngle(x,y,<options>)
%
% In:
%	x	- a point or M1 x ... x Mk array of points on the circle
%	y	- same as x
%	<options>:
%		amin:	(-pi) the minimum point in the space
%		amax:	(pi) the maximum point in the space (amin===amax)
%		abs:	(true) true to return the absolute distance
% 
% Out:
%	d	- an of angular distances between x and y
%
% Updated: 2010-07-22
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'amin'	, -pi	, ...
		'amax'	, pi	, ...
		'abs'	, true	  ...
		);

[x,y]	= FillSingletonArrays(x,y);
nd		= ndims(x);

%find the angular distance
	d1	= x-y;
	
	aRange	= opt.amax-opt.amin;
	d2		= mod(d1,-aRange.*sign(d1));
	d1		= mod(d1,aRange.*sign(d1));
	
	[d,k]	= min(cat(nd+1,abs(d1),abs(d2)),[],nd+1);
	
	if ~opt.abs
		b		= k==1;
		d(b)	= d(b).*sign(d1(b));
		
		b		= k==2;
		d(b)	= d(b).*sign(d2(b));
	end
	