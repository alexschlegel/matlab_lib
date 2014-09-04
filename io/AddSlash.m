function strPath = AddSlash(strPath,varargin)
% AddSlash
% 
% Description:	add a trailing slash to a path if one doesn't exist.  note that
%				nothing is added if strPath is an existing file.
% 
% Syntax:	strPath = AddSlash(strPath,[bCheckFile]=true)
%
% In:
%	strPath			- a path string
%	[bCheckFile]	- true to make sure strPath isn't a file before adding a
%					  slash
% 
% Out:
%	strPath	- the path with a trailing slash
%
% Updated:	2011-03-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bCheckFile	= nargin<2 || varargin{1};

if (~bCheckFile || ~isfile(strPath)) && ~isempty(strPath)
	strSlash	= GetSlashType(strPath);
	strPath		= FixSlash(strPath);
	
	if strPath(end) ~= strSlash
		strPath = [strPath strSlash];
	end
end
