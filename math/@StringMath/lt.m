function b = lt(sm1,sm2)
% lt
% 
% Description:	StringMath less than function
% 
% Syntax:	b = lt(x,y) OR
%			b = x < y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= ~(sm1>=sm2);
