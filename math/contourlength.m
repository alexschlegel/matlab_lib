function [L,d] = contourlength(x,y)
% contourlength
% 
% Description:	calculate the length of a contour
% 
% Syntax:	[L,d] = contourlength(x,y)
% 
% In:
% 	x	- an N-length vector of x values along the contour
%	y	- an N-length vector of y values along the contour
% 
% Out:
% 	L	- the contour length
%	d	- the distance between each successive point
% 
% Updated: 2013-04-17
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
d	= sqrt( diff(x).^2 + diff(y).^2 );
L	= sum(d);
