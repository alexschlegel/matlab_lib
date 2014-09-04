function b = isodd(x)
% isodd
% 
% Description:	determines if a number is odd
% 
% Syntax:	b = isodd(x)
%
% In:
%	x	- an numeric array
% 
% Out:
%	b	- a logical array the same size as x indicating which entries of x are
%		  odd
%
% Updated:	2009-07-06
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= double(x)/2;
b	= b~=fix(b);
