function b = IsYesterday(t)
% IsYesterday
% 
% Description:	test whether the given time represents sometime yesterday
% 
% Syntax:	b = IsYesterday(t)
% 
% In:
% 	t	- a time, as number of ms since the epoch
% 
% Out:
% 	b	- true if t is some time yesterday
% 
% Updated: 2011-10-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the beginning of yesterday
	tYesterday	= FormatTime(FormatTime(nowms,'yyyy-mm-dd'))-86400000;
%test
	tDiff	= t - tYesterday;
	b		= tDiff>=0 & tDiff<86400000;
