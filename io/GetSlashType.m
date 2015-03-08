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
% Updated:	2015-03-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if nargin>0
	strPath	= varargin{1};
	kSlash	= find(strPath=='\' | strPath=='/',1,'first');
else
	kSlash	= [];
end

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
