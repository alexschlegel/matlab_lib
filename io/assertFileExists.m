function assertFileExists(cPath)
% assertFile
% 
% Description:	confirm that all files exist, and raise an error if not
% 
% Syntax:	assertFileExists(cPath)
% 
% In:
% 	cPath	- the path to a file, or a cell of file paths
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cPath	= ForceCell(cPath);
nPath	= numel(cPath);

bExist	= FileExists(cPath);

if ~all(bExist)
	error('the following files do not exist:\n%s',join(cPath(~bExist),10));
end
