function cP = PackageSplit(p)
% PackageSplit
% 
% Description:	split a package path into a cell of package names
% 
% Syntax:	cP = PackageSplit(p)
% 
% In:
% 	p	- the package path (e.g. as output from ClassSplit)
% 
% Out:
% 	cP	- a cell of the package names in the package path
% 
% Updated: 2011-12-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cP	= split(p,'\.');
