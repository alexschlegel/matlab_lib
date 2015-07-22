function b = IsMATFile(strPath)
% IsMATFile
% 
% Description:	test if a file was saved using MATLAB's save command
% 
% Syntax:	b = IsMATFile(strPath)
%
% Note:	this only supports Level 5 .mat files
% 
% Updated: 2015-07-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
try
	fid	= fopen(strPath,'r');
	str	= fread(fid,[1 6]);
	b	= all(str=='MATLAB');
	fclose(fid);
catch me
	b	= false;
end
