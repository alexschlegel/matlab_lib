function strPathConfig = FSLPathConfig()
% FSLPathConfig
% 
% Description:	find the path to the FSL configuration script
% 
% Syntax:	strPathConfig = FSLPathConfig()
% 
% Out:
% 	strPathConfig	- the path to the configuration script
%
% Side-effects:	raises an error of the configuration script could not be found
% 
% Updated: 2015-03-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%only need to search for the script once 
	persistent strPath;
	
	if isempty(strPath)
		%first look in some likely directories
			cDirSearch	=	{
								'/etc/fsl/'
								'/etc/fslconf/'
							};
			nDirSearch	= numel(cDirSearch);
			
			for kD=1:nDirSearch
				strPathTest	= PathUnsplit(cDirSearch{kD},'fsl','sh');
				if FileExists(strPathTest)
					strPath	= strPathTest;
					break;
				end
			end
		
		%now try start up an interactive shell and find it from environment
		%variables
			if isempty(strPath)
				strDirFSL	= FSLDir;
				
				strPathTest	= PathUnsplit(DirAppend(strDirFSL,'etc','fslconf'),'fsl','sh');
				if FileExists(strPathTest)
					strPath	= strPathTest;
				end
			end
		
		%couldn't find it
			if isempty(strPath)
				error('could not find FSL configuration script.');
			end
	end

strPathConfig	= strPath;
