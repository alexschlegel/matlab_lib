function b = IsNextMonth(t)
% IsNextMonth
% 
% Description:	test whether the given date represents some time next month
% 
% Syntax:	b = IsNextMonth(t)
% 
% In:
% 	t	- a time, as number of ms since the epoch
% 
% Out:
% 	b	- true if t is some time next month
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the test date month number
	nTestMonth	= str2num(FormatTime(t,'mm'));
%get the next month number
	tNow		= nowms;
	nNextMonth	= mod(str2num(FormatTime(nowms,'mm')),12)+1;
%test
	b	= t>tNow & t<tNow+86400000*62 & nTestMonth==nNextMonth;
