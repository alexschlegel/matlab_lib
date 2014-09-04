function f = frad(rH)
% FRAD
%
% Description:	calculate the fractional distance of a hyperbolic radius to the
%				edge of the space
%
% Syntax:	f = frad(rH)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

f	= rH;

kOut	= isinfSym(f);
kIn		= ~kOut;

f(kOut)	= 1;
f(kIn)	= exp(rH);
f(kIn)	= (f(kIn)-1)./(f(kIn)+1);
	