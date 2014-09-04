function m = meanPrctile(x,pLower,pUpper)
% meanPrctile
% 
% Description:	get the mean of the values of x between the pLower and pUpper
%				percentiles
% 
% Syntax:	meanPrctile(x,pLower,pUpper)
% 
% In:
% 	x		- an array
%	pLower	- the lower bound percentile
%	pUpper	- the upper bound percentile
% 
% Out:
% 	m	- the mean of the values of x between the pLower and pUpper percentiles
% 
% Updated:	2008-11-20
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

x	= x(:);

xBound	= prctile(x,[pLower pUpper]);
m		= mean(x(x>=xBound(1) & x<=xBound(2)));
