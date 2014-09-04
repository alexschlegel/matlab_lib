function b = isint(x)
% isint
% 
% Description:	determine if numbers are integers
% 
% Syntax:	b = isint(x)
% 
% In:
% 	x	- a numeric array
% 
% Out:
% 	b	- a logical array the same size as x indicating which elements of x are
%		  integers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= x==fix(x);
