function z = p2z(p)
% p2z
% 
% Description:	calculate the positive z-score that has a probability of p of
%				occurring by chance
% 
% Syntax:	p = p2z(z)
%
% Updated:	2012-01-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
z	= sqrt(2)*erfinv(1 - p);
