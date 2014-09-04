function b = isinfSym(x)
% ISINFSYM
%
% Description:	isinf for syms
%
% Syntax:	b = isinfSym(x)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	if isa(x,'sym')
		b	= x==sym('inf') | x==sym('-inf');
	else
		b	= isinf(x);
	end
