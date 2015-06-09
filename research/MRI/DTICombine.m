function bSuccess = DTICombine(cPathData,varargin)
% DTICombine
% 
% Description:	combine multiple DTI runs from the same subject, assuming all
%				runs have the same scan sequence.  performs the following steps:
%					1:	concatenates the input data
%					2:	concatenates the bvecs and bvals files
%					3:	eddy corrects the concatenated data
%					4:	rotates the bvecs to reflect the eddy correction
%					5:	averages volumes with corresponding diffusion directions.
%						this should only be selected (with the <average> option)
%						if each original DTI data set was in close alignment
%						before eddy correction.  (note: run stage 5 even if
%						averaging is not specified, so files will be renamed
%						correctly.)
%					6:	save the b0 image
%					7:	extract the b0 brain
%					8:	run dtifit
%					9:	run bedpostx
% 
% Syntax:	bSuccess = DTICombine(cPathData,<options>)
% 
% In:
% 	cPathData	- one of the following:
%					1) the path to a directory containing individual DTI data
%					   directories.  the directory tree will be searched for
%					   uncorrected data
%					2) a cell of paths to individual DTI data directories.
%					   directory trees will be searched and the uncorrected data
%					   will be combined separately for each tree.
%					3) a cell of paths to uncorrected DTI data (i.e. data.nii /
%					   data-orig.nii) to combine
%					4) a cell of cells of paths to uncorrected DTI data. each
%					   cell of paths will be combined separately.
%	<options>:
%		stage:			(<all>) the stages to process
%		stage_check:	(true) true to make sure the data is ready to be
%						processed at the specified stage(s)
%		dir_out:		(<common_base_dir>/combined) the output directory, or a
%						cell of directories if multiple combinations are being
%						performed
%		average:		(false) true to average corresponding eddy_corrected
%						diffusion images and bvecs values (i think this could be
%						bad if the runs are badly out of alignment)
%		b0volume:		(0) the index of the b=0 volume in data.nii.gz
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
%		force:			(false) true to force combining of data even if the
%						output already exists
%		cores:			(1) number of processor cores to use (only applies when
%						multiple combinations are being performed). note that if
%						the process is being batched, then input of the bet
%						threshold will not be prompted.
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which input data sets were
%				  successfully combined
% 
% Examples:
%	In these examples, subject directories (e.g. .../as/) contain directories
%	that contain uncorrected data.nii files:
%	1) combine all of the data from subject 'as':
%		strPath  = '~/studies/example/data/as';
%		bSuccess = DTICombine(strPath);
%	2) search for the files manually, then combine them:
%		strPath   = '~/studies/example/data/as';
%		cPathData = FindFiles(strPath,'data\.nii\.gz','subdir',true);
%		bSuccess = DTICombine(cPathData);
%   3) combine data for each subject in the data directory, using 5 cores:
%		strDirData  = '~/studies/example/data/';
%		cDirSubject = FindDirectories(strDirData);
%		bSuccess = DTICombine(cDirSubject,'cores',5);
%	4) search each subject's data directory manually and then combine each set
%	   of data individually.  use 5 cores and don't prompt for a bet
%	   threshold:
%		strDirData  = '~/studies/example/data/';
%		cDirSubject = FindDirectories(strDirData);
%		cPathData = cellfun(@(d) FindFiles(d,'data\.nii\.gz','subdir',true),'UniformOutput',false);
%		bSuccess = DTICombine(cPathData,'cores',5,'f_thresh',0.2);
% 
% Updated: 2015-06-09
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'stage'			, 1:9	, ...
		'stage_check'	, true	, ...
		'dir_out'		, []	, ...
		'average'		, false	, ...
		'b0volume'		, 0		, ...
		'f_thresh'		, []	, ...
		'f_prompt'		, []	, ...
		'propagate'		, true	, ...
		'nfibres'		, 2		, ...
		'log'			, true	, ...
		'force'			, false	, ...
		'cores'			, 1		, ...
		'silent'		, false	  ...
		);

[cPathData]	= ForceCell(cPathData,'level',2);
opt.dir_out	= ForceCell(opt.dir_out);

if numel(cPathData)==1 && all(cellfun(@isdir,cPathData{1})) && all(cellfun(@(d) isempty(FindFiles(d,'data(-orig)?\.nii(\.gz)$')),cPathData{1}))
%a cell of directory roots was passed
	%find potential directories
		cDirMaybe	= cellfun(@(d) FindDirectories(d,'(\.bedpostX)|(\.probtrackX)|(combined)','negate',true),cPathData{1},'UniformOutput',false);
	%find data files
		cPathData	= cellfun(@(d) FindFiles(d,'data(-orig)?\.nii$'),cDirMaybe,'UniformOutput',false); 
end

%get the data files
	cPathData	= cellfun(@(cpd) cellfun(@(f) conditional(isdir(f),PathUnsplit(f,'data','nii'),f),cpd,'UniformOutput',false),cPathData,'UniformOutput',false);
	
	%check for data folders whose original data has been moved by eddy correction
		cPathDataOrig	= cellfun(@(cpd) cellfun(@(f) PathAddSuffix(f,'-orig','nii','favor','nii.gz'),cpd,'UniformOutput',false),cPathData,'UniformOutput',false);
		cPathData		= cellfun(@(cpd,cpdo) cellfun(@(f,fo) conditional(FileExists(fo),fo,f),cpd,cpdo,'UniformOutput',false),cPathData,cPathDataOrig,'UniformOutput',false);
%get the output directories
	[cPathData,opt.dir_out]	= FillSingletonArrays(cPathData,opt.dir_out);
	opt.dir_out				= cellfun(@(do,cpd) conditional(~isempty(do),do,DirAppend(PathGetBase(cpd),'combined')),opt.dir_out,cPathData,'UniformOutput',false);
%get the log paths
	[bAppend,bAppendCur]	= deal(false);
	if isequal(opt.log,true)
		[cPathScript,cPathLog]	= deal(opt.dir_out);
	elseif isequal(opt.log,false)
		[cPathScript,cPathLog]	= deal([]);
	else
		cPathLog	= ForceCell(opt.log);
		cPathScript	= cellfun(@(fl) PathAddSuffix(fl,'','sh'),cPathLog,'UniformOutput',false);
		bAppend		= true;
	end
%get rid of any data files from combinations already in progress
	sSet	= size(cPathData);
	nSet	= numel(cPathData);
	
	for kS=1:nSet
		cDir						= cellfun(@PathGetDir,cPathData{kS},'UniformOutput',false);
		bCombined					= cellfun(@(d) isequal(d,opt.dir_out{kS}),cDir);
		cPathData{kS}(bCombined)	= [];
	end

%check for required files
	cDirData	= cellfun(@(cpd) cellfun(@PathGetDir,cpd,'UniformOutput',false),cPathData,'UniformOutput',false);
	cPathBVecs	= cellfun(@(cdd) cellfun(@(d) PathUnsplit(d,'bvecs'),cdd,'UniformOutput',false),cDirData,'UniformOutput',false);
	cPathBVals	= cellfun(@(cdd) cellfun(@(d) PathUnsplit(d,'bvals'),cdd,'UniformOutput',false),cDirData,'UniformOutput',false);
	
	%check for orig bvecs files
		cPathBVecsOrig	= cellfun(@(cbv) cellfun(@(f) PathAddSuffix(f,'-orig'),cbv,'UniformOutput',false),cPathBVecs,'UniformOutput',false);
		cPathBVecs		= cellfun(@(cbv,cbvo) cellfun(@(f,fo) conditional(FileExists(fo),fo,f),cbv,cbvo,'UniformOutput',false),cPathBVecs,cPathBVecsOrig,'UniformOutput',false);
	
	varfun(@(cf) assertFileExists(append(cf{:})),cPathData,cPathBVecs,cPathBVals);
%process each stage
	bSuccess	= true(sSet);
	nStage		= numel(opt.stage);
	
	progress('action','init','total',nStage,'label','Combining DTI Data','status',true,'silent',opt.silent);
	for kS=1:nStage
		kSuccess		= find(bSuccess);
		
		kStageCur		= opt.stage(kS);
		strStage		= num2str(kStageCur);
		
		%get the stage of each set
			kStageNext	= DTICombineGetStage(opt.dir_out(kSuccess),'nfibres',opt.nfibres,'offset',1,'silent',opt.silent);
		%check for invalid stage selections
			bReady				= ~opt.stage_check | (kStageNext>=kStageCur);
			bSuccess(bSuccess)	= bReady;
			if ~all(bReady)
				status(['The following data sets are not yet ready for DTICombine stage ' strStage ':' join(opt.dir_out(~bReady),10)],'warning',true,'silent',opt.silent);
			end
		%get the files to process at the current stage
			bProcess	= bReady & (opt.force | kStageNext==kStageCur);
			
			kCombinedCur	= kSuccess(bProcess);
			cPathDataCur	= cPathData(kCombinedCur);
			cPathBVecsCur	= cPathBVecs(kCombinedCur);
			cPathBValsCur	= cPathBVals(kCombinedCur);
			cDirCombinedCur	= opt.dir_out(kCombinedCur);
		%process them!
			if any(bProcess)
				bSuccessCur				= DTICombineStage(cDirCombinedCur,cPathDataCur,cPathBVecsCur,cPathBValsCur,kStageCur);
				bSuccess(kCombinedCur)	= bSuccessCur;
				
				%check for errors
					if ~all(bSuccessCur)
						status(['DTICombine stage ' strStage ' for the following data sets failed:' join(cDirCombinedCur(~bSuccessCur),10)],'warning',true,'silent',opt.silent);
					end
			end
		
		progress;
	end

%------------------------------------------------------------------------------%
function bSuccess = DTICombineStage(cDirCombined,cPathData,cPathBVecs,cPathBVals,kStage)
	nCombined	= numel(cDirCombined);
	
	strStage	= num2str(kStage);
	strPlural	= plural(nCombined,'','s');
	
	%relevant files
		cPathDataRel			= cellfun(@(cf,d) cellfun(@(f) PathAbs2Rel(f,d),cf,'UniformOutput',false),cPathData,cDirCombined,'UniformOutput',false);
		cPathSourcePaths		= cellfun(@(d) PathUnsplit(d,'sourcepath','txt'),cDirCombined,'UniformOutput',false);
		cPathDataCombined		= cellfun(@(d) PathUnsplit(d,'data','nii.gz'),cDirCombined,'UniformOutput',false);
		cPathBVecsCombined		= cellfun(@(d) PathUnsplit(d,'bvecs'),cDirCombined,'UniformOutput',false);
		cPathBValsCombined		= cellfun(@(d) PathUnsplit(d,'bvals'),cDirCombined,'UniformOutput',false);
		cPathDataCombinedCorr	= cellfun(@(f) PathAddSuffix(f,'-corrected','favor','nii.gz'),cPathDataCombined,'UniformOutput',false);
		cPathECCLog				= cellfun(@(d) PathUnsplit(d,'data-corrected','ecclog'),cDirCombined,'UniformOutput',false);
		cPathNoDif				= cellfun(@(d) PathUnsplit(d,'nodif','nii.gz'),cDirCombined,'UniformOutput',false);
		cPathNoDifBrain			= cellfun(@(f) PathAddSuffix(f,'_brain_mask','favor','nii.gz'),cPathNoDif,'UniformOutput',false);
	%options for CallProcess/RunBashScript calls
		strPrefix	= ['dticombine-' strStage];
		cOpt		=	{
							'file_prefix'	, strPrefix		, ...
							'script_path'	, cPathScript	, ...
							'script_append'	, bAppendCur	, ...
							'log_path'		, cPathLog		, ...
							'log_append'	, bAppendCur	, ...
							'cores'			, opt.cores		, ...
							'silent'		, opt.silent	  ...
						};
	
	switch kStage
		case 1
		%concatenate the data
			%create the output directory
				bSuccess			= cellfun(@CreateDirPath,cDirCombined);
			%save the source paths
				bSuccess(bSuccess)	= cellfun(@(cf,fs) fput(join(cf,10),fs),cPathDataRel,cPathSourcePaths);
			%concatenate
				bSuccess(bSuccess)	= cellfunprogress(@(cpd,fc) FSLMerge(cpd,fc,'silent',opt.silent),cPathData,cPathDataCombined,'label','Merging DTI data','silent',opt.silent);
		case 2
		%concatenate bvecs and bvals
			bSuccess	= true(nCombined,1);
			
			progress('action','init','total',nCombined,'label','Concatenating bvecs files','silent',opt.silent);
			for kC=1:nCombined
				bvecs	= cell2mat(cellfun(@(f) str2array(fget(f)),cPathBVecs{kC},'UniformOutput',false)');
				bvals	= cell2mat(cellfun(@(f) str2array(fget(f)),cPathBVals{kC},'UniformOutput',false)');
				
				bSuccess(kC)	= bSuccess(kC) & fput(array2str(bvecs),cPathBVecsCombined{kC});
				bSuccess(kC)	= bSuccess(kC) & fput(array2str(bvals),cPathBValsCombined{kC});
				
				progress;
			end
		case 3
		%eddy correct the data
			bSuccess	= ~CallProcess('eddy_correct',{cPathDataCombined cPathDataCombinedCorr opt.b0volume},cOpt{:},...
							'description'	, 'Performing eddy correction'		  ...
							); 
		case 4
		%rotate bvecs
			bSuccess	= ~CallProcess('alex_rotate_bvecs',{cPathECCLog cPathBVecsCombined},cOpt{:},...
							'description'	, 'Rotating bvecs'				  ...
							);
		case 5
		%average the data
			bSuccess	= true(nCombined,1);
			
			progress('action','init','total',nCombined,'label','Averaging corrected data','silent',~opt.average | opt.silent);
			for kC=1:nCombined
				if opt.average
				%extract and average each eddy_corrected data set
					nPath	= numel(cPathData{kC});
					bvals	= str2array(fget(cPathBValsCombined{kC}));
					nVol	= numel(bvals)/nPath;
					
					kPath			= reshape(1:nPath,[],1);
					cPathExtract	= arrayfun(@(k) PathAddSuffix(cPathDataCombinedCorr{kC},['-' num2str(k)],'favor','nii.gz'),kPath,'UniformOutput',false);
					kStart			= num2cell(nVol*(kPath-1));
					bSuccess(kC)	= ~any(CallProcess('fslroi',{cPathDataCombinedCorr{kC} cPathExtract kStart nVol},cOpt{:},...
										'file_prefix'	, [strPrefix '-extract']	, ...
										'description'	, 'extracting data'			  ...
										));
					
					if bSuccess(kC)
					%average them
						strAdd			= join(cPathExtract,' -add ');
						strScript		= ['fslmaths ' strAdd ' -div ' num2str(nPath) ' ' cPathDataCombined{kC}];
						bSuccess(kC)	= ~RunBashScript(strScript,cOpt{:},...
											'cores'			, 1							, ...
											'file_prefix'	, [strPrefix '-average']	, ...
											'description'	, 'averaging data'			  ...
											);
						
						if bSuccess(kC)
							%delete the intermediate files
								cellfun(@delete,cPathExtract);
								delete(strPathDataCombinedCorr);
							%extract and average bvecs and shrink bvals
								bvecs	= str2array(fget(cPathBVecsCombined{kC}));
								bvals	= str2array(fget(cPathBValsCombined{kC}));
								nVol	= numel(bvals)/nPath;
								
								bvecs	= mean(reshape(bvecs,3,nVol,[]),3);
								bvals	= bvals(1:nVol);
								
								bSuccess(kC)	= bSuccess(kC) & fput(array2str(bvecs),cPathBVecsCombined{kC});
								bSuccess(kC)	= bSuccess(kC) & fput(array2str(bvals),cPathBValsCombined{kC});
						end
					end
				else
				%rename the corrected data
					bSuccess(kC)	= movefile(cPathDataCombinedCorr{kC},cPathDataCombined{kC},'f');
				end
				
				progress;
			end
		case 6
		%save the b0 image
			bSuccess	= true(nCombined,1);
			
			progress('action','init','total',nCombined,'label',['Extracting b0 image' strPlural],'silent',opt.silent);
			for kC=1:nCombined
				bvals	= str2array(fget(cPathBValsCombined{kC}));
				
				if opt.average
					kB0Average	= {opt.b0volume};
					cPathB0		= {cPathNoDif{kC}};
				else
					nPath		= numel(cPathData{kC});
					nTotal		= numel(bvals);
					nVol		= nTotal/nPath;
					kB0Average	= num2cell(opt.b0volume:nVol:nTotal-1);
					cPathB0		= cellfun(@(k) PathAddSuffix(cPathNoDif{kC},['-' num2str(k)],'favor','nii.gz'),kB0Average,'UniformOutput',false);
				end
				
				nB0Average	= numel(kB0Average);
				
				bSuccess(kC)	= ~any(CallProcess('fslroi',{cPathDataCombined{kC} cPathB0 kB0Average 1},cOpt{:},...
									'file_prefix'	, [strPrefix '-extract']	, ...
									'description'	, 'extracting b0 images'	  ...
									));
				
				if bSuccess(kC) && ~opt.average
					strAdd			= join(cPathB0,' -add ');
					strScript		= ['fslmaths ' strAdd ' -div ' num2str(nB0Average) ' ' cPathNoDif{kC}];
					bSuccess(kC)	= ~RunBashScript(strScript,cOpt{:},...
										'cores'			, 1							, ...
										'file_prefix'	, [strPrefix '-average']	, ...
										'description'	, 'averaging b0 images'		  ...
										);
					
					if bSuccess(kC)
					%delete the intermediate files
						cellfun(@delete,cPathB0);
					end
				end
				
				progress;
			end
		case 7
		%extract the b0 brain
			bSuccess	= cellfunprogress(@(fn) FSLBet(fn,'binarize',true,'thresh',opt.f_thresh,'prompt',opt.f_prompt,'propagate',opt.propagate),cPathNoDif,'label',['Extracting brain image' strPlural],'silent',opt.silent);
		case 8
		%run dtifit
			cPathDTIBase	= cellfun(@(x) PathUnsplit(x,'dti'),cDirCombined,'UniformOutput',false);
			
			bSuccess	= ~CallProcess('dtifit',{'-k' cPathDataCombined '-m' cPathNoDifBrain '-r' cPathBVecsCombined '-b' cPathBValsCombined '-o' cPathDTIBase},cOpt{:},...
							'description'	, 'Fitting diffusion tensors'	 ...
							);
		case 9
		%run bedpostx
			bSuccess	= ~CallProcess('bedpostx',{cDirCombined '-n' opt.nfibres},cOpt{:},...
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

end
