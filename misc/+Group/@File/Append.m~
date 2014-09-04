function b = Append(f,str,strName)
% Group.File.Append
% 
% Description:	append a string to a named text file
% 
% Syntax:	b = f.Append(str,strName)
% 
% In:
%	str		- the string to append
% 	strName	- the file name (previously assigned using f.Set)
% 
% Out:
%	b	- true if the file was successfully appended
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= false;

fid	= f.Info.Get({'fid',strName});

if ~isempty(fid)
	try
		nWritten	= fwrite(fid,str);
		b			= nWritten==numel(str);
	catch me
	%maybe the file wasn't open
		try
			if f.Open(strName)
				fid			= f.Info.Get({'fid',strName});
				nWritten	= fwrite(fid,str);
				b			= nWritten==numel(str);
			else
				f.Log.Append(['error appending "' strName '"']);
			end
		catch me
			f.Log.Append(['error appending "' strName '"']);
		end
	end
else
	strPath	= f.Get(strName);
	strOld	= fget(strPath,'error',false);
	b		= fput([strOld reshape(str,1,[])],strPath);
end
