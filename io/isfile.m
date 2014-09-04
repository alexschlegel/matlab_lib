function b = isfile(strPath)
% isfile
% 
% Description:	return true if strPath is the path to a file
% 
% Syntax:	b = isfile(strPath)
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= exist(strPath,'file');
b	= b~=0 && b~=7;
