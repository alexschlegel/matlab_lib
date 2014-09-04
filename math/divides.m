function b = divides(x,y,varargin)
% divides
% 
% Description:	test to see if one number divides another number
% 
% Syntax:	b = divides(x,y)
% 
% In:
% 	x	- a scalar or array
%	y	- a scalar or array (same size as x)
% 
% Out:
% 	b	- a logical array indicating which values of x divide values of y
% 
% Updated:	2009-10-22
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= mod(y,x)==0;
