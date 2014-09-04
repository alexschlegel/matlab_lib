function t = StartOfDay(t)
% StartOfDay
% 
% Description:	get the date at midnight on the same day as t
% 
% Syntax:	t = StartOfDay(t)
% 
% Updated: 2011-11-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t	= FormatTime(FormatTime(t,'yyyy-mm-dd'));
