function t = ms2serial(ms)
% ms2serial
% 
% Description:	convert a nowms style time to a now style serial time
% 
% Syntax:	t = ms2serial(ms)
% 
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= ms/86400000;
