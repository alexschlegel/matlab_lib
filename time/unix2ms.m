function ms = unix2ms(t)
% unix2ms
% 
% Description:	convert a unix time stamp to a nowms style time
% 
% Syntax:	ms = unix2ms(t)
% 
% Updated: 2015-06-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ms	= 1000*t + unixepoch;
