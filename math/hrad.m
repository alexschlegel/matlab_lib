function r = hrad(f)
% HRAD
%
% Description:	calculate the hyperbolic radius at fractional distance f to the
%				edge of the space
%
% Syntax:	r = hrad(f)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

r	= abs(f);

kIn		= ltSym(r,1);
kOut	= ~kIn;

r(kIn)	= log((1 + r(kIn)) ./ (1 - r(kIn)));
r(kOut)	= Inf;
