function t = nowunixUTC()
% nowunixUTC
%
% Description:	returns the current unix-style time in UTC
%
% Syntax:	t = nowunixUTC
%
% Updated:	2010-04-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
t	= java.lang.System.currentTimeMillis/1000;
