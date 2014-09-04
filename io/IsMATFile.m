function b = IsMATFile(strPath)
% IsMATFile
% 
% Description:	test if a file was saved using MATLAB's save command
% 
% Syntax:	b = IsMATFile(strPath)
% 
% Updated: 2011-12-09
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
try
	w	= whos('-file',strPath);
	b	= true;
catch me
	b	= false;
end
