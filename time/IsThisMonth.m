function b = IsThisMonth(t)
% IsThisMonth
% 
% Description:	test whether the given date represents some time this month
% 
% Syntax:	b = IsThisMonth(t)
% 
% In:
% 	t	- a time, as number of ms since the epoch
% 
% Out:
% 	b	- true if t is some time this month
% 
% Updated: 2011-10-04
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the beginning of the month
	tBegin	= FormatTime([FormatTime(t,'yyyy-mm') '-01']);
%get the test date month number
	nTestMonth	= str2num(FormatTime(t,'mm'));
%get the month number
	tNow		= nowms;
	nThisMonth	= str2num(FormatTime(nowms,'mm'));
%test
	b	= t>=tBegin & t<tBegin+86400000*31 & nTestMonth==nThisMonth;
