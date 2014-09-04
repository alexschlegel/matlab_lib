function strDir = PathGetDir(strPath)
% PathGetDir
% 
% Description:	extract the directory from path strPath
% 
% Syntax:	strDir = PathGetDir(strPath)
% 
% In:
% 	strPath	- a path to a file
% 
% Out:
% 	strDir - the directory path
% 
% Updated:	2010-01-11
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strDir	= PathSplit(strPath);
