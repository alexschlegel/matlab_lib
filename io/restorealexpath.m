function restorealexpath()
% restorealexpath
% 
% Description:	restore the path to the initial state with Alex's MATLAB library
%				and other good stuff
% 
% Syntax: restorealexpath()
% 
% Updated:	2016-01-13
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strDirCode	= DirAppend(GetDirUser,'code','MATLAB');

cDirAdd	= {};

%add the MATLAB library path
	strDirLib	= DirAppend(strDirCode,'lib');
	AddToPath(strDirLib,true,{'_old','\.git','/@','/\+'});

%add fieldtrip
	strDirFT	= DirAppend(strDirCode,'tools','fieldtrip');
	AddToPath(strDirFT,false,{});

%add spm
	strDirSPM	= DirAppend(matlabroot,'toolbox','spm8');
	if ~AddToPath(strDirSPM,false,{})
		strDirSPM	= DirAppend(strDirCode,'tools','spm8');
		AddToPath(strDirSPM,false,{});
	end
	
%add the PsychToolbox path
	strDirPTB	= DirAppend(matlabroot,'toolbox','Psychtoolbox');
	AddToPath(strDirPTB,true,{'\.svn','private/$'});

%construct the path to add
	strPathAdd	= join(cDirAdd,':');

%restore the to the default state
	restoredefaultpathWrapper;

%add the other paths
	addpath(strPathAdd);


%-------------------------------------------------------------------------------
function b = AddToPath(strDir,bSubDir,cREExclude)
	b	= isdir(strDir);
	
	if b
		if bSubDir
			cDir	= [strDir; FindDirectories(strDir,'subdir',true)];
		else
			cDir	= ForceCell(strDir);
		end
		
		if ~isempty(cREExclude)
			bExclude	= cellfun(@(re) ~cellfun(@isempty,regexp(cDir,re)),cREExclude,'uni',false);
			bExclude	= any(cat(2,bExclude{:}),2);
			
			cDir(bExclude)	= [];
		end
		
		cDirAdd	= [cDirAdd; cDir];
	end
end
%-------------------------------------------------------------------------------

end

function restoredefaultpathWrapper
%i get an error about adding variables to the static workspace otherwise
	restoredefaultpath;
end
