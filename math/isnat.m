function b = isint(x)
% isint
% 
% Description:	determine if numbers are natural numbers
% 
% Syntax:	b = isnat(x)
% 
% In:
% 	x	- a numeric array
% 
% Out:
% 	b	- a logical array the same size as x indicating which elements of x are
%		  natural numbers
% 
% Updated:	2010-08-11
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= isint(x) & x>0;
