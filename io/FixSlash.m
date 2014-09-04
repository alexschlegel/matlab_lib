function strPath = FixSlash(strPath)
% FixSlash
% 
% Description:	make sure all the slashes in a path string go the same way
% 
% Syntax:	strPath = FixSlash(strPath)
% 
% Updated:	2009-07-13
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strSlash	= GetSlashType(strPath);

re		= '[\\/]';
strPath	= regexprep(strPath,re,strSlash);
