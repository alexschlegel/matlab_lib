function strFileName = PathGetFileName(strPath)
% PathGetFileName
% 
% Description:	extract the file name from path strPath
% 
% Syntax:	strFileName = PathGetFileName(strPath)
% 
% In:
% 	strPath	- a path to a file
% 
% Out:
% 	strFileName	- the file name
% 
% Updated:	2009-05-03
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[d,strFilePre,strExt]	= PathSplit(strPath);

if ~isempty(strExt)
	strExt	= ['.' strExt];
end

strFileName	= [strFilePre strExt];
