function x = prctileQuick(x,p,n)
% prctileQuick
%
% Description:	a faster version of prctile, which only considers a subset of x
%
% Syntax:	y = prctileQuick(x,p,[n])
%
% In:
%	x	- an array
%	p	- a number between 0 and 100
%	[n]	- optional, consider at most n elements of x.  default==100000
%
% Out:	a number that is greater than p% of values in x
%
% Assumptions:	Assumes the variability of x is distributed evenly (the sample
%				is taken along a regular interval of x)
%
% Example:	y = prctileQuick(x,95);
%
% Updated:	2008-11-24
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if ~exist('n','var')	|| isempty(n)	n	= 100000;	end

nX		= numel(x);
n		= min(n,nX);
sample	= round( (1:n) .* (nX/n) ) ;

x		= prctile(x(sample),p);
