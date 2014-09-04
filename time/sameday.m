function b = sameday(t1,t2)
% sameday
% 
% Description:	determine if two dates are on the same day
% 
% Syntax:	b = sameday(t1,t2)
% 
% Updated: 2012-12-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= StartOfDay(t1)==StartOfDay(t2);
