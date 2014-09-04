function b = iseven(sm)
% iseven
% 
% Description:	determine if a StringMath object is even
% 
% Syntax:	b = iseven(sm)
% 
% Updated:	2009-05-31
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

sz	= size(sm);
n	= numel(sz);

bCheck	= cellfun('isempty',{sm.dec});
vUnit	= cellfun(@GetUnits,{sm(bCheck).int});

b			= false(sz);
b(bCheck)	= iseven(vUnit);


%------------------------------------------------------------------------------%
function u = GetUnits(a)
	if isempty(a)
		u	= 0;
	else
		u	= a(1);
	end
%------------------------------------------------------------------------------%
