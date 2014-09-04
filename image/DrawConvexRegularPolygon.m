function im = DrawConvexRegularPolygon(n,s,varargin)
% DrawPolygon
% 
% Description:	return an image of the specified convex, regular polygon
% 
% Syntax:	im = DrawPolygon(n,s,<options>)
% 
% In:
% 	n	- the number of sides
%	s	- the length of the sides, in units
%	<options>
%		(see DrawPolygonFromPoints)
% 
% Out:
% 	im	- an image of the polygon
% 
% Updated:	2009-02-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%interior angle
	a	= pi-2*pi/n;

%get the coordinates of each point on the polygon
	p		= zeros(n,2);
	aCur	= 0;
	for k=2:n
		aCur	= aCur + (pi-a);
		
		p(k,:)	= p(k-1,:) + s*[sin(aCur) cos(aCur)];
	end

%draw the polygon
	im	= DrawPolygonFromPoints(p,varargin{:});
	