function PrepExperiment(strStudy)
% PrepExperiment
% 
% Description:	prepare a MATLAB environment for an experiment. this should be
%				called from a script that is specific to an experiment and
%				handles things like declaring global variables
% 
% Syntax:	PrepExperiment(strStudy)
% 
% In:
% 	strStudy	- the name of the study
% 
% Updated: 2014-01-20
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global study strDirBase strDirCode strDirData strDirAnalysis

study	= strStudy;

%get the base study directory
	cDirRoot	=	[
						DirAppend(PathRel2Abs('~'),'studies');
						DirAppend('/','home','tselab','studies');
						cellfun(@(n) DirAppend('/','mnt','tsestudies',n), AnalysisComputers, 'uni', false)
					];
	nDirRoot	= numel(cDirRoot);
	
	bFoundBase	= false;
	for kD=1:nDirRoot
		strDirBase	= DirAppend(cDirRoot{kD},strStudy);
		
		if isdir(strDirBase)
			bFoundBase	= true;
			
			status(['base experiment directory: ' strDirBase]);
			
			break;
		end
	end
	
	if ~bFoundBase
		error(['Could not find the base directory for ' strStudy]);
	end
	
%other directories
	strDirCode		= DirAppend(strDirBase,'code');
	strDirData		= DirAppend(strDirBase,'data');
	strDirAnalysis	= DirAppend(strDirBase,'analysis');

%add the matlab paths (except directories of old matlab files)
	cDirAdd	= [strDirCode; FindDirectories(strDirCode,'(\+)|(@)|(_old)','negate',true)];
	addpath(cDirAdd{:});
	
	cd(strDirBase);

cleanup('default')

status([strStudy ' prepared...git er dun!']);
