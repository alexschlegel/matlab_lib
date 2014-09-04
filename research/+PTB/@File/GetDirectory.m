function strDir = GetDirectory(f,strName)
% PTB.File.GetDirectory
% 
% Description:	get the path to a named directory
% 
% Syntax:	strDir = f.GetDirectory(strName)
% 
% In:
% 	strName	- the directory name (previously assigned using f.SetDirectory)
% 
% Updated: 2011-12-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the directory path
	strDir	= f.parent.Info.Get('file',{'directory',strName});
	
	sDirectories		= f.parent.Info.Get('file','directory');
	if ~isempty(sDirectories)
		cDirectories	= fieldnames(sDirectories);
		while ~isempty(strDir) && ismember(strDir,cDirectories)
			strDir	= f.parent.Info.Get('file',{'directory',strDir});
		end
	end

if isempty(strDir) && ~isequal(strName,'base')
	if isdir(strName)
		strDir	= strName;
	else
		strDir	= [];
	end
end
