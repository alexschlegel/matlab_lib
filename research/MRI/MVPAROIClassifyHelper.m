function res = MVPAROIClassifyHelper(s,varargin)
% MVPAROIClassifyHelper
% 
% Description:	a helper function for MVPAROI*Classify-style functions
% 
% Syntax:	res = MVPAROIClassifyHelper(s,<options>)
% 
% In:
%	s	- a struct of analysis-specific parameters and functions
% 	<options>:
%		<+ options for MRIParseDataPaths>
%		<+ options for FSLMELODIC/fMRIROI>
%		<+ options for MVPAClassify>
%		type:		('roiclassify') a description of the analysis type
%		melodic:	(true) true to perform MELODIC on the extracted ROIs before
%					classification
%		comptype:	('pca') (see FSLMELODIC)
%		dim:		(s.default.dim) (see FSLMELODIC)
%		targets:	(<required>) a cell specifying the target for each sample,
%					or a cell of cells (one for each dataset)
%		chunks:		(<required>) an array specifying the chunks for each sample,
%					or a cell of arrays (one for each dataset)
%		nthread:	(1) the number of threads to use
%		force:		(true) true to force classification if the outputs already
%					exist
%		force_pre:	(false) true to force preprocessing steps if the output
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results (see MVPAClassify)
%
% Updated: 2015-03-25
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%analysis-specific parameters
	s.default	= ParseArgs({unless(GetFieldPath(s,'default'),struct)},...
					'dim'	, []	  ...
					);
	s.opt		= ParseArgs({unless(GetFieldPath(s,'opt'),struct)},...
					'mvpa'	, struct	  ...
					);
%parse the inputs
	opt		= ParseArgs(varargin,...
				'type'			, 'roiclassify'	, ...
				'melodic'		, true			, ...
				'targets'		, []			, ...
				'chunks'		, []			, ...
				'zscore'		, []			, ...
				'combine'		, true			, ...
				'group_stats'	, []			, ...
				'extra_stats'	, []			, ...
				'nthread'		, 1				, ...
				'force'			, true			, ...
				'force_pre'		, false			, ...
				'silent'		, false			  ...
				);
	
	assert(~isempty(opt.targets),'targets must be specified.');
	assert(~isempty(opt.chunks),'chunks must be specified.');
	
	opt.group_stats	= unless(opt.group_stats,opt.combine);
	opt.extra_stats	= unless(opt.extra_stats,opt.group_stats);
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional','mask'}	  ...
					);
	sPath		= ParseMRIDataPaths(opt_path);

%extract the ROI data
	if opt.melodic
		opt_melodic	= optadd(sPath.opt_extra,...
						'comptype'	, 'pca'			, ...
						'dim'		, s.default.dim	  ...
						);
		opt_melodic	= optreplace(opt_melodic,...
						'path_functional'	, sPath.functional	, ...
						'path_mask'			, sPath.mask		, ...
						'nthread'			, opt.nthread		, ...
						'force'				, opt.force_pre		, ...
						'silent'			, opt.silent		  ...
						);
		
		sMELODIC				= FSLMELODIC(opt_melodic);
		sPath.functional_roi	= sMELODIC.path.data;
	else
		opt_roi					= optreplace(sPath.opt_extra,...
									'path_functional'	, sPath.functional	, ...
									'path_mask'			, sPath.mask		, ...
									'nthread'			, opt.nthread		, ...
									'force'				, opt.force_pre		, ...
									'silent'			, opt.silent		  ...
									);
		sPath.functional_roi	= fMRIROI(opt_roi);
	end

%get the input data and ROI names
	[cPathDataROI,cNameROI,sMaskInfo]	= s.f.ParseROIs(sPath);
	
%classify!
	%get a target/chunk/zscore set for each classification
		cTarget				= ForceCell(opt.targets,'level',2);
		[kChunk,kZScore]	= ForceCell(opt.chunks,opt.zscore);
		
		[cPathDataROI,cTarget,kChunk,kZScore]	= FillSingletonArrays(cPathDataROI,cTarget,kChunk,kZScore);
		
		cTargetRep	= cellfun(@(d,t) repmat({t},[size(d,1) 1]),cPathDataROI,cTarget,'uni',false);
		kChunkRep	= cellfun(@(d,c) repmat({c},[size(d,1) 1]),cPathDataROI,kChunk,'uni',false);
		kZScoreRep	= cellfun(@(d,z) repmat({z},[size(d,1) 1]),cPathDataROI,kZScore,'uni',false);
	
		%flatten for MVPAClassify
			[cPathDataFlat,cTargetFlat,kChunkFlat,kZScoreFlat,cNameROIFlat]	= varfun(@(x) cat(1,x{:}),cPathDataROI,cTargetRep,kChunkRep,kZScoreRep,cNameROI);
	
	cOptMVPA	= opt2cell(s.opt.mvpa);
	opt_mvpa	= optreplace(sPath.opt_extra,cOptMVPA{:},...
					'path_mask'		, []			, ...
					'mask_name'		, []			, ...
					'output_prefix'	, cNameROIFlat	, ...
					'combine'		, false			, ...
					'group_stats'	, false			, ...
					'extra_stats'	, false			, ...
					'zscore'		, kZScoreFlat	, ...
					'nthread'		, opt.nthread	, ...
					'force'			, opt.force		, ...
					'silent'		, opt.silent	  ...
					);
	
	res	= MVPAClassify(cPathDataFlat,cTargetFlat,kChunkFlat,opt_mvpa);

%combine the results
	cMask	= s.f.ParseMaskLabel(sMaskInfo);
	nMask	= numel(cMask);
	
	if opt.combine
		try
			%construct dummy structs for failed classifications
				bFailed	= cellfun(@isempty,res);
				if any(bFailed)
					kGood	= find(~bFailed,1);
					if isempty(kGood)
						error('none of the classifications completed. results cannot be combined.');
					end
					
					resDummy		= dummy(res{kGood});
					res(bFailed)	= {resDummy};
				end
			
			nSubject	= numel(res)/nMask;
			sCombine	= [nMask nSubject];
			
			res			= structtreefun(@CombineResult,res{:});
			res.mask	= cMask;
			res.type	= opt.type;
		catch me
			status('combine option was selected but analysis results are not uniform.','warning',true,'silent',opt.silent);
			return;
		end
		
		if opt.group_stats && nSubject>1
			res	= GroupStats(res);
			
			if opt.extra_stats
				opt_extrastats	= optadd(sPath.opt_extra,...
									'silent'	, opt.silent	  ...
									);
				
				res.stat	= MVPAClassifyExtraStats(res,opt_extrastats);
			end
		end
	end

%------------------------------------------------------------------------------%
function x = CombineResult(varargin)
	if nargin==0
		x	= [];
	else
		if isnumeric(varargin{1}) && uniform(cellfun(@size,varargin,'uni',false))
			if isscalar(varargin{1})
				x	= reshape(cat(1,varargin{:}),sCombine);
			else
				sz	= size(varargin{1});
				x	= reshape(stack(varargin{:}),[sz sCombine]);
			end
		else
			x	= reshape(varargin,sCombine);
		end
	end
end
%------------------------------------------------------------------------------%
function res = GroupStats(res)
	if isstruct(res)
		res	= structfun2(@GroupStats,res);
		
		if isfield(res,'accuracy')
			%accuracies
				acc		= res.accuracy.mean;
				nd		= ndims(acc);
				chance	= res.accuracy.chance(1,end);
				
				res.stats.accuracy.mean	= nanmean(acc,nd);
				res.stats.accuracy.se	= nanstderr(acc,[],nd);
				
				[h,p,ci,stats]	= ttest(acc,chance,'tail','right','dim',nd);
				
				res.stats.accuracy.chance	= chance;
				res.stats.accuracy.df		= stats.df;
				res.stats.accuracy.t		= stats.tstat;
				res.stats.accuracy.p		= p;
			%confusion matrices
				conf	= res.confusion;
				
				if ~iscell(conf)
					res.stats.confusion.mean	= nanmean(conf,4);
					res.stats.confusion.se		= nanstderr(conf,[],4);
				end
		end
	end
end
%------------------------------------------------------------------------------%

end
