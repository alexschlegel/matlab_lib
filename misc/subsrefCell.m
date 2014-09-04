function cY = subsrefCell(cX,k)
% subsrefCell
% 
% Description:	return a cell of subelements of arrays stored in another cell
% 
% Syntax:	cY = subsrefCell(cX,k)
% 
% In:
% 	cX	- a cell of arrays
%	k	- a cell of arrays indices to return from each array in cX
% 
% Out:
% 	cY	- a cell of subarrays from cX
% 
% Updated:	2009-12-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cY	= cellfun(@(x,y) x(y),cX,k,'UniformOutput',false);
