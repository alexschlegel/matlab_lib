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
% Updated:	2010-02-07
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isempty(cDir)
	strDir	= '';
	return;
end

strSlash	= GetSlashType();

strDir	= join(cDir,strSlash);

%make sure we're not getting double slashes
	strDir	= strrep(strDir,[strSlash strSlash],strSlash);

%add a slash
	strDir	= AddSlash(strDir);	
