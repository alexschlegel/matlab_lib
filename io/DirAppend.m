function strDir = DirAppend(strDir,varargin)
% DirAppend
% 
% Description:	append subdirectories to a directory path string
% 
% Syntax:	strDir = DirAppend(strDir,strSubdir1,...,strSubdirN)
% 
% In:
% 	strDir		- the directory path
%	strSubdirK	- a string/char of the name(s) of the subdirectory/ies to append
% 
% Out:
% 	strDir	- the new directory path
% 
% Updated:	2011-03-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the slash type
	if any(strDir=='\')
		strSlash	= '\';
	else
		strSlash	= '/';
	end
%add a slash to the end of the directory
	if numel(strDir) && strDir(end)~=strSlash
		strDir	= [strDir strSlash];
	end
%append the subdirectories
	strAppend	= '';
	for k=1:nargin-1
		strAppend	= [strAppend varargin{k} strSlash];
	end
	
	strDir	= [strDir strAppend];
