function ms = nowms()
% nowms
%
% Description:	returns the number of milliseconds since the 0000-01-01@00:00:00
%
% Syntax:	ms = nowms;
%
% Updated:	2010-04-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ms	= now*86400000;
