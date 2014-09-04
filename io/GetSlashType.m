function strSlash = GetSlashType(varargin)
% GetSlashType
% 
% Description:	determine whether a path uses \ or / (if both are used, takes
%				the first one that occurs in the path)
% 
% Syntax:	strSlash = GetSlashType([strPath])
%
% In:
%	[strPath]	- a path
% 
% Out:
%	strSlash	- the type of slash used, or '\' if none exists
%
% Updated:	2010-02-07
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strPath	= ParseArgs(varargin,'');

kSlash	= find(strPath=='\' | strPath=='/',1,'first');

if ~isempty(kSlash)
	strSlash	= strPath(kSlash);
else
	if ispc
		strSlash	= '\';
	elseif isunix || ismac
		strSlash	= '/';
	else
		error('Slash type couldn''t be determined');
	end
end
