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
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if nargin>0
	if any(varargin{1}=='/')
		strSlash	= '/';
		return;
	elseif any(varargin{1}=='\')
		strSlash	= '\';
		return;
	end
end

strSlash	= filesep;
