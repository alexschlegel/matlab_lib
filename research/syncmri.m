function syncmri
% syncmri
% 
% Description:	sync the raw MRI data from rolando to the raw data folder. this
%				function assumes a PrepXXX script has been called and global
%				study and strDirData variables are defined
% 
% Syntax:	syncmri
% 
% Updated: 2014-01-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global study strDirData

if isempty(study) || isempty(strDirData)
	error('A PrepXXX script must be called before running this function.');
end

%mount rolando
	[strDirRolando,tMount]	= MountRolando;

%get the to and from paths
	strDirRaw		= DirAppend(strDirData,'raw');
	cDirSource		= FindRolandoDirs;
	cDirSourceRel	= cellfun(@(d) PathAbs2Rel(d,strDirRolando),cDirSource,'uni',false);
	
	strPrompt	= sprintf('Detected the following source and destination directories:\nSource:\n%s\nDestination: %s\nContinue?',...
					join(cDirSourceRel,10)	, ...
					strDirRaw				  ...
					);
	res	= ask(strPrompt,'dialog',false,'choice',{'y','n'});
	
	if ~isequal(res,'y')
		error('aborted.');
	end

%sync!
	nDirSource	= numel(cDirSource);
	for kD=1:nDirSource
		SyncDir(cDirSource{kD});
	end

%unmount rolando
	UnmountRolando;


%------------------------------------------------------------------------------%
function [strDirRolando,tMount]	= MountRolando()
	status('mounting rolando');
	
	%get a temporary directory
		strDirRolando	= GetTempDir;
	%mount rolando into it
		sshmount(...
			'user'			, 'tse'							, ...
			'host'			, 'rolando.cns.dartmouth.edu'	, ...
			'remote_dir'	, '/inbox/INTERA/'				, ...
			'local_dir'		, strDirRolando					  ...
			);
	
	tMount	= nowms;
end
%------------------------------------------------------------------------------%
function UnmountRolando()
	status('unmounting rolando');
	
	%make sure we wait at least five seconds after mounting (i'm getting
	%device busy errors)
	while nowms < tMount + 5000
		WaitSecs(0.1);
	end
	
	sshumount(strDirRolando);
	
	%remove the temporary directory
		rmdir(strDirRolando);
end
%------------------------------------------------------------------------------%
function cDirSource = FindRolandoDirs()
%find the rolando paths that contain data for the study
	cDirSearch	= FindDirectories(strDirRolando);
	
	cDirSource	= cellfun(@(d) DirAppend(d, study), cDirSearch, 'uni', false);
	
	cDirSource	= cDirSource(cellfun(@isdir,cDirSource));
end
%------------------------------------------------------------------------------%
function SyncDir(strDir)
	strDirRel	= PathAbs2Rel(strDir,strDirRolando);
	
	status(['syncing dir: ' strDirRel]);
	
	strCommand	= sprintf('rsync -harvz %s %s', strDir, strDirRaw);
	
	[ec,out]	= RunBashScript(strCommand);
end
%------------------------------------------------------------------------------%

end
