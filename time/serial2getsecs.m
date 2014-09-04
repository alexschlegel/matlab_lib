function t = serial2getsecs(s)
% serial2getsecs
% 
% Description:	convert a now style serial time to a GetSecs style time
% 
% Syntax:	t = serial2getsecs(s)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= ms2getsecs(serial2ms(s));
