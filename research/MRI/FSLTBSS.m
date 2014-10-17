function [strPathFASkeleton,cPathIn] = FSLTBSS(cPathIn,varargin)
% FSLTBSS
% 
% Description:	coregister FA skeletons for a set of FA data sets using the TBSS
%				procedure described here:
%					http://www.fmrib.ox.ac.uk/fsl/tbss/index.html
% 
% Syntax:	[strPathFASkeleton,cPathIn] = FSLTBSS(cPathIn,[strDirOut]=<see below>,<options>)
% 
% In:
% 	cPathIn		- a directory, path to a .nii.gz FA data file, or cell of such
%	[strDirOut]	- the base output directory of the TBSS results.  if
%				  unspecified, then the input paths must be within a directory
%				  called "data", in which case the output files are saved in a
%				  folder called "data/tbss" off of this directory's parent.
%				  e.g. if cPathIn=='.../studies/blah/data' then strDirOut will
%				  be '.../studies/blah/data/tbss'
%	<options>:
%		stage:			(<all>) an array of the stages to process:
%							1:	preprocessing
%							2:	registration
%							3:	post-registration
%							4:	pre-stats
%		out_file_pre:	(<see description>) a cell of the pre-extension file
%						names of FA data sets once they are transferred by this
%						function to the tbss directory.  if unspecified, the
%						function constructs the file names as a "_"-separated
%						string of the directories containing each input data set,
%						traveling up the directory tree until a unique name can
%						be assigned to each data set.
%		target_image:	('FMRIB58_FA') the path to the target of the nonlinear
%						registration procedure.  can also be one of the
%						following:
%							'FMRIB58_FA':	use FSL's standard-space FA image
%							'auto':	automatically choose the "most
%									representative" data set as the target image
%									(see TBSS documentation)
%		skeleton_from:	('data') either 'data' or 'FMRIB58_FA' to specify how
%						tbss_3_postreg will compute the mean FA image for
%						skeletonization
%		threshold:		(<prompt>) the threshold to use for the mean FA skeleton
%						in tbss_4_prestats.  if unspecified and the 'silent'
%						option is false, the function opens fslview and prompts
%						the user to find a suitable threshold.  otherwise 0.2 is
%						used
%		redo:			(false) true to force a redo of all processes
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	strPathFASkeleton	- the path to the 4D skeletonized FA image
%	cPathIn				- a cell of input FA paths, in the order they appear in
%						  the 4D skeletonized FA image
% 
% Updated: 2011-02-16
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
threshDefault	= 0.2;

[strDirOut,opt]	= ParseArgs(varargin,[],...
					'stage'			, 1:4			, ...
					'out_file_pre'	, []			, ...
					'target_image'	, 'FMRIB58_FA'	, ...
					'skeleton_from'	, 'data'		, ...
					'threshold'		, []			, ...
					'redo'			, false			, ...
					'silent'		, false			  ...
					);
opt.stage	= unique([0 reshape(opt.stage,1,[])]);
switch lower(opt.target_image)
	case 'fmrib58_fa'
		strOptTBSS2Reg	= '-T';
	case 'auto'
		strOptTBSS2Reg	= '-n'; 
	otherwise
		strOptTBSS2Reg	= ['-t ' opt.target_image];
		
end
switch lower(opt.skeleton_from)
	case 'data'
		strOptTBSS3PostReg	= '-S';
	case 'fmrib58_fa'
		strOptTBSS3PostReg	= '-T';
	otherwise
		error(['"' tostring(opt.skeleton_from) '" is an unrecognized value for the skeleton_from option.']);
end
if isempty(opt.threshold) && opt.silent
	opt.threshold	= threshDefault;
end

%get the input files
	cPathInRaw	= ForceCell(cPathIn);
	nPathIn		= numel(cPathInRaw);
	
	cPathIn	= {};
	for kP=1:nPathIn
		if isdir(cPathInRaw{kP})
			cPathIn	= [cPathIn; FindFiles(cPathInRaw{kP},'^dti_FA\.nii\.gz$','subdir',true)];
		elseif isequal(lower(PathGetFileName(cPathInRaw{kP})),'dti_FA.nii.gz')
			cPathIn	= [cPathIn; cPathInRaw(kP)];
		else
			error(['"' tostring(cPathInRaw{kP}) '" is unrecognized.']);
		end
	end
	
	nPathIn	= numel(cPathIn);
%get the output directory
	if isempty(strDirOut)
		%find a file path that's in a directory called 'data'
			for kP=1:nPathIn
				cDirSplit	= DirSplit(cPathIn{kP});
				kData		= FindCell(cDirSplit,'data');
				if ~isempty(kData)
					strDirOut	= DirAppend(DirUnsplit(cDirSplit(1:kData(1)-1)),'data','tbss');
					break;
				end
			end
		if isempty(strDirOut)
			error(['Output directory was unspecified and couldn''t be determined from the input files.']);
		end
		
		status(['TBSS will be performed in ' strDirOut],'silent',opt.silent);
	end
	strPathFASkeleton	= PathUnsplit(DirAppend(strDirOut,'stats'),'all_FA_skeletonised','nii.gz');
%determine the stages we need to processes
	%get the current stage
		kStageTBSS		= FSLTBSSGetStage(strDirOut);
	%eliminate redundant stages
		kStageProcess	= conditional(opt.redo,opt.stage,opt.stage(opt.stage>kStageTBSS));
	%add necessary stages
		kStageProcess	= unique([kStageProcess kStageTBSS:(min(kStageProcess)-1)]);
%create the output directory
	if ismember(0,kStageProcess) && ~CreateDirPath(strDirOut)
		error(['Output directory "' tostring(strDirOut) '" could not be created.']);
	end
%get the output FA file paths
	%get the pre-extension file names
		if isempty(opt.out_file_pre)
			status('constructing output FA names','silent',opt.silent);
			
			%find the minimum directory depth that allows construction of unique
			%names
				cDirSplit	= cellfun(@DirSplit,cPathIn,'UniformOutput',false);
				nDir		= min(cellfun(@numel,cDirSplit));
				kDir		= 1;
				while kDir<=nDir
					cFilePre	= cellfun(@(x) join(x(end-kDir+1:end),'_'),cDirSplit,'UniformOutput',false);
					if numel(unique(cFilePre))==nPathIn
						break;
					end
					kDir	= kDir+1;
				end
				if kDir>nDir
					error('Pre-extension FA file names were unspecified and no unique file names could be generated.');
				end
			%construct the pre-extension names
				cFilePre	= cellfun(@(x) [x '_FA'],cFilePre,'UniformOutput',false);
		elseif numel(opt.out_file_pre)~=nPathIn
			error('Number of pre-extension file names specified is different from number of input file paths.');
		else
			cFilePre	= opt.out_file_pre;
		end
	%construct the output FA paths
		cPathFAOut	= cellfun(@(x) PathUnsplit(strDirOut,x,'nii.gz'),cFilePre,'UniformOutput',false);
		cDir		= cellfun(@PathGetDir,cPathFAOut,'UniformOutput',false);
		cFilePre	= cellfun(@PathGetFilePre,cPathFAOut,'UniformOutput',false);
		cFileExt	= cellfun(@PathGetExt,cPathFAOut,'UniformOutput',false);
%copy the FA files to the output directory
	if ismember(0,kStageProcess)
		status('copying FA files','silent',opt.silent);
		
		cellfun(@copyfile,cPathIn,cPathFAOut);
	end
%run tbss_1_preproc
	if ismember(1,kStageProcess)
		RunStep('tbss_1_preproc','*.nii.gz');
	end
%run tbss_2_reg
	if ismember(2,kStageProcess)
		RunStep('tbss_2_reg',strOptTBSS2Reg);
	end
%run tbss_3_postreg
	if ismember(3,kStageProcess)
		RunStep('tbss_3_postreg',strOptTBSS3PostReg);
	end
%verify the FA threshold and run tbss_4_prestats
	if ismember(4,kStageProcess)
		%verify the FA threshold
			if isempty(opt.threshold)
				status('waiting for FA skeletonization threshold','silent',opt.silent);
				
				strScript	= join({
								['cd ' DirAppend(strDirOut,'stats')]
								'fslview all_FA -b 0,0.8 mean_FA_skeleton -b 0.2,0.8 -l Green'
								},10);
				
				if RunBashScript(strScript,'silent',opt.silent);
					error(['fslview failed!']);
				end
				
				opt.threshold	= ask('Use FSLView to choose a skeletonization threshold:','title',mfilename,'default',threshDefault);
			end
		%run tbss_4_prestats
			RunStep('tbss_4_prestats','');
	end
%done!
	status('done!','silent',opt.silent);

%------------------------------------------------------------------------------%
function bProcess = RunStep(strCommand,strOption)
	status(['running ' strCommand],'silent',opt.silent);
	
	strScript	= join({
					['cd ' strDirOut]
					[strCommand ' ' strOption]
					},10);
	
	if RunBashScript(strScript,'silent',opt.silent);
		error([strCommand ' failed!']);
	end
end
%------------------------------------------------------------------------------%

end
