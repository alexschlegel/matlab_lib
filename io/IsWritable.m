function b = IsWritable(strDir)
% IsWritable
% 
% Description:	determine if a directory is writable
% 
% Syntax:	b = IsWritable(strDir)
% 
% Updated: 2011-12-09
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(strDir) || ~isdir(strDir)
	b	= false;
else
	%get the path to a temporary file in the directory
		strPathTemp	= GetTempFile('base',PathUnsplit(strDir,'temp'));
	%try to write something to it
		b	= fput('meow',strPathTemp);
	%delete it if we were successful
		if b
			try
				delete(strPathTemp);
			catch me
			end
		end
end
