function f = fpart(x)
% fpart
%
% Description:	returns the fractional part of number x
%
% Syntax:	f = fpart(x)
%
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
f	= x - fix(x);
