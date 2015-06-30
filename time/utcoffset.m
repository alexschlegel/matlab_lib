function ms = utcoffset()
% utcoffset
%
% Description:	the offset of UTC from the current time zone, in ms
%
% Syntax:	ms = utcoffset
%
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ms	= round(nowmsUTC - nowms);

%take care of error from multiple calls to current time
	ms	= round(ms/100)*100;
