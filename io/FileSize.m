function n = FileSize(strPath)
% FileSize
% 
% Description:	returns the size (in bytes) of a file
% 
% Syntax:	n = FileSize(strPath)
%
% In:
%	strPath	- the path to a file
% 
% Out:
%	n	- the size of the file
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

d	= dir(strPath);
if numel(d)
	n	= d(1).bytes;
else
	n	= -1;
end
