function b = Append(f,str,strName)
% PTB.File.Append
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
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

b	= false;

if isfield(PTBIFO.file.fid,strName)
	fid	= PTBIFO.file.fid.(strName);
else
	fid	= [];
end

if ~isempty(fid)
	try
		nWritten	= fwrite(fid,str);
		b			= nWritten==numel(str);
	catch me
	%maybe the file wasn't open
		try
			if f.Open(strName)
				fid			= PTBIFO.file.fid.(strName);
				nWritten	= fwrite(fid,str);
				b			= nWritten==numel(str);
			else
				f.AddLog(['error appending "' strName '"']);
			end
		catch me
			f.AddLog(['error appending "' strName '"']);
		end
	end
else
	strPath	= f.Get(strName);
	strOld	= fget(strPath,'error',false);
	b		= fput([strOld reshape(str,1,[])],strPath);
end
