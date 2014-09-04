function b = le(sm1,sm2)
% le
% 
% Description:	StringMath less than or equal to function
% 
% Syntax:	b = le(x,y) OR
%			b = x <= y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= ~(sm1>sm2);
