function t = FileModTime(strPathFile)
% FileModTime
% 
% Description:	get the modification time of a file as number of milliseconds
%				since the epoch
% 
% Syntax:	t = FileModTime(strPathFile)
% 
% In:
% 	strPathFile	- path to a file
% 
% Out:
% 	t	- file modification time of the file
% 
% Updated:	2009-08-10
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the modification time as a serial date number
	d	= dir(strPathFile);
	d	= d.datenum;
%convert to number of milliseconds since the epoch
	t	= d * 86400000;