function bSuccess = DTIProcess(cDirSession,varargin)
% DTIProcess
% 
% Description:	perform one or all of the following on a raw NIfTI DTI data
%				set(s) with bvecs/bvals files:
%					1) save the b0 image
%					2) extract the brain image
%					3) perform eddy correction
%					4) fit diffusion tensors
%					5) bedpostx preparation for tractography
%				Note:	the process must start with one directory for each data
%						set, containing the following files:
%							data.nii(.gz)
%							bvecs
%							bvals
% 
% Syntax:	bSuccess = DTIProcess(cDirSession,<options>)
% 
% In:
% 	cDirSession	- the session directory or a cell of directories
%	<options>:
%		stage:			(<all>) an array of stages to perform (see above)
%		stage_check:	(true) true to make sure the data is ready to be
%						processed at the specified stage(s)
%		b0volume:		(<determine from bvals>) the index of the b=0 volume in
%						data.nii.gz
%		f_thresh:		(<FSLBet default>) the fractional intesity threshold for
%						bet brain extraction
%		f_prompt:		(<false if f_thresh specified>) true to display the
%						results of brain extraction and prompt for a new f value
%		propagate:		(true) true to propagate user-input changes in
%						parameters
%		nfibres:		(2) the number of fibers option for bedpostx
%		log:			(true) true/false to specify whether logs should be
%						saved to the default location, or the path/cell of paths
%						to a log file to save
%		force:			(true) true to redo the specified processing steps
%		cores:			(1) the number of processor cores to use
%		silent:			(false) true to suppress status updates.  command
%						outputs are still displayed in the command window if
%						substage 2 is involved since it requires user input
% 
% Out:
% 	bSuccess	- a logical array indicating which sessions were successfully
%				  processed
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'stage'			, 1:5	, ...
		'stage_check'	, true	, ...
		'b0volume'		, []	, ...
		'f_thresh'		, []	, ...
		'f_prompt'		, []	, ...
		'propagate'		, true	, ...
		'nfibres'		, 2		, ...
		'log'			, true	, ...
		'force'			, true	, ...
		'cores'			, 1		, ...
		'silent'		, false	  ...
		);

cDirSession	= cellfun(@AddSlash,ForceCell(cDirSession),'UniformOutput',false);

%get the log paths
	[bAppend,bAppendCur]	= deal(false);
	if isequal(opt.log,true)
		[cPathScript,cPathLog]	= deal(cDirSession);
	elseif isequal(opt.log,false)
		[cPathScript,cPathLog]	= deal([]);
	else
		cPathLog	= ForceCell(opt.log);
		cPathScript	= cellfun(@(fl) PathAddSuffix(fl,'','sh'),cPathLog,'UniformOutput',false);
		bAppend		= true;
	end
%input paths
	sSession	= size(cDirSession);
	nSession	= numel(cDirSession);

%process each stage
	bSuccess	= true(sSession);
	nStage		= numel(opt.stage);
	
	progress('action','init','total',nStage,'label','Processing DTI Stages','status',true,'silent',opt.silent);
	for kS=1:nStage
		kSuccess		= find(bSuccess);
		
		kStageCur		= opt.stage(kS);
		strStage		= num2str(kStageCur);
		
		%get the stage of each session
			[kStageSession,cSession]	= DTIProcessGetStage(cDirSession(kSuccess),'nfibres',opt.nfibres,'offset',1,'silent',opt.silent);
		%check for invalid stage selections
			bReady				= ~opt.stage_check | (kStageSession>=kStageCur);
			bSuccess(bSuccess)	= bReady;
			if ~all(bReady)
				status(join([{['The following sessions are not yet ready for DTIProcess stage ' strStage ':']}; reshape(cSession(~bReady),[],1)],10),'warning',true,'silent',opt.silent);
			end
		%get the files to process at the current stage
			bProcess	= bReady & (opt.force | kStageSession==kStageCur);
			
			cDirSessionCur	= cDirSession(kSuccess(bProcess));
			cSessionCur		= cSession(bProcess);
		%process them!
			if any(bProcess)
				bSuccessCur						= DTIProcessStage(cDirSessionCur,cSessionCur,kStageCur);
				bSuccess(kSuccess(bProcess))	= bSuccessCur;
				
				%check for errors
					if ~all(bSuccessCur)
						status(['DTIProcess stage ' strStage ' for ' join(cSessionCur(~bSuccessCur),',') ' failed!'],'warning',true,'silent',opt.silent);
					end
			end
		
		progress;
	end

%------------------------------------------------------------------------------%
function bSuccess = DTIProcessStage(cDirSession,cSession,kStage)
% call one stage of the DTI processing pipeline
	strStage	= num2str(kStage);
	strPlural	= plural(numel(cDirSession),'','s');
	
	%relevant files
		cPathDataRaw	= cellfun(@GetPathRaw,cDirSession,'UniformOutput',false);
		cPathDataOrig	= cellfun(@(f) PathAddSuffix(f,'-orig','favor','nii.gz'),cPathDataRaw,'UniformOutput',false);
		cPathData		= cellfun(@(x) PathUnsplit(x,'data','nii.gz'),cDirSession,'UniformOutput',false);
		cPathNoDif		= cellfun(@(x) PathUnsplit(x,'nodif','nii.gz'),cDirSession,'UniformOutput',false);
		cPathBVecs		= cellfun(@(x) PathUnsplit(x,'bvecs'),cDirSession,'UniformOutput',false);
		cPathBVals		= cellfun(@(x) PathUnsplit(x,'bvals'),cDirSession,'UniformOutput',false);
	%options for CallProcess/RunBashScript calls
		strPrefix	= ['dtiprocess-' strStage];
		cOpt		=	{
							'file_prefix'	, strPrefix		, ...
							'script_path'	, cPathScript	, ...
							'script_append'	, bAppendCur	, ...
							'log_path'		, cPathLog		, ...
							'log_append'	, bAppendCur	, ...
							'cores'			, opt.cores		, ...
							'silent'		, opt.silent	  ...
						};
	%run the stage
		switch kStage
			case 1
				b0			= GetB0(cPathBVals);
				bSuccess	= ~CallProcess('fslroi',{cPathDataRaw cPathNoDif b0 1},cOpt{:},...
								'description'	, ['Saving b0 image' strPlural]	 ...
								);
			case 2
				bSuccess	= cellfunprogress(@(fn) FSLBet(fn,'binarize',true,'thresh',opt.f_thresh,'prompt',opt.f_prompt,'propagate',opt.propagate),cPathNoDif,'label',['Extracting brain image' strPlural],'silent',opt.silent);
			case 3
				cPathECCLog		= cellfun(@(x) PathUnsplit(x,'data','ecclog'),cDirSession,'UniformOutput',false);
				
				%move the raw data files
					bSuccess			= cellfun(@(fr,fo) movefile(fr,fo,'f'),cPathDataRaw,cPathDataOrig);
				%eddy correct
					b0					= GetB0(cPathBVals);
					bSuccess(bSuccess)	= ~CallProcess('eddy_correct',{cPathDataOrig(bSuccess) cPathData(bSuccess) b0},cOpt{:},...
											'file_prefix'	, [strPrefix '-eddy_correction']	, ...
											'description'	, 'Performing eddy correction'		  ...
											); 
				%rotate bvecs
					bSuccess(bSuccess)	= ~CallProcess('alex_rotate_bvecs',{cPathECCLog cPathBVecs},cOpt{:},...
											'file_prefix'	, [strPrefix '-rotate_bvecs']	, ...
											'description'	, 'Rotating bvecs'				  ...
											); 
			case 4
				cPathDTIBase	= cellfun(@(x) PathUnsplit(x,'dti'),cDirSession,'UniformOutput',false);
				cPathNoDifMask	= cellfun(@(x) PathUnsplit(x,'nodif_brain_mask','nii.gz'),cDirSession,'UniformOutput',false);
				
				bSuccess	= ~CallProcess('dtifit',{'-k' cPathData '-m' cPathNoDifMask '-r' cPathBVecs '-b' cPathBVals '-o' cPathDTIBase},cOpt{:},...
								'description'	, 'Fitting diffusion tensors'	 ...
								);
			case 5
				bSuccess	= ~CallProcess('bedpostx',{cDirSession '-n' opt.nfibres},cOpt{:},...
								'description'	, 'Running bedpostx'	 ...
								);
			otherwise
				error(['"' tostring(kStage) '" is an invalid stage.']);
		end
	
	if bAppend
		bAppendCur	= true;
	end
end
%------------------------------------------------------------------------------%
function strPathRaw = GetPathRaw(strDirSession)
	strPathRaw		= PathUnsplit(strDirSession,'data','nii');
	strPathRawOrig	= PathAddSuffix(strPathRaw,'-orig');
	strPathRawGZ	= PathUnsplit(strDirSession,'data','nii.gz');
	
	if ~any(FileExists({strPathRaw; strPathRawOrig})) && FileExists(strPathRawGZ)
		strPathRaw	= strPathRawGZ;
	end
end
%------------------------------------------------------------------------------%
function b0 = GetB0(cPathBVals)
	if ~isempty(opt.b0volume)
		b0	= opt.b0volume
	else
		b0	= cellfun(@(f) find(str2array(fget(f))==0,1)-1,cPathBVals,'UniformOutput',false);
	end
end
%------------------------------------------------------------------------------%

end
