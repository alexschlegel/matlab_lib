function x = roundn(x,n)
% roundn
% 
% Description:	round each element of x to the nearest multiple of 10^n
% 
% Syntax:	xr = roundn(x,n)
% 
% Updated: 2011-12-31
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= 10.^(-n);
x	= round(x.*n)./n;
