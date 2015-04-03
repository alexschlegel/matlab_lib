function kStage = FreeSurferProcessGetStage(cDirFreeSurfer,varargin)
% FreeSurferProcessGetStage
% 
% Description:	get the current FreeSurferProcessGetStage stage of a set of
%				FreeSurfer directories
% 
% Syntax:	kStage = FreeSurferProcessGetStage(cDirFreeSurfer,varargin)
% 
% In:
% 	cDirFreeSurfer	- a freesurfer directory or cell of freesurfer directories
%	<options>:
%		offset:		(0) specify an integer if the return stage should be offset
%					from the actual stage (e.g. to check for the next stage to
%					process)
%		silent:		(false) true to suppress status output
% 
% Out:
% 	kStage		- an array of the current FreeSurfer processing stage of the
%				  specified freesurfer directories:
%					stage	-1:  nothing exists that should
%							0:   freesurfer directory has been set up
%							1:   autorecon1 has been run
%							1.5: autorecon1 has been checked
%							2:   autorecon2 has been run
%							2.5: autorecon2 has been checked
%							3:   autorecon3 has been run
% 
% Updated: 2015-03-18
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent kStageAll nStage cDirStage cFileStage

if isempty(kStageAll)
	kStageAll	= [-1 0 1 1.5 2 2.5 3 4];
	nStage		= numel(kStageAll);
	
	cDirStage	=	{
						{{}}
						{{'mri' 'orig'} {'mri'}}
						{{'mri'}}
						{{}}
						{{'surf'}}
						{{}}
						{{'stats'}}
						{{}}
					};
	cFileStage	=	{
						{}
						{'001'				'mgz'}
						{'brainmask'		'mgz'}
						{'stage1checked'	''}
						{'rh'				'inflated.K'}
						{'stage2checked'	''}
						{'wmparc'			'stats'}
						{}
					};
end

opt			= ParseArgs(varargin,...
				'offset'	, 0		, ...
				'silent'	, false	  ...
				);

cDirFreeSurfer	= ForceCell(cDirFreeSurfer);
sDir			= size(cDirFreeSurfer);

kStage	= kStageAll(1)*ones(sDir);
bCheck	= true(sDir);

%check for each stage
	for kS=nStage-1:-1:2
		bCheckCur			= bCheck;
		bCheckCur(bCheck)	= CheckStageFiles(cDirFreeSurfer(bCheck),cDirStage{kS},cFileStage{kS});
		
		kStage(bCheckCur)	= kStageAll(kS);
		bCheck(bCheckCur)	= false;
	end

%add the offset
	[b,kkStage]	= ismember(kStage,kStageAll);
	kkStage		= kkStage + opt.offset;
	kStage		= reshape(kStageAll(kkStage),sDir);

%------------------------------------------------------------------------------%
function b = CheckStageFiles(cDirFreeSurfer,cDirCheck,cFileCheck)
	nDirFS		= numel(cDirFreeSurfer);
	nDirCheck	= numel(cDirCheck);
	
	b	= false(nDirFS,1);
	for kD=1:nDirCheck
		cDirCur		= cDirCheck{kD};
		
		bCheck		= ~b;
		cPathCheck	= cellfun(@(d) PathUnsplit(DirAppend(d,cDirCur{:}),cFileCheck{:}),cDirFreeSurfer(bCheck),'uni',false);
		b(bCheck)	= cellfun(@FileExists,cPathCheck);
	end
%------------------------------------------------------------------------------%
