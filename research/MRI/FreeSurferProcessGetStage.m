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
% Updated: 2012-03-12
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt			= ParseArgs(varargin,...
				'offset'	, 0		, ...
				'silent'	, false	  ...
				);
kStageAll	= [-1 0 1 1.5 2 2.5 3 4];
nStage		= numel(kStageAll);

cDirFreeSurfer	= ForceCell(cDirFreeSurfer);
sDir			= size(cDirFreeSurfer);

kStage	= -1*ones(sDir);
bCheck	= true(sDir);

%check for stage 3
	bInStage			= bCheck;
	bInStage(bCheck)	= cellfun(@(d) FileExists(PathUnsplit(DirAppend(d,'stats'),'wmparc','stats')),cDirFreeSurfer(bCheck));
	
	kStage(bInStage)	= 3;
	bCheck(bInStage)	= false;
%check for stage 2.5
	bInStage			= bCheck;
	bInStage(bCheck)	= cellfun(@(d) FileExists(PathUnsplit(d,'stage2checked','')),cDirFreeSurfer(bCheck));
	
	kStage(bInStage)	= 2.5;
	bCheck(bInStage)	= false;
%check for stage 2
	bInStage			= bCheck;
	bInStage(bCheck)	= cellfun(@(d) FileExists(PathUnsplit(DirAppend(d,'surf'),'rh','inflated.K')),cDirFreeSurfer(bCheck));
	
	kStage(bInStage)	= 2;
	bCheck(bInStage)	= false;
%check for stage 1.5
	bInStage			= bCheck;
	bInStage(bCheck)	= cellfun(@(d) FileExists(PathUnsplit(d,'stage1checked','')),cDirFreeSurfer(bCheck));
	
	kStage(bInStage)	= 1.5;
	bCheck(bInStage)	= false;
%check for stage 1
	bInStage			= bCheck;
	bInStage(bCheck)	= cellfun(@(d) FileExists(PathUnsplit(DirAppend(d,'mri'),'brainmask','mgz')),cDirFreeSurfer(bCheck));
	
	kStage(bInStage)	= 1;
	bCheck(bInStage)	= false;
%check for stage 0
	bInStage			= bCheck;
	bInStage(bCheck)	= cellfun(@(d) FileExists(PathUnsplit(DirAppend(d,'mri','orig'),'001','mgz')),cDirFreeSurfer(bCheck));
	
	kStage(bInStage)	= 0;
	bCheck(bInStage)	= false;

%add the offset
	[b,kkStage]	= ismember(kStage,kStageAll);
	kkStage		= kkStage + opt.offset;
	kStage		= kStageAll(kkStage);
