function res = MVPAClassify(cPathData,cTarget,kChunk,varargin)
% MVPAClassify
% 
% Description:	perform MVPA classification using PyMVPA
% 
% Syntax:	res = MVPAClassify(cPathData,cTarget,kChunk,<options>)
% 
% In:
% 	cPathData	- the path to the nX x nY x nZ x nSample NIfTI file to analyze,
%				  or a cell of paths. for classifications that require paired
%				  datasets (matched dataset cross-classification and information
%				  flow classification), then this must be a cell whose last
%				  dimension has size 2. in this case, both datasets must have
%				  the same target/chunk structure.
%	cTarget		- an nSample x 1 cell specifying the target of each sample, or a
%				  cell of sample cell arrays (one for each dataset)
%	kChunk		- an nSample x 1 array specifying the chunk of each sample, or a
%				  cell of chunk arrays (one for each dataset)
%	<options>:
%		path_mask:				(<none>) the path to a mask NIfTI file to apply
%								to the data, or a cell of mask paths (or a cell
%								of cells of mask paths, one cell for each
%								dataset)
%		mask_name:				(<auto>) the name of each mask
%		mask_balancer:			('none') the strategy to use if non-uniformly
%								sized masks are specified. one of the following:
%									'erode': erode each mask to be the same size
%									'bootstrap': bootstrap subsets of masks. a
%										subset of the voxels in each mask will
%										be randomly chosen (based on the
%										smallest mask), and the classification
%										performed on that mask subset.
%									'none': nothing will be done to correct for
%										uneven mask sizes
%		mask_balancer_count:	(25) the number of bootstrap iterations to
%								perform for each mask when balancing (see above)
%		partitioner:			(1) the partitioner to use. one of the
%								following:
%									n:	use NFoldPartitioner, leaving n folds
%										out in each cross validation fold
%									str:	a string to be eval'ed, the result
%											of which is the partitioner
%		classifier:				('LinearCSVMC') a string specifying the
%								classifier to use, or a cell of classifiers to
%								do nested classifier selection. suggestions:
%								LinearCSVMC, SMLR, RbfCSVMC. classifiers can
%								also specify parameters
%								(e.g. 'LinearCSVMC(C=-0.5)').
%		allway:					(true) true to perform an all-way classification
%		twoway:					(false) true to perform every pairwise
%								classification
%		permutations:			(false) the number of permutations to perform
%								during Monte Carlo testing. set to false to skip
%								permutation testing.
%		sensitivities:			(false) true to save the L1-normed
%								classification sensitivities. note that
%								sensivities cannot be saved if more than one
%								classifier is specified.
%		average:				(false) true to average samples from the same
%								target and chunk
%		spatiotemporal:			(false) true to do a spatiotemporal analysis
%		matchedcrossclassify:	(false) true to perform matched dataset
%								cross-classification, but only if the data are
%								formatted as described above. in this case, two
%								datasets share the same targets and chunks and
%								have the same number of features, and the
%								classifier is trained on one dataset and tested
%								on the other. currently both datasets are
%								included in training and testing.
%		match_features:			(false) only applies to matched dataset
%								cross-classifications. true to perform feature
%								matching between the training and testing
%								datasets.
%		match_include_blank:	(true) only applies to matched dataset
%								cross-classifications. true to include blank
%								samples in the feature matching step
%		informationflow:		(false) true to perform an information-flow
%								classification, but only if the data are
%								formatted as described above. in this analysis
%								information flow patterns for each target and
%								chunk are constructed by calculating the Granger
%								Causality from each feature of dataset 1 to each
%								feature of dataset 2. the classification is
%								performed on these patterns.
%		selection:				(1) the number/fraction of features to select
%								for classification, based on a one-way ANOVA. if
%								a number less than one is passed, it is
%								interpreted as a fraction. if an integer greater
%								than one is passed, it is interpreted as an
%								absolute number of features to keep.
%		save_selected:			(false) true to save a map for each
%								classification showing the fraction of folds in
%								which each voxel was selected
%		target_subset:			(<all except blank>) a cell specifying the
%								subset of targets to include in the analysis, or
%								a cell of cells of target subsets (one for each
%								dataset)
%		target_blank:			(<none>) a string specifying the 'blank' target
%								that should be eliminated before classifying
%		zscore:					('chunks') the sample attribute to use as the
%								chunks_attr for z-scoring, or an nSample x 1
%								array to use as a custom attribute (or a cell of
%								arrays, one for each dataset). set to false
%								to skip z-scoring.
%		target_balancer:		(true) the number of permutations to perform for
%								unbalanced targets. set to false to skip target
%								balancing.
%		mean_control:			(false) true to perform a control classification
%								on the mean pattern values
%		sample_attr:			(<none>) a struct of nSample x 1 arrays (or
%								cells of arrays) specifying custom sample
%								attributes
%		nan_remove:				('none') specify how to remove NaNs from the
%								data. one of the following:
%									'none':	don't remove NaNs. scripts will die!
%									'sample':	remove samples with any NaNs in
%												them
%									'feature':	remove feature dimensions in
%												which any sample has a NaN
%		output_dir:				(<none>) a directory to which to save the
%								results of the classification analysis
%		output_prefix:			('<data_name>-classify') the prefix to use
%								for constructing output file paths, or a cell of
%								output prefixes (one for each dataset)
%		array_to_file:			(false) true to save arrays like sensitivity
%								maps and selected voxels to file instead of
%								returning them in the results struct
%		combine:				(true) true to attempt to combine the results
%								of all the classification analyses. this
%								requires that each analysis was performed with
%								identical sets of mask names, target subsets,
%								etc.
%		group_stats:			(true) true to perform group stats on the
%								accuracies and confusion matrices (<combine>
%								must also be true)
%		nthread:				(1) the number of threads to use
%		closepool:				(true) true to close the matlab pool before
%								and after the MultiTask call
%		force:					(true) true to force the analysis to run even if
%								the output results file already exists
%		force_each:				(<force>) true to force each mask analysis to
%								run even if the mask output exists
%		run:					(true) true to actually run the analyses
%		debug:					('info') the debug level, to determine which
%								messages are shown. one of 'all', 'info',
%								'warn', or 'error'
%		debug_multitask:		('warn') the debug level for the call to
%								MultiTask
%		silent:					(false) true to suppress status messages
% 
% Out:
% 	res	- a struct array of analysis results
% 
% Updated: 2015-01-24
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'path_mask'				, {}			, ...
			'mask_name'				, {}			, ...
			'mask_balancer'			, 'none'		, ...
			'mask_balancer_count'	, 25			, ...
			'partitioner'			, 1				, ...
			'classifier'			, 'LinearCSVMC'	, ...
			'allway'				, true			, ...
			'twoway'				, false			, ...
			'permutations'			, false			, ...
			'sensitivities'			, false			, ...
			'average'				, false			, ...
			'spatiotemporal'		, false			, ...
			'matchedcrossclassify'	, false			, ...
			'match_features'		, false			, ...
			'match_include_blank'	, true			, ...
			'informationflow'		, false			, ...
			'selection'				, 1				, ...
			'save_selected'			, false			, ...
			'target_subset'			, {}			, ...
			'target_blank'			, NaN			, ...
			'zscore'				, 'chunks'		, ...
			'target_balancer'		, 10			, ...
			'mean_control'			, false			, ...
			'sample_attr'			, struct		, ...
			'nan_remove'			, 'none'		, ...
			'output_dir'			, []			, ...
			'output_prefix'			, []			, ...
			'array_to_file'			, false			, ...
			'combine'				, true			, ...
			'group_stats'			, true			, ...
			'nthread'				, 1				, ...
			'closepool'				, true			, ...
			'force'					, true			, ...
			'force_each'			, []			, ...
			'run'					, true			, ...
			'debug'					, 'info'		, ...
			'debug_multitask'		, 'warn'		, ...
			'silent'				, false			  ...
			);
	
	opt.path_script	= PathAddSuffix(mfilename('fullpath'),'','py');
	opt.force_each	= unless(opt.force_each,opt.force);
	
	%make sure we have a scalar cell of a cell of classifiers so everything gets
	%packaged properly down below
		opt.classifier	= ForceCell(opt.classifier,'level',2);
	
	%make sure we got proper option values
		opt.mask_balancer	= CheckInput(opt.mask_balancer,'mask_balancer',{'none','bootstrap','erode'});
		opt.nan_remove		= CheckInput(opt.nan_remove,'nan_remove',{'none','sample','feature'});
	
		if opt.selection<0 || (opt.selection>1 && ~isint(opt.selection))
			error('Uninterpretable selection parameter.');
		end
	
	%are we doing matched dataset cross-classification or information flow
	%classification?
		szData						= size(cPathData);
		bPairedDataset				= iscell(cPathData) && szData(end)==2;
		opt.informationflow			= opt.informationflow && bPairedDataset;
		opt.matchedcrossclassify	= ~opt.informationflow && opt.matchedcrossclassify && bPairedDataset;
		
		if opt.matchedcrossclassify || opt.informationflow
			strAnalysis	= conditional(opt.informationflow,'Information-flow Classification','Matched Dataset Cross-classification');
			status(sprintf('%s will be performed since last dimension of the data has size 2.',strAnalysis),'silent',opt.silent);
			
			%reformat data as a cell of 2x1 cells of file paths
				cSub		= subsall(cPathData);
				cSub		= cSub(1:end-1);
				cPathData	= cellfun(@(f1,f2) {f1;f2},cPathData(cSub{:},1),cPathData(cSub{:},2),'uni',false);
		end
	
	%construct one set of everything for each dataset
		[cPathData,kChunk,opt.zscore,opt.output_prefix]			= ForceCell(cPathData,kChunk,opt.zscore,opt.output_prefix);
		[cTarget,opt.path_mask,opt.mask_name,opt.target_subset]	= ForceCell(cTarget,opt.path_mask,opt.mask_name,opt.target_subset,'level',2);
		
		[cPathData,kChunk,opt.zscore,opt.output_prefix,cTarget,opt.path_mask,opt.mask_name,opt.target_subset]	= FillSingletonArrays(cPathData,kChunk,opt.zscore,opt.output_prefix,cTarget,opt.path_mask,opt.mask_name,opt.target_subset);
		
		szData		= size(cPathData);
		nAnalysis	= numel(cPathData);
	
	%format the targets
		for kA=1:nAnalysis
			%make sure all targets are strings
				if ~iscellstr(cTarget{kA})
					cTarget{kA}	= cellfun(@tostring,cTarget{kA},'uni',false);
				end
			%fill default target_subsets
				if isempty(opt.target_subset{kA})
					opt.target_subset{kA}	= setdiff(unique(cTarget{kA}),unless(opt.target_blank,[],NaN));
				end
		end
	%compress the targets array so we don't have to send so much info to the
	%MultiTask workers
		opt.unique_target	= cellfun(@unique,cTarget,'uni',false);
		[b,kTarget]			= cellfun(@ismember,cTarget,opt.unique_target,'uni',false);
	
	%reformat sample_attr as a szData cell of struct arrays
		if ~isequal(opt.sample_attr,struct)
			if ~isa(opt.sample_attr,'struct')
				error('The ''sample_attr'' option must be a struct.');
			end
			
			%make sure each attribute has an entry for each subject
				opt.sample_attr	= structfun2(@ForceCell,opt.sample_attr);
				
				cField			= fieldnames(opt.sample_attr);
				cAttr			= struct2cell(opt.sample_attr);
				[x,cAttr{:}]	= FillSingletonArrays(cPathData,cAttr{:});
				opt.sample_attr	= cell2struct(cAttr,cField);
			
			%make sure each attribute has an entry for each sample
				opt.sample_attr	= structfun2(@(ca) cellfun(@(a,t) reshape(FillSingletonArrays(a,t),1,[]),ca,cTarget,'uni',false),opt.sample_attr);
			
			opt.sample_attr	= num2cell(opt.sample_attr);
		end
		
	%default output prefixes
		opt.output_prefix	= cellfun(@ParseOutputPrefix,opt.output_prefix,cPathData,'uni',false);
	
	%create the output directory
		if ~isempty(opt.output_dir)
			CreateDirPath(opt.output_dir);
		end

%construct a cell of parameter structs, one for each analysis
	cOpt	= opt2cell(opt);
	param	= num2cell(struct(cOpt{:}));

%run each classification analysis
	cKAnalysis	= num2cell(reshape(1:nAnalysis,size(cPathData)));
	
	res	= MultiTask(@ClassifyOne,{param cKAnalysis cPathData kTarget kChunk},...
						'description'	, 'performing MVPA classifications'	, ...
						'nthread'		, opt.nthread						, ...
						'closepool'		, opt.closepool						, ...
						'debug'			, opt.debug_multitask				, ...
						'silent'		, opt.silent						  ...
						);

x	= res;

if opt.combine
	try
		res	= structtreefun(@CombineResult,res{:});
	catch me
		status('combine option was selected but analysis results are not uniform.','warning',true,'silent',opt.silent);
	end
	
	if opt.group_stats && nAnalysis > 1
		res	= GroupStats(res);
	end
end

if isempty(res) && opt.run
	error('wtf?');
end

%------------------------------------------------------------------------------%
function res = ClassifyOne(param,kAnalysis,strPathData,kTarget,kChunk)
	tNow	= nowms;
	L		= Log('level',param.debug,'silent',param.silent);
	
	%save a custom sample attribute for zscoring if necessary
		if ~isequal(param.zscore,false) && ~ischar(param.zscore)
			param.sample_attr.zscore	= param.zscore;
			param.zscore				= 'zscore';
		end
	
	%reshape the custom sample attributes
		param.sample_attr	= structfun2(@(attr) reshape(attr,1,[]),param.sample_attr);
	
	%file paths
		bSaveOutput	= ~isempty(param.output_dir);
		if ~bSaveOutput
			param.output_dir	= GetTempDir;
		end
		
		param.path_data			= strPathData;
		param.path_attribute	= PathUnsplit(param.output_dir,param.output_prefix,'attr');
		param.path_param		= PathUnsplit(param.output_dir,param.output_prefix,'parameters');
		param.path_result		= PathUnsplit(param.output_dir,param.output_prefix,'mat');
	
	%perform the analysis
	if param.force || ~bSaveOutput || (bSaveOutput && ~FileExists(param.path_result))
		%potentially do mask balancing
			param	= MaskBalancer(param);
		%save the attributes file
			SaveAttributes(param, kTarget, kChunk);
		%save the parameters
			SaveParameters(param,tNow);
		
		%run the python script
			if param.run
				L.Print('calling python classification script','all');
				[ec,str]	= CallProcess('python',{param.path_script param.path_param});
				L.Print('python classification script finished','all');
				
				str	= str{1};
				
				if ec~=0
					error(['python script error (' str ')']);
				end
			end
	end
	
	%load the results
		if param.run
			L.Print('loading classification results','all');
			res	= getfield(load(param.path_result),'result');
			L.Print('loaded classification results','all');
		else
			res	= [];
		end
	
	%delete the temporary files
		if ~bSaveOutput
			rmdir(param.output_dir,'s');
		end
%------------------------------------------------------------------------------%
function param = MaskBalancer(param)
	if isequal(param.mask_balancer,'erode')
	%erode the masks to equal size
		%no need to erode if all masks are already the same size
			nVoxelMask	= cellfun(@(f) sum(reshape(getfield(NIfTIRead(f),'data'),[],1)),param.path_mask);
			
			if uniform(nVoxelMask)
				return;
			end
		
		%get the output paths
			[dummy,cFileMask,cExtMask]	= cellfun(@(f) PathSplit(f,'favor','nii.gz'),param.path_mask,'uni',false);
			cPathOut					= cellfun(@(f,e) PathUnsplit(param.output_dir,[param.output_prefix '-' f '-erode'],e),cFileMask,cExtMask,'uni',false);
		
		%erode
			param.path_mask	= NIfTIMaskErode(param.path_mask,'output',cPathOut,'silent',true);
	end
%------------------------------------------------------------------------------%
function SaveAttributes(param, kTarget, kChunk)
	cTarget	= param.unique_target(kTarget);
	
	attr.target	= cTarget;
	attr.chunk	= kChunk;
	
	strAttr	= struct2table(attr,'heading',false);
	
	fput(strAttr,param.path_attribute);
%------------------------------------------------------------------------------%
function SaveParameters(param,tNow)
	cField	= sort(fieldnames(param));
	
	param.creation_time	= FormatTime(tNow);
	param.generated_by	= mfilename;
	
	param	= orderfields(param,['generated_by'; 'creation_time'; cField]);
	
	param	= structfun2(@FixParameter,param);
	
	json.dump(param,param.path_param);
%------------------------------------------------------------------------------%
function x = FixParameter(x)
	sz	= size(x);
	
	if sz(1) > 1 && sz(2)==1
		x	= x';
	end
%------------------------------------------------------------------------------%
function x = CombineResult(varargin)
	if nargin==0
		x	= [];
	else
		if isnumeric(varargin{1}) && uniform(cellfun(@size,varargin,'uni',false))
			if isscalar(varargin{1})
				x	= cat(1,varargin{:});
			else
				x	= stack(varargin{:});
			end
		else
			x	= reshape(varargin,[],1);
		end
	end
%------------------------------------------------------------------------------%
function res = GroupStats(res)
	if isstruct(res)
		res	= structfun2(@GroupStats,res);
		
		if isfield(res,'accuracy')
			%accuracies
				acc		= res.accuracy.mean;
				nd		= conditional(ndims(acc)==3,3,1);
				chance	= res.accuracy.chance(1,end);
				
				res.stats.accuracy.mean	= mean(acc,nd);
				res.stats.accuracy.se	= stderr(acc,[],nd);
				
				[h,p,ci,stats]	= ttest(acc,chance,'tail','right','dim',nd);
				
				res.stats.accuracy.chance	= chance;
				res.stats.accuracy.df		= stats.df;
				res.stats.accuracy.t		= stats.tstat;
				res.stats.accuracy.p		= p;
			%confusion matrices
				conf	= res.confusion;
				
				if ~iscell(conf)
					res.stats.confusion.mean	= mean(conf,3);
					res.stats.confusion.se		= stderr(conf,[],3);
				end
		end
	end
%------------------------------------------------------------------------------%
function strPrefix = ParseOutputPrefix(strPrefix,strPathData)
	if isempty(strPrefix)
		cPrefix		= cellfun(@PathGetDataName,ForceCell(strPathData),'uni',false);
		strPrefix	= sprintf('%s-classify',join(cPrefix,'_'));
	end
%------------------------------------------------------------------------------%
