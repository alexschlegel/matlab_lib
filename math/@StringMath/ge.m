function b = ge(sm1,sm2)
% ge
% 
% Description:	StringMath greater than or equal to function
% 
% Syntax:	b = ge(x,y) OR
%			b = x >= y
% 
% In:
%	x/y	- an array of StringMath objects, numeric strings, or numbers
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fix the input
	[sm1,sm2,bEmptyInput]	= p_FixInput(sm1,sm2);
	
	if bEmptyInput
		b	= [];
		return;
	end

b	= sm1>sm2 | sm1==sm2;
