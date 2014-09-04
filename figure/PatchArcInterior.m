function hP = PatchArcInterior(x,y,r,a1,a2,w,varargin)
% PatchArc
% 
% Description:	draw an arc patch toward the interior of a circle so that the arc
%				intersects the circle at right angles
% 
% Syntax:	hP = PatchArcInterior(x,y,r,a1,a2,w,<options>)
% 
% In:
% 	x	- the x value of the circle center
%	y	- the y value of the circle center
%	r	- the radius of the circle
%	a1	- the first angle endpoint of the arc, in radians
%	a2	- the second angle endpoint of the arc, in radians
%	w	- the thickness of the arc, in axes units
%	<options>:
%		ha:				(<gca>) the handle of the axes to use
%		color:			([0 0 0]) the arc color
%		alpha:			(1) the transparency (0->1)
%		nstep:			(100) the number of vertices to use
% 
% Out:
% 	hP	- the handle to the arc patch
% 
% Updated: 2011-03-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the angles
	a1	= mod(a1,2*pi);
	a2	= mod(a2,2*pi);
	at	= a1;
	a1	= min(at,a2);
	a2	= max(at,a2);
	
	if a2-a1>pi
		at	= a1;
		a1	= a2 - 2*pi;
		a2	= at;
	end
	
	if (a2-a1)==pi
		p1	= [x y] + PointConvert([r a1],'polar','cartesian');
		p2	= [x y] + PointConvert([r a2],'polar','cartesian');
		
		hP	= PatchLine([p1(1);p2(1)],[p1(2);p2(2)],w,varargin{:});
		
		return;
	end

%get the equivalent PatchArc inputs for the interior arc
	%x,y of the arc end points
		pa1	= PointConvert([r a1],'polar','cartesian');
		xa1	= x + pa1(1);
		ya1	= y + pa1(2);
		
		pa2	= PointConvert([r a2],'polar','cartesian');
		xa2	= x + pa2(1);
		ya2	= y + pa2(2);
	%the new radius
		t	= min(pi-0.01,a2-a1);
		r2	= r*tan(t/2);
		
		if r2<0
			at	= a1;
			a1	= a2;
			a2	= at;
			t	= a2 - a1;
			r2	= r*tan(t/2);
		end
	%the new center point
		aBetween	= (a1+a2)/2;
		rBetween	= abs(r*cos(t/2)) + abs(r2*cos((pi-t)/2));
		
		pBetween	= PointConvert([rBetween aBetween],'polar','cartesian');
		x2	= x + pBetween(1);
		y2	= y + pBetween(2);
	%the new angles
		a21	= atan2(y2-ya1,x2-xa1)+pi;
		a22	= atan2(y2-ya2,x2-xa2)+pi;
		
		a21	= mod(a21,2*pi);
		a22	= mod(a22,2*pi);
		
		at	= a21;
		a21	= min(at,a22);
		a22	= max(at,a22);
		
		if a22-a21>pi
			at	= a21;
			a21	= a22-2*pi;
			a22	= at;
		end

hP	= PatchArc(x2,y2,r2,a21,a22,w,varargin{:});
