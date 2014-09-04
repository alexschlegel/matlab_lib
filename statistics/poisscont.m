function y = poisscont(x,mu)
% poisscont
% 
% Description:	a continuous poisson-like distribution
% 
% Syntax:	y = poisscont(x,mu)
% 
% Out:
% 	y	- exp(-mu).*mu.^x./gamma(x)
% 
% Updated: 2012-10-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
y	= exp(-mu).*mu.^x./gamma(x);
