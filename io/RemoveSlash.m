function strPath = RemoveSlash(strPath)
% RemoveSlash
% 
% Description:	remove the trailing slash from a path if one exists
% 
% Syntax:	strPath = RemoveSlash(strPath)
%
% In:
%	strPath	- a path string
% 
% Out:
%	strPath	- the path without a trailing slash
%
% Updated:	2009-07-17
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strSlash	= GetSlashType(strPath);
strPath		= FixSlash(strPath);

if strPath(end) == strSlash
	strPath = strPath(1:end-1);
end
