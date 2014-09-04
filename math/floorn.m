function x = floorn(x,n)
% floorn
% 
% Description:	floor each element of x at the nearest multiple of 10^n
% 
% Syntax:	xf = floorn(x,n)
% 
% Updated: 2011-12-31
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= 10.^(-n);
x	= floor(x.*n)./n;
