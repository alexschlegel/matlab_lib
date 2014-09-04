function strPath = PathUnsplit(varargin)
% PathUnsplit
% 
% Description:	concatenate the parts of a path previously split with PathSplit
% 
% Syntax:	strPath = PathUnsplit([strDir],[strFile],[strExt])
% 
% In:
%	strDir	- the directory containing the file
%	strFile	- the pre-extension file name
%	strExt	- the file's extension
% 
% Out:
%	strPath	- the file path
% 
% Updated:	2011-03-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strDir,strFile,strExt]	= ParseArgs(varargin,'','','');

if ~isempty(strDir)
	strDir	= AddSlash(strDir,false);
end

if numel(strExt)
	strExt	= ['.' strExt];
end

strPath	= [strDir strFile strExt];
