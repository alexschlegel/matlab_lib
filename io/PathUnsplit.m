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
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
varargin(nargin+1:3)	= {''};
[strDir,strFile,strExt]	= deal(varargin{1:3});

if ~isempty(strExt)
	strExt	= ['.' strExt];
end

strPath	= [AddSlash(strDir) strFile strExt];
