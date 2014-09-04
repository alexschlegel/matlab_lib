function b = Close(f,strName)
% Group.File.Close
% 
% Description:	close a text file for opened with Group.File.Open
% 
% Syntax:	f.Close(strName)
% 
% In:
% 	strName	- the name of the file (previously assigned using f.Set)
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
fid	= f.Info.Get({'fid',strName});

try
	fclose(fid);
	
	f.Info.Unset({'fid',strName});
catch me
end
