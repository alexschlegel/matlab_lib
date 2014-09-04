function sgn = signSym(x)
% signSym
%
% Description:	sign function that handles Syms
%
% Syntax:	sgn = signSym(x)
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	if isa(x,'sym')
		sgn			= double(gtSym(x,sym(0)));
		sgn
		sgn(sgn==0)	= -1;
		sgn(x==0)	= 0;
	else
		sgn	= sign(x);
	end
