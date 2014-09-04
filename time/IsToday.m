function b = IsToday(t)
% IsToday
% 
% Description:	test whether the given time represents sometime today
% 
% Syntax:	b = IsToday(t)
% 
% In:
% 	t	- a time, as number of ms since the epoch
% 
% Out:
% 	b	- true if t is some time today
% 
% Updated: 2011-10-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the beginning of today
	tToday	= StartOfDay(nowms);
%test
	tDiff	= t - tToday;
	b		= tDiff>=0 & tDiff<86400000;
