function t = serial2ms(s)
% serial2ms
% 
% Description:	convert a now style serial time to a nowms style time
% 
% Syntax:	t = serial2ms(s)
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= s*86400000;
