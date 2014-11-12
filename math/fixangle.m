function a = fixangle(a)
% fixangle
% 
% Description:	force a to be between -180 and 180
% 
% Syntax:	a = fixangle(a)
% 
% In:
% 	a	- the angle, in degrees
% 
% Updated: 2014-11-10
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
a	= mod(a,360);

bNeg	= a>180;
a(bNeg)	= a(bNeg)-360;
