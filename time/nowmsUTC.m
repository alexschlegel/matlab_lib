function ms = nowmsUTC()
% nowms
%
% Description:	returns the number of milliseconds since 0000-01-01@00:00:00 UTC
%
% Syntax:	ms = nowms;
%
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ms	= 1000*nowunixUTC + unixepoch;
