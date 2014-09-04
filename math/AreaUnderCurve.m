function a = AreaUnderCurve(y,varargin)
% AreaUnderCurve
% 
% Description:	calculate the area under the curve y.  positive and negative
%				y-values both contribute positive area values
% 
% Syntax:	a = AreaUnderCurve(y,[xStep]=1)
% 
% In:
% 	y		- the y data of the curve
%	[xStep]	- the x-spacing between y points
% 
% Out:
% 	a	- the area under the curve defined by y
% 
% Example:	AreaUnderCurve([0 1 2],0.5) == 1
% 
% Updated:	2008-04-30
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
xStep	= ParseArgs(varargin,1);

y	= abs(y);

a	= sum(y(1:end-1).*xStep + (y(2:end)-y(1:end-1)).*xStep/2);
