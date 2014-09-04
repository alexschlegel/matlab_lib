function b = Close(f,strName)
% PTB.File.Close
% 
% Description:	close a text file for opened with PTB.File.Open
% 
% Syntax:	f.Close(strName)
% 
% In:
% 	strName	- the name of the file (previously assigned using f.Set)
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
fid	= f.parent.Info.Get('file',{'fid',strName});

try
	fclose(fid);
	
	f.parent.Info.Unset('file',{'fid',strName});
catch me
end
