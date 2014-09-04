function strPath = Get(f,strName)
% PTB.File.Get
% 
% Description:	get the path to a named file
% 
% Syntax:	strPath = f.Get(strName)
% 
% In:
% 	strName	- the name of the file (previously assigned using f.Set)
% 
% Updated: 2011-12-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strDir	= f.GetDirectory(f.parent.Info.Get('file',{'file','directory',strName}));
strFile	= f.parent.Info.Get('file',{'file','file',strName});

if isempty(strDir) && isempty(strFile)
	strPath	= strName;
else
	strPath	= PathUnsplit(strDir,strFile);
end
