function x = closest(x,xSet)
% closest
% 
% Description:	transform each value of x to the closest value in xSet
% 
% Syntax:	x = closest(x,xSet)
% 
% Updated: 2012-02-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s		= size(x);
nd		= numel(s);

nSet	= numel(xSet);
xSet	= repmat(reshape(xSet,[ones(1,nd) nSet]),[s 1]);
x		= repmat(x,[ones(1,nd) nSet]);

d	= abs(xSet - x);
d	= d==repmat(min(d,[],nd+1),[ones(1,nd) nSet]);

xSet	= permute(xSet,[nd+1 1:nd]);
d		= permute(d,[nd+1 1:nd]);

x	= reshape(xSet(d),s);
