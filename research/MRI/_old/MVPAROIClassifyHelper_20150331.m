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
% Updated: 2015-03-27
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%analysis-specific parameters
	s.default	= ParseArgs(opt2cell(GetFieldPath(s,'default')),...
					'dim'	, []	  ...
					);
	s.opt		= ParseArgs(opt2cell(GetFieldPath(s,'opt')),...
					'mvpa'	, struct	  ...
					);
%parse the inputs
	opt		= ParseArgs(varargin,...
				'melodic'		, true			, ...
				'targets'		, []			, ...
				'chunks'		, []			, ...
				'zscore'		, 'chunks'		, ...
				'nthread'		, 1				, ...
				'force'			, true			, ...
				'force_pre'		, false			, ...
				'silent'		, false			  ...
				);
	
	assert(~isempty(opt.targets),'targets must be specified.');
	assert(~isempty(opt.chunks),'chunks must be specified.');
	
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
						'dir_out'			, []				, ...
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

%make sure we have the same number of masks for each dataset
	if ~uniform(cellfun(@numel,cPathDataROI))
		error('specify the same number of masks per dataset.');
	end
	nMask	= numel(cPathDataROI{1});

%get a target/chunk/zscore set for each classification
	cTarget				= ForceCell(opt.targets,'level',2);
	[kChunk,kZScore]	= ForceCell(opt.chunks,opt.zscore);
	
	[cPathDataROI,cNameROI,cTarget,kChunk,kZScore]	= FillSingletonArrays(cPathDataROI,cNameROI,cTarget,kChunk,kZScore);
	
	%make sure each parameter is nMask x 1 on the inside
		[cTarget,kChunk,kZScore]	= varfun(@(c) cellfun(@(x) repmat({x},[nMask 1]),c,'uni',false),cTarget,kChunk,kZScore);
	
	%reshape to nMask x nSubject
		[cPathDataROI,cNameROI,cTarget,kChunk,kZScore]	= varfun(@(c) cat(2,c{:}),cPathDataROI,cNameROI,cTarget,kChunk,kZScore);

%classify!
	cOptMVPA	= opt2cell(s.opt.mvpa);
	opt_mvpa	= optadd(sPath.opt_extra,...
					'type'	, 'roiclassify'	  ...
					);
	opt_mvpa	= optreplace(opt_mvpa,cOptMVPA{:},...
					'name'		, cNameROI		, ...
					'path_mask'	, []			, ...
					'mask_name'	, []			, ...
					'zscore'	, kZScore		, ...
					'nthread'	, opt.nthread	, ...
					'force'		, opt.force		, ...
					'silent'	, opt.silent	  ...
					);
	
	res			= MVPAClassify(cPathDataROI,cTarget,kChunk,opt_mvpa);
	res.mask	= s.f.ParseMaskLabel(sMaskInfo);
	return;

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
