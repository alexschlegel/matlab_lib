function strDirHome = GetHomeDir()
% GetHomeDir
% 
% Description:	get a user's home directory
% 
% Syntax:	strDirHome = GetHomeDir()
% 
% Updated: 2011-12-09
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ispc
	strDirHome	= getenv('USERPROFILE');
else
	strDirHome	= getenv('HOME');
end

if ~isdir(strDirHome)
	strDirHome	= '';
end
