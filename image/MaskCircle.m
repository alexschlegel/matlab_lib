function b = MaskCircle(d1,varargin)
% MaskCircle
% 
% Description:	create a binary circular or elliptical mask
% 
% Syntax:	b = MaskCircle(d1,[d2]=d1)
% 
% In:
% 	d1		- the vertical diameter of the ellipse
%	[d2]	- the horizontal diameter of the ellipse
% 
% Out:
% 	b	- a binary mask set to true inside the circular/elliptical mask
% 
% Updated:	2009-03-31
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
d2	= ParseArgs(varargin,d1);

[x,y]	= Coordinates([d1 d2],'cartesian');

b	= (2*x/d2).^2 + (2*y/d1).^2 <= 1;
