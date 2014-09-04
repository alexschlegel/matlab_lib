function cPathCOPE = FSLPathCOPE(strDirFEAT)
% FSLPathCOPE
% 
% Description:	get the paths to the COPE files of a FEAT analysis
% 
% Syntax:	cPathCOPE = FSLPathCOPE(strDirFEAT)
% 
% In:
% 	strDirFEAT	- the path to a FEAT directory
% 
% Out:
% 	cPathCOPE	- a cell of path to the COPE files
% 
% Updated: 2012-03-31
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cPathCOPE	= FindFiles(DirAppend(strDirFEAT,'stats'),'^cope\d+\.nii\.gz');
