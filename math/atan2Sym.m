function a=atan2Sym(y,x)
% ATAN2SYM
%
% Description:	atan2 for symbolic variables
%
% Syntax:	a=atan2Sym(y,x)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	if isa(y,'sym') || isa(x,'sym')
		a	= atan(y,x);
	else
		a	= atan2(y,x);
	end
