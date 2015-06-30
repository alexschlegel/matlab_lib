function t = ms2unix(ms)
% ms2unix
% 
% Description:	convert a nowms style time to a unix time stamp
% 
% Syntax:	t = ms2unix(ms)
% 
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= (ms-unixepoch)/1000;
