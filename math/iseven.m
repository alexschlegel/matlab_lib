function b = iseven(x)
% iseven
% 
% Description:	determines if a number is even
% 
% Syntax:	b = iseven(x)
%
% In:
%	x	- an numeric array
% 
% Out:
%	b	- a logical array the same size as x indicating which entries of x are
%		  even
%
% Updated:	2009-07-06
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= double(x)/2;
b	= b==fix(b);
