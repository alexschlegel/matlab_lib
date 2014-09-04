function [x,n] = stack(varargin)
% stack
% 
% Description:	concatenate a set of identically-sized arrays along their first
%				unoccupied dimension
% 
% Syntax:	[x,n] = stack(x1,...,xN)
% 
% In:
%	xK	- the Kth array
% 
% Out:
%	x	- the stacked array
%	n	- the dimension along which the arrays were stacked
% 
% Updated: 2010-12-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nargin>0
	nd	= ndims(varargin{1});
	n	= conditional(size(varargin{1},nd)==1,nd,nd+1);
else
	n	= 0;
end

x	= cat(n,varargin{:});
