function b = ne(sm1,sm2)
% ne
% 
% Description:	StringMath ne function
% 
% Syntax:	b = ne(x,y) OR
%			x~=y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= ~eq(sm1,sm2);
