function sm = ceil(sm)
% ceil
% 
% Description:	StringMath ceiling function
% 
% Syntax:	sm = ceil(sm)
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

persistent sm01;
if isempty(sm01) || ~p_EqualProperties(sm01,sm)
	sm01	= p_TransferProperties(sm,StringMath('1'));
end

%add one to positive numbers with decimal components
	bAdd		= [sm.sign]==1 & ~cellfun('isempty',{sm.dec});
	sm(bAdd)	= sm(bAdd) + sm01;
%delete the decimal part
	[sm.dec]	= deal(int8([]));
