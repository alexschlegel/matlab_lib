function strPath = PathReplaceDir(strPath,strDir)
% PathReplaceDir
% 
% Description:	replace the directory portion of path
% 
% Syntax:	strPath = PathReplaceDir(strPath,strDir)
% 
% In:
% 	strPath	- the path to a file
%	strDir	- the new directory for the file
% 
% Out:
% 	strPath	- the path with the directory portion replaced by strDir
% 
% Updated: 2011-11-13
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strDirOld,strFilePre,strExt]	= PathSplit(strPath);

strPath	= PathUnsplit(strDir,strFilePre,strExt);
