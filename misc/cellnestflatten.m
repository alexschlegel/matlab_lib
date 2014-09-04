function c = cellnestflatten(c)
% cellnestflatten
% 
% Description:	flatten a nested cell into a single Nx1 cell
% 
% Syntax:	c = cellnestflatten(c)
% 
% Updated: 2012-04-13
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if any(cellfun(@iscell,c))
	c	= cellfun(@(x) conditional(iscell(x),reshape(x,[],1),x),c,'UniformOutput',false);
	c	= cat(1,c{:});
	
	c	= cellnestflatten(c);
end
