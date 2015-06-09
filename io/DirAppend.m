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
% Updated: 2015-03-16
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the slash type
	strSlash	= GetSlashType(strDir);
%join the path together
	strDir	= join([strDir varargin],strSlash);
%make sure we don't have double slashes
	strDir	= strrep(strDir,[strSlash strSlash],strSlash);
