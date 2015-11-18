function d = dprime(pHit,pFA)
% dprime
% 
% Description:	calculate d'
% 
% Syntax: d = dprime(pHit,pFA)
% 
% In:
%	pHit	- probability of a hit
%	pFA		- probability of a false alarm
% 
% Out:
%	d	- the d' estimate
% 
% Updated:	2015-11-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
d	= norminv(pHit) - norminv(pFA);
