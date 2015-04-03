function strDirFSL = FSLDir()
% FSLDir
% 
% Description:	find the root FSL path
% 
% Syntax:	strDirFSL = FSLDir()
% 
% Side-effects:	raises an error of the FSL directory could not be found
% 
% Updated: 2015-03-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%only need to search for the directory once 
	persistent strDir;
	
	if isempty(strDir)
		%first look in common places
			cDirSearch	=	{
								'/usr/share/fsl/'
							};
			nDirSearch	= numel(cDirSearch);
			
			for kD=1:nDirSearch
				strDirSearch	= cDirSearch{kD};
				if isdir(strDirSearch)
					%get the subdirectories
						dSub	= dir(strDirSearch);
						dSub	= dSub([dSub.isdir]);
						cDirSub	= setdiff({dSub.name},{'.','..'});
					%find the ones that are numbers (i.e. versions)
						nVersion	= cellfun(@str2num,cDirSub,'uni',false);
						kKeep		= find(~cellfun(@isempty,nVersion));
					%get the maximum of those
						if ~isempty(kKeep)
							[v,kMax]	= max(cell2mat(nVersion(kKeep)));
							strDir		= DirAppend(strDirSearch,cDirSub{kKeep(kMax)});
							break;
						end
				end
			end
		
		%try to start up an interactive shell and find it from its environment
		%variable
			if isempty(strDir)
				cScript			=	{
										'#!/bin/bash -i'
										'unset LD_LIBRARY_PATH'
										'echo $FSLDIR'
									};
				strScript		= join(cScript,10);
				strPathScript	= tempname;
				fput(strScript,strPathScript);
				fileattrib(strPathScript,'+x');
				[ec,str]	= system(strPathScript);
				delete(strPathScript);
				
				if ~isempty(str)
					cStr	= split(str,10);
					if isdir(cStr{end})
						strDir	= AddSlash(cStr{end});
					end
				end
			end
		
		%couldn't find it
			if isempty(strDir)
				error('could not find root FSL directory.');
			end
	end

strDirFSL	= strDir;
