function [x,n] = stackin(varargin)
% stackin
% 
% Description:	concatenate a set of identically-sized arrays along their first
%				singleton dimension
% 
% Syntax:	[x,n] = stackin(x1,...,xN)
% 
% In:
%	xK	- the Kth array
% 
% Out:
%	x	- the stacked array
%	n	- the dimension along which the arrays were stacked
% 
% Updated: 2011-03-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nargin>0
	n	= unless(find(size(varargin{1})==1,1,'first'),ndims(varargin{1})+1);
else
	n	= 0;
end

x	= cat(n,varargin{:});
