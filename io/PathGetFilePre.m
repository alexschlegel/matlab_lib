function strFilePre = PathGetFilePre(strPath,varargin)
% PathGetFilePre
% 
% Description:	extract the pre-extension file name from a file path
% 
% Syntax:	strFilePre = PathGetFilePre(strPath,<options>)
% 
% In:
% 	strPath	- the path to a file
%	<options>:	see PathSplit
% 
% Out:
% 	strFilePre	- the file's pre-extension file name
% 
% Updated:	2010-04-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[dummy,strFilePre,dummy]	= PathSplit(strPath,varargin{:});
