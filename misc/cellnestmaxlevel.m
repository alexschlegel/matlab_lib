function n = cellnestmaxlevel(varargin)
% cellnestmaxlevel
% 
% Description:	find the maximum nesting level of a set of nested cells
% 
% Syntax:	n = cellnestmaxlevel(c1,...,cN)
% 
% In:
% 	cK	- the Kth nested cell
% 
% Out:
% 	n	- the maximum nesting level of the cells
% 
% Updated: 2012-04-12
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bCell	= cellfun(@iscell,varargin);

if any(bCell)
	n	= 1 + max(cellfun(@(c) cellnestmaxlevel(c{:}),varargin(bCell)));
else
	n	= 0;
end
