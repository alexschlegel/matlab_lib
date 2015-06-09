function b = FileExists(cPath)
% FileExists
% 
% Description:	determine if files exist
% 
% Syntax:	b = FileExists(cPath)
% 
% In:
% 	cPath	- the path to a file, or a cell of file paths
% 
% Out:
% 	b	- a logical array indicating which files exist
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if iscell(cPath)
	b	= cellfun(@FileExists,cPath);
else
	b	= exist(cPath,'file');
	b	= b & b~=7; %make sure it's not a directory
end
