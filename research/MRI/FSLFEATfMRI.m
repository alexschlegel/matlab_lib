function b = FSLFEATfMRI(cDirFunctional,cPathStructural,c,strDirOut,varargin)
% FSLFEATfMRI
% 
% Description:	analyze an fMRI study from raw, organized data.  uses feat to
%				preprocess each run of each subject, perform a first level
%				analysis on each run, combine across runs within each subject in
%				a second level fixed effects analysis, and then perform a third
%				level cross subject mixed effects analysis.
% 
% Syntax:	b = FSLFEATfMRI(cDirFunctional,cPathStructural,c,strDirOut,<options>)
% 
% In:
% 	cDirFunctional	- a cell of paths to subjects' functional data directories.
%					  for each subject, all runs must be within a single folder
%					  and stored in nii.gz files named data_<run_number>.nii.gz
%					  (e.g. data_01.nii.gz).
%	cPathStructural	- a cell of paths to subjects' structural data files
%	c				- a cell of the conditions for each subject and run. each
%					  element of c is a cell of arrays specifying the conditions
%					  for each run of the corresponding subject. for example,
%					  c{3}{4} is an array specifying the conditions for run 4 of
%					  subject 3 (whose data directory is cDirFunctional{3}). the
%					  arrays must be formatted as follows:
%						block:	an nBlock-length array specifying the condition
%							number shown during each block (don't include rest
%							blocks)
%						event:	an nEvent x 3 array specifying the condition
%							number, event time (in TRs), and event duration (in
%							TRs) of each event
%	strDirOut		- the directory for the results of the third-level analysis
%	<options>:
%		n_condition:		(<auto>) the number of conditions presented
%		condition_name:		(<auto>) the names of the conditions
%		dur_block			(<required for block design>) the duration, in TRs,
%							of the stimulus blocks (block design only)
%		dur_rest:			(<required for block design>) the duration, in TRs,
%							of the rest blocks (block design only)
%		dur_pre:			(0) the number of blank timepoints to prepend to the
%							EVs (can be negative) (block design only)
%		dur_post:			(0) the number of blank timepoints to append to the
%							EVs (can be negative) (block design only)
%		dur_run:			(<required for event design>) the duration, in TRs,
%							of a run (event design only)
%		bet_thresh:			(0.25) the fractional intensity threshold for bet
%							extraction on the structural images
%		motion_correct:		(true) true to perform motion correction
%		slice_time_correct:	(1) a code to specify which type of slice timing
%							correction to perform:
%								0: None
%								1: Regular up (0, 1, 2, 3, ...)
%								2: Regular down
%								5: Interleaved (0, 2, 4 ... 1, 3, 5 ... )
%		spatial_fwhm:		(6) the spatial smoothing filter FWHM, in mm
%		norm_intensity:		(false) true to perform intensity normalization
%		highpass:			(100) the highpass filter cutoff, in seconds.  set to
%							0 to skip highpass filtering.
%		lowpass:			(false) true to lowpass filter
%		struct_dof:			(9) degrees of freedom for the functional->structural
%							registration
%		standard_dof:		(12) degrees of freedom for the structural->standard
%							registration
%		warp_res:			(10) the nonlinear warp field resolution
%		melodic_ar:			(false) true to use MELODIC to remove artifacts
%		regress_wmv:		(false) true to regress out the white matter and
%							ventricle signals.  if this is true, then a fully-
%							processed freesurfer directory must exist in each
%							structural path directory.
%		firstlevel:			('run') the level at which to perform the first level
%							analysis.  either 'run' to do it on each run or
%							'subject' to concatenate preprocessed runs and do it
%							on the concatenated data.
%		tfilter:			(true) true to temporally filter the EVs, or an
%							nCondition-length logical array specifying which EVs
%							to filter
%		tderivative:		(true) true to add the temporal derivative of the EVs
%							as additional EVs, or an nEV-length logical array
%							specifying the EVs for which to add temporal
%							derivatives
%		tcontrast:			(eye(<n_condition>)) an nTContrast x nCondition array
%							of t-contrast definitions.  FEAT seems to crash if no
%							t-contrasts are defined.
%		tcontrast_name:		(<auto>) an nTContrast-length cell of names for each
%							t-contrast
%		ftest:				(<ones>) an nFTest x nTContrast array of f-test
%							definitions
%		delete_volumes:		(0) the number of volumes to delete from the
%							beginning of the data file (the design matrix must
%							not include these volumes)
%		group:				(<ones>) an nData-length array specifying group
%							membership, or a cell of arrays
%		thresh_type:		('cluster') the type of thresholding to perform.  one
%							of: 'none', 'uncorrected', 'voxel', or 'cluster'.
%		p_thresh:			(0.05) the probability threshold for rendered stat
%							maps
%		z_thresh:			(2.3) the z threshold for clustering
%		bb_thresh:			(10) the brain/background threshold percentage
%		noise_level:		(0.66) the noise level parameter in the feat design
%		noise_ar:			(0.34) the noise AR parameter in the feat design
%		cores:				(1) the number of processor cores to use
%		coresmaxfirst:		(5) the maximum number of cores to use for the first
%							level analysis if <firstlevel> is 'subject' (this is
%							because concatenated functional data take up a lot
%							of memory)
%		force_preprocess:	(false) true to force preprocessing if preprocessed
%							data files already exist
%		force_first:		(false) true to force first-level analyses if the
%							cope files already exist
%		force_second:		(false) true to force second-level analyses if the
%							cope files already exist (second only exists for
%							'run'-type first level analyses)
%		force:				(true) true to force the third-level analysis
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	b	- true if the analysis completed successfully
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= false;

opt	= ParseArgs(varargin,...
		'n_condition'			, []		, ...
		'condition_name'		, []		, ...
		'dur_block'				, []		, ...
		'dur_rest'				, []		, ...
		'dur_pre'				, 0			, ...
		'dur_post'				, 0			, ...
		'dur_run'				, []		, ...
		'bet_thresh'			, 0.25		, ...
		'motion_correct'		, true		, ...
		'slice_time_correct'	, 1			, ...
		'spatial_fwhm'			, 6			, ...
		'norm_intensity'		, false		, ...
		'highpass'				, 100		, ...
		'lowpass'				, false		, ...
		'struct_dof'			, 9			, ...
		'standard_dof'			, 12		, ...
		'warp_res'				, 10		, ...
		'melodic_ar'			, false		, ...
		'regress_wmv'			, false		, ...
		'firstlevel'			, 'run'		, ...
		'tfilter'				, true		, ...
		'tderivative'			, true		, ...
		'tcontrast'				, []		, ...
		'tcontrast_name'		, []		, ...
		'ftest'					, []		, ...
		'delete_volumes'		, 0			, ...
		'group'					, []		, ...
		'thresh_type'			, 'cluster'	, ...
		'p_thresh'				, 0.05		, ...
		'z_thresh'				, 2.3		, ...
		'bb_thresh'				, 10		, ...
		'noise_level'			, 0.66		, ...
		'noise_ar'				, 0.34		, ...
		'cores'					, 1			, ...
		'coresmaxfirst'			, 5			, ...
		'force_preprocess'		, false		, ...
		'force_first'			, false		, ...
		'force_second'			, false		, ...
		'force'					, true		, ...
		'silent'				, false		  ...
		);

opt.firstlevel	= CheckInput(opt.firstlevel,'firstlevel',{'run','subject'});

nSubject	= numel(cDirFunctional);

if nSubject>0
	switch size(c{1}{1},2)
		case 1
			strDesign	= 'block';
		case 3
			strDesign	= 'event';
		otherwise
			error('malformed condition-specifier.');
	end
end

%get the data paths
	cPathFunctional	= cellfun(@(d) FindFiles(d,'^data_\d+\.nii\.gz$'),cDirFunctional,'UniformOutput',false);
%sort by run number
	cKRun			= cellfun(@(c) cellfun(@(f) str2num(getfield(regexp(PathGetFilePre(f),'data_(?<run>\d+)','names'),'run')),c),cPathFunctional,'UniformOutput',false);
	[cKRun,cKSort]	= cellfun(@sort,cKRun,'UniformOutput',false);
	cPathFunctional	= cellfun(@(c,k) c(k),cPathFunctional,cKSort,'UniformOutput',false);
	nRun			= cellfun(@numel,cPathFunctional);

%make sure we got the right number of condition cells
	bMatch	= cellfun(@(d,con) numel(d)==numel(con),cPathFunctional,c);
	
	if ~all(bMatch)
		error(['Mismatch between runs and condition-specifiers for the following subjects: ' join(cDirFunctional(~bMatch),10)]);
	end

%get the condition names
	if isempty(opt.n_condition)
		switch strDesign
			case 'block'
				cu	= cellfun(@(cc) cellfun(@unique,cc,'UniformOutput',false),c,'UniformOutput',false);
			case 'event'
				cu	= cellfun(@(cc) cellfun(@(x) unique(x(:,1)),cc,'UniformOutput',false),c,'UniformOutput',false);
		end
		
		cu	= cellfun(@(cc) unique(append(cc{:})),cu,'UniformOutput',false);
		cu	= unique(append(cu{:}));
		
		opt.n_condition	= numel(cu);
	end
	
	if isempty(opt.condition_name)
		opt.condition_name	= arrayfun(@(k) ['condition_' num2str(k)],(1:opt.n_condition)','UniformOutput',false);
	end
%get the first-level design matrices
	switch strDesign
		case 'block'
			ev	= cellfun(@(cc) cellfun(@(c) block2ev(c,opt.dur_block,opt.dur_rest,opt.dur_pre,opt.dur_post,opt.n_condition),cc,'UniformOutput',false),c,'UniformOutput',false);
		case 'event'
			ev	= cellfun(@(cc) cellfun(@(c) event2ev(c,opt.dur_run),cc,'UniformOutput',false),c,'UniformOutput',false);
	end
	
	evAll	= cat(1,ev{:});
%get the t-contrasts
	if isempty(opt.tcontrast)
		opt.tcontrast	= eye(opt.n_condition);
	end
	nTContrast	= size(opt.tcontrast,1);
	
	if isempty(opt.tcontrast_name)
		opt.tcontrast_name	= arrayfun(@(t) ['tcontrast_' num2str(t)],(1:nTContrast)','UniformOutput',false);
	end
%get the f-tests
	if isempty(opt.ftest)
		opt.ftest	= ones(1,nTContrast);
	end
%get the groups
	if isempty(opt.group)
		opt.group	= ones(nSubject,1);
	end

%extract the structural brain images
	[b,cPathStructuralBrain]	= cellfun(@(f) FSLBet(f,'thresh',opt.bet_thresh,'force',opt.force_preprocess,'silent',opt.silent),cPathStructural,'UniformOutput',false);
	b							= cell2mat(b);
	
	if ~all(b)
		b	= false;
		
		status('failed to extract brain images from the structural data','warning',true,'silent',opt.silent);
		
		return;
	end
%preprocess the data
	cPathStructuralBrainG	= cellfun(@(c,f) repmat({f},size(c)),cPathFunctional,cPathStructuralBrain,'UniformOutput',false);
	cPathFunctionalAll		= cat(1,cPathFunctional{:});
	cPathStructuralBrainAll	= cat(1,cPathStructuralBrainG{:});
	
	[b,cPathDataAll,tr,cDirFEATAll]	= FSLFEATPreprocess(cPathFunctionalAll,cPathStructuralBrainAll,...
										'motion_correct'		, opt.motion_correct		, ...
										'slice_time_correct'	, opt.slice_time_correct	, ...
										'spatial_fwhm'			, opt.spatial_fwhm			, ...
										'norm_intensity'		, opt.norm_intensity		, ...
										'highpass'				, opt.highpass				, ...
										'lowpass'				, opt.lowpass				, ...
										'struct_dof'			, opt.struct_dof			, ...
										'standard_dof'			, opt.standard_dof			, ...
										'warp_res'				, opt.warp_res				, ...
										'bb_thresh'				, opt.bb_thresh				, ...
										'noise_level'			, opt.noise_level			, ...
										'noise_ar'				, opt.noise_ar				, ...
										'force'					, opt.force_preprocess		, ...
										'cores'					, opt.cores					, ...
										'silent'				, opt.silent				  ...
										);
	
	cDirFEAT	= mat2cell(cDirFEATAll,nRun,1);
	
	if ~all(b)
		status(['failed to preprocess the following data: ' join(cPathFunctionalAll(~b),10)],'warning',true,'silent',opt.silent);
		
		b	= false;
		
		return;
	end
%MELODIC artifact removal
	if opt.melodic_ar
		[cPathDataAll,kRemove] = FSLMELODICArtifactRemoval(cPathDataAll,tr,...
									'cores'		, opt.cores				, ...
									'force_pre'	, opt.force_preprocess	, ...
									'force'		, opt.force_preprocess	  ...
									);
	end
%regress out white matter and ventricle timecourses
	if opt.regress_wmv
		cDirFreeSurfer	= cellfun(@(d) DirAppend(PathGetDir(d),'freesurfer'),cPathStructuralBrainAll,'UniformOutput',false);
		
		[b,cPathDataAll]	= fMRIRegressWMV(cPathDataAll,cDirFEATAll,cDirFreeSurfer,...
								'cores'		, opt.cores				, ...
								'force'		, opt.force_preprocess	, ...
								'silent'	, opt.silent			  ...
								);
	end
%first level analysis
	%should we concatenate?
		if isequal(opt.firstlevel,'subject')
			cPathData		= mat2cell(cPathDataAll,nRun,1);
			
			[b,cPathDataAll,cDirFEATAll]	= FSLConcatenate(cPathData,...
												'demean'	, 'align'				, ...
												'force'		, opt.force_preprocess	, ...
												'cores'		, opt.cores				, ...
												'silent'	, opt.silent			  ...
												);
			
			evAll		= cellfun(@(x) cat(1,x{:}),ev,'UniformOutput',false);
			
			nCoreFirst	= min(opt.coresmaxfirst,opt.cores);
		else
			nCoreFirst	= opt.cores;
		end
	
	[b,cDirFEATAll]	= FSLFEATFirst(cPathDataAll,evAll,...
						'ev_name'			, opt.condition_name	, ...
						'convolve'			, true					, ...
						'tfilter'			, opt.tfilter			, ...
						'tderivative'		, opt.tderivative		, ...
						'tcontrast'			, opt.tcontrast			, ...
						'tcontrast_name'	, opt.tcontrast_name	, ...
						'ftest'				, opt.ftest				, ...
						'delete_volumes'	, opt.delete_volumes	, ...
						'highpass'			, opt.highpass			, ...
						'lowpass'			, opt.lowpass			, ...
						'bb_thresh'			, opt.bb_thresh			, ...
						'noise_level'		, opt.noise_level		, ...
						'noise_ar'			, opt.noise_ar			, ...
						'cores'				, nCoreFirst			, ...
						'force'				, opt.force_first		, ...
						'silent'			, opt.silent			  ...
						);
	
	if ~all(b)
		status(['failed to complete first-level analysis for the following data: ' join(cPathDataAll(~b),10)],'warning',true,'silent',opt.silent);
		
		b	= false;
		
		return;
	end
%second level analysis
	if isequal(opt.firstlevel,'run')
		cDirSecond	= cellfun(@(d) DirAppend(d,'feat_subject'),cDirFunctional,'UniformOutput',false);
		
		d2	= cellfun(@(c) ones(numel(c),1),cDirFEAT,'UniformOutput',false);
		
		b	= FSLFEATHigher(cDirFEAT,d2,...
				'output'		, cDirSecond		, ...
				'model'			, 3					, ...
				'thresh_type'	, opt.thresh_type	, ...
				'p_thresh'		, opt.p_thresh		, ...
				'z_thresh'		, opt.z_thresh		, ...
				'cores'			, opt.cores			, ...
				'force'			, opt.force_second	, ...
				'silent'		, opt.silent		  ...
				);
		
		if ~all(b)
			status(['failed to complete second-level analysis for the following subjects: ' join(cDirFunctional(~b),10)],'warning',true,'silent',opt.silent);
			
			b	= false;
			
			return;
		end
	else
		cDirSecond	= cDirFEATAll;
	end
%third level analysis!!
	%design matrix
		d3	= ones(nSubject,1);
	%get the directories to analyze
		if isequal(opt.firstlevel,'run')
			cDirCOPE	= cellfun(@(d) FindDirectories(d,'cope\d+\.feat'),cDirSecond,'UniformOutput',false);
			
			if ~uniform(cellfun(@numel,cDirCOPE))
				error('Not all subjects have the same number of COPEs.');
			end
			
			nCOPE	= numel(cDirCOPE{1});
			
			%sort by COPE number
				kCope			= cellfun(@(d) str2num(getfield(regexp(RemoveSlash(DirSub(d,0,0)),'cope(?<cope>\d+)\.feat$','names'),'cope')),cDirCOPE{1});
				[kCope,kSort]	= sort(kCope);
				
				cDirCOPE	= cellfun(@(c) c(kSort),cDirCOPE,'UniformOutput',false);
			%output directories
				cDirOut	= cellfun(@(d) DirAppend(strDirOut,DirSub(d,0,0)),cDirCOPE{1},'UniformOutput',false);
			%rearrange
				cDirCOPE	= arrayfun(@(k) cellfun(@(c) c{k},cDirCOPE,'UniformOutput',false),(1:nCOPE)','UniformOutput',false);
			
			cDirIn			= cDirCOPE;
			cTContrastName	= conditional(nCOPE==nTContrast,cellfun(@(str) {str},opt.tcontrast_name,'UniformOutput',false),[]);
		else
			cDirIn			= cDirSecond;
			cDirOut			= strDirOut;
			cTContrastName	= [];
		end
	
	b	= FSLFEATHigher(cDirIn,d3,...
			'output'			, cDirOut			, ...
			'tcontrast_name'	, cTContrastName	, ...
			'thresh_type'		, opt.thresh_type	, ...
			'p_thresh'			, opt.p_thresh		, ...
			'z_thresh'			, opt.z_thresh		, ...
			'reg_standard'		, false				, ...
			'cores'				, opt.cores			, ...
			'force'				, opt.force			, ...
			'silent'			, opt.silent		  ...
			);
	
	if ~b
		status('failed to complete third-level analysis.','warning',true,'silent',opt.silent);
	end
%fourth level analysis!!!!!!
	%there is no fourth level analysis
