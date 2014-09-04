function sm = uminus(sm)
% uminus
% 
% Description:	the StringMath uminus function
% 
% Syntax:	sm = uminus(sm) OR
%			sm = -sm
% 
% Updated:	2009-05-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

bInvert	= sm~=0;
bP		= [sm.sign]==1;

[sm(bInvert & bP).sign]	= deal(-1);
[sm(~bP).sign]			= deal(1);
