function x = Read(f,strName)
% Group.File.Read
% 
% Description:	read data from a named file
% 
% Syntax:	x = f.Read(strName)
% 
% In:
% 	strName	- the name of the file (previously assigned using f.Set)
% 
% Out:
%	x	- the data stored in the named file
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPath	= f.Get(strName);

x	= [];

if FileExists(strPath)
	if IsMATFile(strPath)
		s	= load(strPath);
		
		cField	= fieldnames(s);
		if numel(cField)>0
			x		= s.(cField{1});
		end
	else
		x	= fget(strPath);
	end
end
