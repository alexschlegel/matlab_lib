function t = getsecs2serial(gs)
% getsecs2serial
% 
% Description:	convert a GetSecs style time to a now style serial time
% 
% Syntax:	t = getsecs2serial(gs)
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= ms2serial(getsecs2ms(gs));
