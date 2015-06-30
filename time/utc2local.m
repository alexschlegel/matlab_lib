function t = utc2local(tUTC)
% utc2local
%
% Description:	convert a UTC nowms style time to local time
%
% Syntax:	t = utc2local(tUTC)
%
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= tUTC - utcoffset;
