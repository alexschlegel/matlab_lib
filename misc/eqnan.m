function b = eqnan(x,y)
% eqnan
% 
% Description:	eq with equal NaNs
% 
% Syntax:	b = eqnan(x,y)
% 
% Updated:	2009-06-15
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= (isnan(x) & isnan(y)) | x==y;
