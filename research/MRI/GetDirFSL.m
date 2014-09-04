function strDirFSL = GetDirFSL()
% GetDirFSL
% 
% Description:	get the FSL directory
% 
% Syntax:	strDirFSL = GetDirFSL()
% 
% Out:
% 	strDirFSL	- the FSL directory
% 
% Updated: 2011-03-03
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent dfsl;

if isempty(dfsl)
	if isunix
		[ec,dfsl]	= RunBashScript('echo $FSLDIR','silent',true);
		dfsl		= AddSlash(StringTrim(dfsl));
	else
		dfsl	= DirAppend(PathGetDir(mfilename('fullpath')),'fsl');
		
		if ~isdir(dfsl)
			error('Could not find the FSL directory.');
		end
	end
end

strDirFSL	= dfsl;
