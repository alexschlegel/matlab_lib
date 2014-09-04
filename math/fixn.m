function x = fixn(x,n)
% fixn
% 
% Description:	fix each element of x at the nearest multiple of 10^n
% 
% Syntax:	xf = fixn(x,n)
% 
% Updated: 2011-12-31
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= 10.^(-n);
x	= fix(x.*n)./n;
