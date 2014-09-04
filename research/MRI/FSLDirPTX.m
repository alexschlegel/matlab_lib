function strDirPTX = FSLDirPTX(strDirDTI)
% FSLDirPTX
% 
% Description:	get the path to a probtrackx directory
% 
% Syntax:	strDirPTX = FSLDirPTX(strDirDTI)
% 
% In:
% 	strDirDTI	- the DTI data directory path
% 
% Out:
% 	strDirPTX	- the path to the probtrackx directory
% 
% Updated: 2011-03-20
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strDirPTX	= AddSlash([RemoveSlash(strDirDTI) '.probtrackX'],false);
