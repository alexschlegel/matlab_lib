function sm = floor(sm)
% floor
% 
% Description:	StringMath floor function
% 
% Syntax:	sm = floor(sm)
% 
% Updated:	2009-05-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

persistent sm01;
if isempty(sm01) || ~p_EqualProperties(sm01,sm)
	sm01	= StringMath('1');
end

%subtract one from negative numbers with decimal components
	bSubtract		= [sm.sign]==-1 & ~cellfun('isempty',{sm.dec});
	sm(bSubtract)	= sm(bSubtract) - sm01;
%delete the decimal part
	[sm.dec]	= deal(int8([]));
