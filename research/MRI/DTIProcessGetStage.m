function [kStage,cSession] = DTIProcessGetStage(cDirSession,varargin)
% DTIProcessGetStage
% 
% Description:	get the current DTIProcess stage of a set of DTI directories
% 
% Syntax:	[kStage,cSession] = DTIProcessGetStage(cDirSession,<options>)
% 
% In:
%	cDirSession	- a session directory or cell of session directories
%	<options>:
%		nfibres:	(2) the number of fibers specified in the bedpostx advanced
%					options
%		offset:		(0) specify an integer if the return stage should be offset
%					from the actual stage (e.g. to check for the next stage to
%					process)
%		silent:		(false) true to suppress status output
% 
% Out:
% 	kStage		- an array of the current DTI processing stage of the specified
%				  sessions:
%					stage	0:		nothing exists that should
%							0.1:	data.nii exists
%							0.2:	bvecs and bvals exist
%							1:		b0 image exists
%							2:		brain image exists
%							3:		eddy_corrected files exist
%							4:		diffusion tensor files exist
%							5:		bedpostx files exist
%	cSession	- an Nx1 array of the sessions
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt			= ParseArgs(varargin,...
				'nfibres'	, 2		, ...
				'offset'	, 0		, ...
				'silent'	, false	  ...
				);
kStageAll	= [0 0.1 0.2 1:5];
nStage		= numel(kStageAll);

cDirSession	= ForceCell(cDirSession);
sSession	= size(cDirSession);
nSession	= numel(cDirSession);
kStage		= zeros(sSession);
cSession	= cell(sSession);

progress('action','init','total',nSession,'label','Determining DTI Processing Stage','silent',opt.silent);
for kS=1:nSession
	cSession{kS}	= PathGetSession(cDirSession{kS});
	
	if isempty(cSession{kS})
		cSession(kS)	= DirSplit(cDirSession{kS},'limit',1);
	end
	
	for kT=nStage:-1:1
		cPathCheck	= DTIProcessStageFiles(cDirSession{kS},kStageAll(kT),'nfibres',opt.nfibres);
		nFile		= numel(cPathCheck);
		
		bFilesExist	= true;
		for kF=1:nFile
			[strDirCheck,strFilePreCheck,strExtCheck]	= PathSplit(cPathCheck{kF});
			
			if isdir(strDirCheck)
				if ~isempty(strFilePreCheck) || ~isempty(strExtCheck)
					strFileCheck	= [strFilePreCheck conditional(isempty(strExtCheck),'','.') strExtCheck];
					
					if isempty(FindFiles(strDirCheck,strFileCheck))
						bFilesExist	= false;
						break;
					end
				end
			else
				bFilesExist	= false;
				break;
			end
		end
		
		if bFilesExist
			break;
		end
	end
	
	kT	= max(1,kT+opt.offset);
	if kT>nStage
		kStage(kS)	= kStageAll(nStage)+opt.offset;
	else
		kStage(kS)	= kStageAll(kT);
	end
	
	progress;
end
