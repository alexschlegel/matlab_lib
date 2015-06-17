function strDir = DirUnsplit(cDir)
% DirUnsplit
% 
% Description:	unsplit a cell of directories split with DirSplit
% 
% Syntax:	strDir = DirUnsplit(cDir)
% 
% In:
% 	cDir	- a cell of directories representing the path
% 
% Out:
% 	strDir	- the directory path
% 
% Example:	DirUnsplit({'c:','temp','blah'}) => 'c:\temp\blah\'
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if isempty(cDir)
	strDir	= '';
	return;
end

strSlash	= GetSlashType;

strDir	= join(cDir,strSlash);

%make sure we're not getting double slashes
	strDir	= strrep(strDir,[strSlash strSlash],strSlash);

%add a slash
	strDir	= AddSlash(strDir);
