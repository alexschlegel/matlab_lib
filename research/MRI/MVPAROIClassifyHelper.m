function res = MVPAROIClassifyHelper(param,varargin)
% MVPAROIClassifyHelper
% 
% Description:	a helper function for MVPAROI*Classify-style functions
% 
% Syntax:	res = MVPAROIClassifyHelper(param,<options>)
% 
% In:
%	param	- a struct of analysis-specific parameters and functions
% 	<options>:
%		<+ options for MRIParseDataPaths>
%		<+ options for FSLMELODIC/fMRIROI>
%		<+ options for MVPAClassify>
%		melodic:	(true) true to perform MELODIC on the extracted ROIs before
%					classification
%		comptype:	('pca') (see FSLMELODIC)
%		dim:		(param.default.dim) (see FSLMELODIC)
%		targets:	(<required>) a cell specifying the target for each sample,
%					or a cell of cells (one for each dataset)
%		chunks:		(<required>) an array specifying the chunks for each sample,
%					or a cell of arrays (one for each dataset)
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force classification if the outputs already
%					exist
%		force_pre:	(false) true to force preprocessing steps if the output
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results (see MVPAClassify)
%
% Updated: 2016-01-14
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt		= ParseArgs(varargin,...
				'melodic'		, true			, ...
				'targets'		, []			, ...
				'chunks'		, []			, ...
				'zscore'		, 'chunks'		, ...
				'cores'			, 1				, ...
				'force'			, true			, ...
				'force_pre'		, false			, ...
				'silent'		, false			  ...
				);
	
	assert(~isempty(opt.targets),'targets must be specified.');
	assert(~isempty(opt.chunks),'chunks must be specified.');
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional','mask'}	  ...
					);
	cOptPath	= opt2cell(opt_path);
	sPath		= ParseMRIDataPaths(cOptPath{:});

%analysis-specific parameters
	param	= optadd(param,...
				'default'		, struct				, ...
				'opt'			, struct				, ...
				'parseInput'	, @ParseInputDefault	  ...
				);
	
	param.default	= optadd(param.default,...
						'dim'	, []	  ...
						);
	
	param.opt	= optadd(param.opt,...
					'mvpa'	, optstruct(struct,struct)	  ...
					);

%extract the ROI data
	if opt.melodic
		opt_melodic	= optadd(sPath.opt_extra,...
						'comptype'	, 'pca'				, ...
						'dim'		, param.default.dim	  ...
						);
		opt_melodic	= optreplace(opt_melodic,...
						'dir_out'			, []				, ...
						'path_functional'	, sPath.functional	, ...
						'path_mask'			, sPath.mask		, ...
						'cores'				, opt.cores			, ...
						'force'				, opt.force_pre		, ...
						'silent'			, opt.silent		  ...
						);
		
		cOptMELODIC				= opt2cell(opt_melodic);
		sMELODIC				= FSLMELODIC(cOptMELODIC{:});
		sPath.functional_roi	= sMELODIC.path.data;
	else
		opt_roi					= optreplace(sPath.opt_extra,...
									'path_functional'	, sPath.functional	, ...
									'path_mask'			, sPath.mask		, ...
									'cores'				, opt.cores			, ...
									'force'				, opt.force_pre		, ...
									'silent'			, opt.silent		  ...
									);
		
		cOptROI					= opt2cell(opt_roi);
		sPath.functional_roi	= fMRIROI(cOptROI{:});
	end

%parse the input data
	sData	= param.parseInput(sPath);

%make sure we have the same number of masks for each dataset
	if ~uniform(cellfun(@numel,sData.cPathDataROI))
		error('specify the same number of masks per dataset.');
	end
	nMask	= numel(sData.cPathDataROI{1});

%get a target/chunk/zscore set for each classification
	cTarget				= ForceCell(opt.targets,'level',2);
	[kChunk,kZScore]	= ForceCell(opt.chunks,opt.zscore);
	
	[sData.cPathDataROI,sData.cNameROI,cTarget,kChunk,kZScore]	= FillSingletonArrays(sData.cPathDataROI,sData.cNameROI,cTarget,kChunk,kZScore);
	
	%make sure each parameter is nMask x 1 on the inside
		[cTarget,kChunk,kZScore]	= varfun(@(c) cellfun(@(x) repmat({x},[nMask 1]),c,'uni',false),cTarget,kChunk,kZScore);
	
	%reshape to nMask x nSubject
		[sData.cPathDataROI,sData.cNameROI,cTarget,kChunk,kZScore]	= varfun(@(c) cat(2,c{:}),sData.cPathDataROI,sData.cNameROI,cTarget,kChunk,kZScore);

%classify!
	cOptMVPA	= opt2cell(param.opt.mvpa);
	opt_mvpa	= optadd(sPath.opt_extra,...
					'type'	, 'roiclassify'	  ...
					);
	opt_mvpa	= optreplace(opt_mvpa,cOptMVPA{:},...
					'name'		, sData.cNameROI	, ...
					'path_mask'	, []				, ...
					'mask_name'	, []				, ...
					'zscore'	, kZScore			, ...
					'cores'		, opt.cores			, ...
					'force'		, opt.force			, ...
					'silent'	, opt.silent		  ...
					);
	
	cOptMVPA	= opt2cell(opt_mvpa);
	res			= MVPAClassify(sData.cPathDataROI,cTarget,kChunk,cOptMVPA{:});
	res.mask	= sData.cMask;

%------------------------------------------------------------------------------%
function sData = ParseInputDefault(sPath) 
	sData.cPathDataROI	= sPath.functional_roi;
	sData.cNameROI		= cellfun(@GetROINames,sPath.functional_session,sPath.mask_name,'uni',false);
	sData.cMask			= reshape(sPath.mask_name{1},[],1);
%------------------------------------------------------------------------------%
function cNameROI = GetROINames(strSession,cNameMask)
	cNameROI	= cellfun(@(m) GetROIName(strSession,m),cNameMask,'uni',false);
%------------------------------------------------------------------------------%
function strNameROI = GetROIName(strSession,strNameMask) 
	strNameROI	= sprintf('%s-%s',strSession,strNameMask);
%------------------------------------------------------------------------------%
