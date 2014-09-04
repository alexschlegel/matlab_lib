function strExt = PathGetExt(strPath,varargin)
% PathGetExt
% 
% Description:	extract the file extension from a file path
% 
% Syntax:	strExt = PathGetExt(strPath,<options>)
% 
% In:
% 	strPath	- the path to a file
%	<options>:	see PathSplit
% 
% Out:
% 	strExt	- the file extension
% 
% Updated:	2010-04-29
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[dummy,dummy,strExt]	= PathSplit(strPath,varargin{:});
