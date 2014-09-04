function a = angle3point(pv,p1,p2)
% angle3point
% 
% Description:	return the angle between three points
% 
% Syntax:	a = angle3point(pv,p1,p2)
% 
% In:
% 	pv	- the vertex point
%	p1	- point 1
%	p2	- point 2
% 
% Out:
% 	a	- the angle between the three points
% 
% Updated: 2013-05-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
d12		= dist(p1,pv);
d13		= dist(p2,pv);
d23		= dist(p2,p1);
a		= acos( (d12.^2 + d13.^2 - d23.^2)./(2.*d12.*d13) );
