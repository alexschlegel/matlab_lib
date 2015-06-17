function strDir = AddSlash(strDir)
% AddSlash
% 
% Description:	add a trailing slash to a directory path if one doesn't exist
% 
% Syntax:	strDir = AddSlash(strDir)
%
% In:
%	strDir	- a directory path string
% 
% Out:
%	strDir	- the directory path with a trailing slash
%
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strSlash	= GetSlashType(strDir);

if ~isempty(strDir) && strDir(end)~=strSlash
	strDir(end+1) = strSlash;
end
