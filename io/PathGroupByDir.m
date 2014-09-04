function [cPathGroup,cDirGroup] = PathGroupByDir(cPath)
% PathGroupByDir
% 
% Description:	group a cell of file paths by directory
% 
% Syntax:	[cPathGroup,cDirGroup] = PathGroupByDir(cPath)
% 
% In:
% 	cPath	- a cell of file paths
% 
% Out:
% 	cPathGroup	- a cell of cells of file paths, one cell per directory
%	cDirGroup	- a cell of directories corresponding to the cells in cPath
% 
% Updated:	2009-06-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the directories
	nPath	= numel(cPath);
	cDir	= cell(nPath,1);
	for k=1:nPath
		cDir{k}	= PathSplit(cPath{k});
	end
	
%get the unique ones
	[cDirGroup,kAll2U,kU2All]	= unique(cDir);
	
	nUnique		= numel(cDirGroup);
	cPathGroup	= cell(nUnique,1);
	for k=1:nUnique
		cPathGroup{k}	= cPath(kU2All==k);
	end
	