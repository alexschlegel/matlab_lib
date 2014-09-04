function b = p_EqualProperties(sm1,sm2)
% p_EqualProperties
% 
% Description:	test to see if sm1 and sm2 have the same property values
% 
% Syntax:	b = p_EqualProperties(sm1,sm2)
% 
% Updated:	2009-05-30
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= sm1.precision==sm2.precision;
