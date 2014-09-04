function cMember = cellnestmembers(c)
% cellnestmembers
% 
% Description:	get the non-cell members of a nested cell
% 
% Syntax:	cMember = cellnestmembers(c)
% 
% In:
% 	c	- a nested cell (e.g. {{1,2},{3,{{4,5},6}},7}
% 
% Out:
% 	cMember	- an Nx1 cell of the members of c (e.g. {1;2;3;4;5;6;7})
% 
% Updated: 2011-12-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if iscell(c)
	cM		= cellfun(@cellnestmembers,c,'UniformOutput',false);
	cMember	= UniqueCell(cat(1,cM{:}));
else
	cMember	= {c};
end
