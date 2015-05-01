function [bSuccess,cDirOut] = FreeSurferProcess(cPathStructural,varargin)
% FreeSurferProcess
% 
% Description:	run a structural data set through the freesurfer reconstruction
%				pipeline. the pipeline is divided into four stages:
%					0)   set up the freesurfer directory structure for the data
%					1)   normalization, talairaching, skull stripping
%					1.5) check the results of stage 1 
%					2)   segmentation, cortex models
%					2.5) check the results of stage 2
%					3)   cortex spheres, measurements, parcellation
% 
% Syntax:	bSuccess = FreeSurferProcess(cPathStructural,<options>)
% 
% In:
% 	cPathStructural	- the path to a structural data set, or a cell of paths to
%					  run the pipeline on each data set independently, or a cell
%					  of cells of paths to run the pipeline on each set of data
%					  sets (i.e. multiple structurals for one reconstruction)
%	<options>:
%		stage:			(<all>) an array of the stages to process, or a string
%						specifying a specific stage (e.g. '-skullstrip')
%		stage_check:	(true) true to make sure the data is ready to be
%						processed at the specified stage(s)
%		check_results:	(true) true to perform the intermediate result checking
%						stages
%		wmedit:			(false) true if running stage 2 for the second time
%						after making white matter edits
%		opt:			('') extra options for the recon-all calls
%		force:			(false) true to redo the specified processing steps
%		cores:			(1) the number of processor cores to use
%		silent:			(false) true to suppress status updates
% 
% Out:
% 	bSuccess	- a logical array indicating which data sets were successfully
%				  processed
%	cDirOut		- the freesurfer directory or cell of directories associated with
%				  the input
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'stage'			, [0 1 1.5 2 2.5 3]	, ...
		'stage_check'	, true				, ...
		'check_results'	, true				, ...
		'wmedit'		, false				, ...
		'opt'			, ''				, ...
		'force'			, false				, ...
		'cores'			, 1					, ...
		'silent'		, false				  ...
		);

bSuccess	= false(0);
bCustom		= ischar(opt.stage);

%format the input
	cPathStructural	= ForceCell(cPathStructural);
	cPathStructural	= cellfun(@ForceCell,cPathStructural,'UniformOutput',false);
	sPathStructural	= size(cPathStructural);
	nPathStructural	= numel(cPathStructural);
	
	bDestroy					= cellfun(@isempty,cPathStructural);
	cPathStructural(bDestroy)	= [];
%get the output directories
	cDirOut	= cellfun(@(c) DirAppend(PathGetDir(c{1}),'freesurfer'),cPathStructural,'UniformOutput',false);

if bCustom
	bSuccess	= FreeSurferProcessStage(cPathStructural,cDirOut,opt.stage);
else
%process each stage
	bSuccess	= true(sPathStructural);
	
	nStage	= numel(opt.stage);
	
	progress('action','init','total',nStage,'label','Processing FreeSurfer Stages','status',true,'silent',opt.silent);
	for kS=1:nStage
		kSuccess	= find(bSuccess);
		
		kStageCur		= opt.stage(kS);
		strStage		= num2str(kStageCur);
		
		%get the stage of each data set
			kStage	= FreeSurferProcessGetStage(cDirOut(kSuccess),'offset',1,'silent',opt.silent);
		%check for invalid stage selections
			bReady				= ~opt.stage_check | (kStage>=kStageCur);
			bSuccess(bSuccess)	= bReady;
			if ~all(bReady)
				status(join([{['The following directories are not yet ready for FreeSurferProcess stage ' strStage ':']}; reshape(cDirOut(~bReady),[],1)],10),'warning',true,'silent',opt.silent);
			end
		%get the files to process at the current stage
			bProcess	= bReady & (opt.force | kStage==kStageCur);
			
			cPathStructuralCur	= cPathStructural(kSuccess(bProcess));
			cDirOutCur			= cDirOut(kSuccess(bProcess));
		%process them!
			if any(bProcess)
				bSuccessCur						= FreeSurferProcessStage(cPathStructuralCur,cDirOutCur,kStageCur);
				bSuccess(kSuccess(bProcess))	= bSuccessCur;
				
				%check for errors
					if ~all(bSuccessCur)
						status(['FreeSurferProcess stage ' strStage ' failed for:' 10 join(cDirOutCur(~bSuccessCur),10)],'warning',true,'silent',opt.silent);
					end
			end
		
		progress;
	end
end

%------------------------------------------------------------------------------%
function bSuccess = FreeSurferProcessStage(cPathStructural,cDirOut,kStage)
	strStage	= num2str(kStage);
	
	cDirBase	= cellfun(@(d) DirSub(d,1,-1),cDirOut,'UniformOutput',false);
	cSubject	= cellfun(@(d) DirSub(d,0,0),cDirOut,'UniformOutput',false);
	
	%options for CallProcess/RunBashScript calls
		strPrefix	= ['freesurferprocess-' strStage];
		cOpt		=	{
							'file_prefix'	, strPrefix		, ...
							'cores'			, opt.cores		, ...
							'silent'		, opt.silent	  ...
						};
	%run the stage
		cExtraOpt	= split(opt.opt,'\s+');
		
		if ischar(kStage)
			bSuccess	= ~CallProcess('freesurferscript',{cDirBase 'recon-all' strStage cExtraOpt{:} '-subjid' cSubject},cOpt{:},...
							'description'	, 'running custom recon-all step'	  ...
							);
		else
			switch kStage
				case 0
					cArgInput	= cellfun(@(c) ['-i ' join(c,' -i ')],cPathStructural,'UniformOutput',false);
					
					bSuccess	= ~CallProcess('freesurferscript',{cDirBase 'recon-all' cExtraOpt{:} cArgInput '-subjid' cSubject},cOpt{:},...
									'description'	, 'setting up FreeSurfer directories'	  ...
									);
				case 1
					bSuccess	= ~CallProcess('freesurferscript',{cDirBase 'recon-all' cExtraOpt{:} '-autorecon1' '-subjid' cSubject},cOpt{:},...
									'description'	, 'running autorecon1'	  ...
									);
				case 1.5
					bSuccess	= FreeSurferCheck(cDirOut,1,'check',opt.check_results);
				case 2
					strExtra	= conditional(opt.wmedit,'-wm','');
					
					bSuccess	= ~CallProcess('freesurferscript',{cDirBase 'recon-all' cExtraOpt{:} ['-autorecon2' strExtra] '-subjid' cSubject},cOpt{:},...
									'description'	, 'running autorecon2'	  ...
									);
				case 2.5
					[bSuccess,bRerun]	= deal(true(size(cDirOut)));
					
					while any(bRerun)
						[bSuccess(bRerun),bRerun(bRerun)]	= FreeSurferCheck(cDirOut(bRerun),2,'check',opt.check_results);
						
						if any(bRerun)
							bWMEditOld	= opt.wmedit;
							opt.wmedit	= true;
							
							bSuccess(bRerun)	= FreeSurferProcessStage(cPathStructural(bRerun),cDirOut(bRerun),2);
							bRerun(bRerun)		= bSuccess(bRerun) & bRerun(bRerun);
							
							opt.wmedit	= bWMEditOld;
						end
					end
				case 3
					bSuccess	= ~CallProcess('freesurferscript',{cDirBase 'recon-all' cExtraOpt{:} '-autorecon3' '-subjid' cSubject},cOpt{:},...
									'description'	, 'running autorecon3'	  ...
									);
				otherwise
					error(['"' strStage '" is an invalid stage.']);
			end
		end
	
end
%------------------------------------------------------------------------------%

end
