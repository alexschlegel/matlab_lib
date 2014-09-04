function b = IsTomorrow(t)
% IsTomorrow
% 
% Description:	test whether the given time represents sometime tomorrow
% 
% Syntax:	b = IsTomorrow(t)
% 
% In:
% 	t	- a time, as number of ms since the epoch
% 
% Out:
% 	b	- true if t is some time tomorrow
% 
% Updated: 2011-10-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the beginning of tomorrow
	tTomorrow	= FormatTime(FormatTime(nowms,'yyyy-mm-dd'))+86400000;
%test
	tDiff	= t - tTomorrow;
	b		= tDiff>=0 & tDiff<86400000;
