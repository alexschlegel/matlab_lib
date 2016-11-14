function res = MVPAClassify(cPathData,cTarget,kChunk,varargin)
% MVPAClassify
% 
% Description:	perform MVPA classification using PyMVPA
% 
% Syntax:	res = MVPAClassify(cPathData,cTarget,kChunk,<options>)
% 
% In:
% 	cPathData	- the path to an nX x nY x nZ x nSample NIfTI file to analyze,
%				  or a cell of paths to perform multiple classifications. for
%				  classifications that require paired datasets (matched dataset
%				  cross-classification and directed connectivity
%				  classification), then this must be a cell and each element
%				  must be a two element cell of the two datapaths required for
%				  each classification. in this case, both datasets must have the
%				  same target/chunk structure.
%	cTarget		- an nSample x 1 cell specifying the target of each sample, or a
%				  cell of sample cell arrays (one for each classification)
%	kChunk		- an nSample x 1 array specifying the chunk of each sample, or a
%				  cell of chunk arrays (one for each classification)
%	<options>:
%		dir_out:				(<none>) the directory to which to save the
%								results of the classification analyses
%		name:					(<auto>) a name for each analysis. used for
%								constructing output file paths.
%		path_mask:				(<none>) the path to a mask NIfTI file to apply
%								to the data, or a cell of mask paths (or a cell
%								of cells of mask paths, one cell for each
%								classification)
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
%									str:	a string to be eval'ed in python,
%											the result of which is the
%											partitioner
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
%								sensivities cannot be saved if nested classifier
%								selection is selected.
%		average:				(false) true to average samples from the same
%								target and chunk (ignored for directed
%								connectivity classifications)
%		spatiotemporal:			(false) true to do a spatiotemporal analysis
%								(ignored for directed connectivity
%								classifications)
%		matchedcrossclassify:	(false) true to perform matched dataset
%								cross-classification, in which the classifier is
%								trained on one dataset and tested on the other.
%								both datasets are included in training and
%								testing.
%		match_features:			(false) true to perform feature matching between
%								the training and testing datasets in matched
%								dataset cross-classifications
%		match_include_blank:	(true) true to include blank samples in the
%								feature matching step of matched dataset
%								cross-classifications
%		dcclassify:				(false) true to perform a directed connectivity
%								classification, in which directed connectivity
%								patterns are constructed for each target and
%								chunk by calculating the Granger Causality from
%								each feature of dataset 1 to each feature of
%								dataset 2. the classification is performed on
%								these patterns.
%		dcclassify_lags:		(1) the number of lags to use in directed
%								connectivity classifications
%		selection:				(1) the number or fraction of features to select
%								for classification, based on a one-way ANOVA. if
%								a number less than one is passed, it is
%								interpreted as a fraction. if an integer greater
%								than one is passed, it is interpreted as the
%								number of features to keep.
%		save_selected:			(false) true to save a map for each
%								classification showing the fraction of folds in
%								which each voxel was selected
%		target_subset:			(<all except blank>) a cell specifying the
%								subset of targets to include in the analyses
%		target_blank:			(<none>) a string specifying the 'blank' target
%								that should be eliminated before classifying
%		zscore:					('chunks') the sample attribute to use as the
%								chunks_attr for z-scoring, or an nSample x 1
%								array to use as a custom attribute (or a cell of
%								arrays, one for each classification). set to
%								false to skip z-scoring.
%		target_balancer:		(10) the number of permutations to perform for
%								unbalanced targets. set to false to skip target
%								balancing. this is ignored for directed
%								connectivity classifications.
%		mean_control:			(false) true to perform a control classification
%								on the mean pattern value of each target and
%								chunk
%		nan_remove:				('none') specify how to remove NaNs from the
%								data. one of the following:
%									'none':		don't remove NaNs. scripts will
%												die!
%									'sample':	remove samples with any NaNs in
%												them
%									'feature':	remove feature dimensions in
%												which any sample has a NaN
%		array_to_file:			(false) true to save arrays like sensitivity
%								maps and selected voxels to file instead of
%								returning them in the results struct
%		combine:				(true) true to attempt to combine the results
%								of all the classification analyses. this
%								requires that each analysis was performed with
%								identical sets of mask names, targets, etc.
%		stats:					(<combine>) true to perform group stats on
%								the accuracies and confusion matrices (<combine>
%								must also be true)
%		confusion_model:		([]) the confusion model or cell of models to
%								compare with the actual confusion matrices.
%								If <matched_confmodels> is true, there are
%								additional requirements (see below).
%		confcorr_method:		('subjectjk') the method to use for calculating
%								confusion correlation stats. one of the
%								following:
%									group:		correlate the model with the
%												group mean confusion matrix
%									subject:	correlate the model with each
%												subject's confusion matrix and
%												perform a t-test
%									subjectjk:	correlate the model with
%												jackknifed group mean confusion
%												matrices and perform a jackknife
%												t-test
%		matched_confmodels:		(false) true to indicate that each
%								subject's confusion matrices should be
%								correlated with their own confusion model.
%								If true, <confusion_model> must be a cell
%								of models with numel equal to the last 
%								non-singleton dimension of cPathData.
%								<confusion_model> can also be a cell of
%								such cells of models, in which case multiple
%								sets of models will be tested. If <confusion_model>
%								is a cell containing a mixture of
%								individual models and at least one
%								nSubject-length cell of models, the
%								individual models will be tested against
%								the results from all classifications.
%								If <confcorr_method> = 'group', sets of
%								models will be meaned before correlating
%								with the group mean confusion matrix.
%		cores:					(1) the number of processor cores to use
%		force:					(true) true to force the analysis to run even if
%								the output results files already exist
%		force_each:				(<force>) true to force each mask analysis to
%								run even if the mask output exists
%		run:					(true) true to actually run the analyses
%		type:					('mvpaclassify') an identifier for the
%								classification type
%		debug:					('info') the debug level, to determine which
%								messages are shown. one of 'all', 'info',
%								'warn', or 'error'.
%		debug_multitask:		('warn') the debug level for the call to
%								MultiTask
%		error:					(false) true to raise an error if one related to
%								script execution occurs (some other errors may
%								occur regardless). false to just display the
%								error as a warning and return blank results for
%								the classification in which the error occurred.
%		silent:					(false) true to suppress status messages
% 
% Out:
% 	res	- if <combine> is selected, then a structtree of analysis results.
%		  otherwise, a cell of result structs.
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'dir_out'				, []				, ...
			'name'					, []				, ...
			'path_mask'				, {}				, ...
			'mask_name'				, {}				, ...
			'mask_balancer'			, 'none'			, ...
			'mask_balancer_count'	, 25				, ...
			'partitioner'			, 1					, ...
			'classifier'			, 'LinearCSVMC'		, ...
			'allway'				, true				, ...
			'twoway'				, false				, ...
			'permutations'			, false				, ...
			'sensitivities'			, false				, ...
			'average'				, false				, ...
			'spatiotemporal'		, false				, ...
			'matchedcrossclassify'	, false				, ...
			'match_features'		, false				, ...
			'match_include_blank'	, true				, ...
			'dcclassify'			, false				, ...
			'dcclassify_lags'		, 1					, ...
			'selection'				, 1					, ...
			'save_selected'			, false				, ...
			'target_subset'			, {}				, ...
			'target_blank'			, NaN				, ...
			'zscore'				, 'chunks'			, ...
			'target_balancer'		, 10				, ...
			'mean_control'			, false				, ...
			'nan_remove'			, 'none'			, ...
			'array_to_file'			, false				, ...
			'combine'				, true				, ...
			'stats'					, []				, ...
			'confusion_model'		, {}				, ...
			'confcorr_method'		, 'subjectjk'		, ...
			'matched_confmodels'	, false				, ...
			'cores'					, 1					, ...
			'force'					, true				, ...
			'force_each'			, []				, ...
			'run'					, true				, ...
			'type'					, 'mvpaclasssify'	, ...
			'debug'					, 'info'			, ...
			'debug_multitask'		, 'warn'			, ...
			'error'					, false				, ...
			'silent'				, false				  ...
			);
	
	opt.path_script	= PathAddSuffix(mfilename('fullpath'),'','py');
	opt.stats		= unless(opt.stats,opt.combine);
	opt.force_each	= unless(opt.force_each,opt.force);
		
	%make sure we got proper option values
		opt.mask_balancer	= CheckInput(opt.mask_balancer,'mask_balancer',{'none','bootstrap','erode'});
		opt.nan_remove		= CheckInput(opt.nan_remove,'nan_remove',{'none','sample','feature'});
		opt.confcorr_method	= CheckInput(opt.confcorr_method,'confusion correlation method',{'group','subject','subjectjk'});
		
		assert(opt.selection>=0 && (opt.selection<1 || isint(opt.selection)),'uninterpretable selection parameter.');
	
	%make sure we have a cell of cells of file paths
		cPathData	= ForceCell(cPathData);
		cPathData	= cellfun(@ForceCell,cPathData,'uni',false);
		
	% format confusion_model and validate
		opt.confusion_model	= ForceCell(opt.confusion_model);
		if opt.matched_confmodels
			% get nSubject
			nd	= find(size(cPathData)~=1,1,'last');
			bModelCell = cellfun(@iscell, opt.confusion_model);
			if any(bModelCell)
				% cell of sets of models
				assert(all(cellfun(@(c) isequal(numel(c),size(cPathData,nd)), ...
					opt.confusion_model(bModelCell))), 'length of some confusion model set(s) does not match nSubject.');
				opt.confusion_model(bModelCell) = cellfun(@(c) reshape(c,[],1), opt.confusion_model(bModelCell), 'uni', false);
				% expand any singleton models
				opt.confusion_model = cellfun(@ForceCell,opt.confusion_model,'uni',false);
				[opt.confusion_model{:}] = FillSingletonArrays(opt.confusion_model{:});
			else
				% set of models
				assert(isequal(numel(opt.confusion_model), size(cPathData,nd)), ...
					'length of confusion model set does not match nSubject.');
				reshape(opt.confusion_model,[],1);
				opt.confusion_model = {opt.confusion_model};
			end
		end
	
	%make sure we have a classification-specific parameter for each classification
		[kChunk,opt.zscore,opt.name]			= ForceCell(kChunk,opt.zscore,opt.name);
		[cTarget,opt.path_mask,opt.mask_name]	= ForceCell(cTarget,opt.path_mask,opt.mask_name,'level',2);
		
		[cPathData,kChunk,opt.zscore,opt.name,cTarget,opt.path_mask,opt.mask_name]	= FillSingletonArrays(cPathData,kChunk,opt.zscore,opt.name,cTarget,opt.path_mask,opt.mask_name);
	
	%make sure all targets are strings
		cTarget	= cellfun(@FormatTargets,cTarget,'uni',false);
	
	%compress the targets array so we don't have to send so much info to the
	%MultiTask workers
		opt.unique_target	= cellfun(@unique,cTarget,'uni',false);
		[b,kTarget]			= cellfun(@ismember,cTarget,opt.unique_target,'uni',false);
	
	%default target_subset
		if isempty(opt.target_subset)
			cTargetUnique		= unique(cat(1,opt.unique_target{:}));
			
			if ~isnan(opt.target_blank)
				opt.target_subset	= setdiff(cTargetUnique,opt.target_blank);
			end
		end
	
	%create the output directory
		bSaveOutput	= ~isempty(opt.dir_out);
		if bSaveOutput
			CreateDirPath(opt.dir_out);
		else
			opt.dir_out	= GetTempDir;
		end

%construct a cell of parameter structs, one for each analysis
	%make sure we have a cell of a cell for some parameters so everything gets
	%packaged properly
		[opt.classifier,opt.target_subset]	= ForceCell(opt.classifier,opt.target_subset,'level',2);
	%add the data paths to the opt struct
		opt.path_data	= cPathData;
	
	%get rid of options that only apply here
		param	= rmfield(opt,{'opt_extra','isoptstruct','combine','stats','confusion_model','confcorr_method','cores','type','debug_multitask'});
	
	%switcheroo to one param struct per analysis
		param	= opt2cell(param);
		param	= num2cell(struct(param{:}));
	
	param	= cellfun(@ParseParam,param,'uni',false);

%which analyses do we need to perform?
	sz	= size(param);
	
	res	= cell(sz);
	if opt.force
		bDo	= true(sz);
	else
		bDo	= ~cellfun(@OutputExists,param);
	end

%load the existing results
	res(~bDo)	= cellfunprogress(@LoadResult,param(~bDo),...
					'label'		, 'loading existing results'	, ...
					'uni'		, false							, ...
					'silent'	, opt.silent					  ...
					);
	
%run each classification analysis
	if any(bDo(:))
		res(bDo)	= MultiTask(@ClassifyOne,{param(bDo) kTarget(bDo) kChunk(bDo)},...
						'description'	, 'performing MVPA classifications'	, ...
						'cores'			, opt.cores							, ...
						'debug'			, opt.debug_multitask				, ...
						'silent'		, opt.silent						  ...
						);
	end

%delete the output directory if not needed
	if ~bSaveOutput
		rmdir(opt.dir_out,'s');
	end

%construct dummy structs for failed classifications
	bFailed	= cellfun(@(r) ~r.success,res);
	if any(bFailed(:))
		kGood	= find(~bFailed,1);
		if ~isempty(kGood)
			resDummy		= dummy(res{kGood});
			res(bFailed)	= cellfun(@(r) FillFailedResult(r,resDummy),res(bFailed),'uni',false);
		end
	end

if opt.combine
	nClassification	= numel(res);
	
	res			= restruct(res);
	res.type	= opt.type;
	
	res.result	= structtreefun(@StackCell,res.result);
	
	if opt.stats && nClassification>1
		res	= DoStats(res,opt);
	end
end


%------------------------------------------------------------------------------%
function res = ClassifyOne(param,kTarget,kChunk)
	res	= struct('success',false,'param',param);
	
	tNow	= nowms;
	L		= Log(...
				'name'		, param.name	, ...
				'level'		, param.debug	, ...
				'silent'	, param.silent	  ...
				);
	
	%do some error checking
		try
			assert(~isempty(kTarget),'targets are undefined');
			assert(~isempty(kChunk),'chunks are undefined');
			
			nData	= numel(param.path_data);
			for kD=1:nData
				assert(FileExists(param.path_data{kD}),'%s does not exist',param.path_data{kD});
			end
			
			nMask	= numel(param.path_mask);
			for kM=1:nMask
				assert(FileExists(param.path_mask{kM}),'%s does not exist',param.path_mask{kM});
			end
		catch me
			if param.error
				rethrow(me);
			else
				L.Print(sprintf('%s. classification will not be performed.',me.message),'error',...
					'exception'	, me	  ...
					);
				return;
			end
		end
	
	%parse the mask balancer
		param	= ParseMaskBalancer(param);
	
	%save the attributes file
		SaveAttributes(param,kTarget,kChunk);
	%save the parameters
		SaveParameters(param,tNow);
	
	if ~param.run
		return;
	end
	
	%run the python script
		L.Print('calling python classification script','all');
		[ec,str]	= CallProcess('python',{param.path_script param.path_param});
		L.Print('python classification script finished','all');
		
		if ec~=0
			strError	= sprintf('python script error: %s',str{1});
			if param.error
				error(strError);
			else
				L.Print(strError,'error');
				return;
			end
		end
	
	%load the results
		res	= LoadResult(param);
%------------------------------------------------------------------------------%
function param = ParseMaskBalancer(param)
	if isequal(param.mask_balancer,'erode')
	%erode the masks to equal size
		%no need to erode if all masks are already the same size
			nVoxelMask	= cellfun(@(f) sum(reshape(NIfTI.Read(f,'return','data'),[],1)),param.path_mask);
			
			if uniform(nVoxelMask)
				return;
			end
		
		%get the output paths
			[dummy,cFileMask,cExtMask]	= cellfun(@(f) PathSplit(f,'favor','nii.gz'),param.path_mask,'uni',false);
			cPathOut					= cellfun(@(f,e) PathUnsplit(param.dir_out,sprintf('%s-%s-erode',param.name,f),e),cFileMask,cExtMask,'uni',false);
		
		%erode
			param.path_mask	= NIfTI.MaskErode(param.path_mask,'output',cPathOut,'silent',true);
	end
%------------------------------------------------------------------------------%
function SaveAttributes(param,kTarget,kChunk)
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
	
	param	= structtreefun(@FixParameter,param);
	
	json.dump(param,param.path_param);
%------------------------------------------------------------------------------%
function x = FixParameter(x)
%reshape Nx1 arrays to 1xN to avoid ridiculous json
	sz	= size(x);
	nd	= numel(sz);
	
	if nd==2 && sz(1)>1 && sz(2)==1
		x	= reshape(x,1,[]);
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function cTarget = FormatTargets(cTarget)
	if ~iscellstr(cTarget)
		if ~iscell(cTarget)
			cTarget	= num2cell(cTarget);
		end
		cTarget	= cellfun(@tostring,cTarget,'uni',false);
	end
	
	cTarget	= reshape(cTarget,[],1);
%------------------------------------------------------------------------------%
function param = ParseParam(param)
	%default analysis name
		if isempty(param.name)
			cName		= cellfun(@PathGetDataName,param.path_data,'uni',false);
			param.name	= sprintf('%s-classify',join(cName,'_'));
		end 
		
	%initialize the custom sample attributes struct
		param.sample_attr	= struct;
	
	%save a custom sample attribute for zscoring if necessary
		if ~isequal(param.zscore,false) && ~ischar(param.zscore)
			param.sample_attr.zscore	= param.zscore;
			param.zscore				= 'zscore';
		end
	
	%file paths
		param.path_attribute	= PathUnsplit(param.dir_out,param.name,'attr');
		param.path_param		= PathUnsplit(param.dir_out,param.name,'parameters');
		param.path_result		= PathUnsplit(param.dir_out,param.name,'mat');
%------------------------------------------------------------------------------%
function x = StackCell(x)
	if iscell(x) && ~isempty(x) && uniform(cellfun(@size,x,'uni',false))
		szIn	= size(x{1});
		kLast	= find(szIn>1,1,'last');
		
		szOut	= size(x);
		
		x	= stack(x{:});
		x	= reshape(x,[szIn(1:kLast) szOut]);
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function b = OutputExists(param)
	b	= FileExists(param.path_result);
%------------------------------------------------------------------------------%
function res = LoadResult(param)
	res			= load(param.path_result);
	res.success	= true;
	res.param	= param;
%------------------------------------------------------------------------------%
function resFill = FillFailedResult(res,resDummy) 
	resFill			= resDummy;
	resFill.success	= res.success;
	resFill.param	= res.param;
%------------------------------------------------------------------------------%
function res = DoStats(res,opt)
	%perform some stats on each group-wide classification analysis
		res.result	= DoIndividualStats(res.result,opt);
	%now do some stats involving all classifications
		res	= MVPAHigherStats(res);
%------------------------------------------------------------------------------%
function res = DoIndividualStats(res,opt)
	if isstruct(res)
		if IsClassificationResult(res)
			%accuracies
				acc	= res.accuracy.mean;
				nd	= find(size(acc)~=1,1,'last');
				
				chance	= res.accuracy.chance(find(~isnan(res.accuracy.chance),1));
				
				res.stats.accuracy.mean	= nanmean(acc,nd);
				res.stats.accuracy.se	= nanstderr(acc,[],nd);
				
				[h,p,ci,stats]	= ttest(acc,chance,'tail','right','dim',nd);
				
				res.stats.accuracy.chance	= chance;
				res.stats.accuracy.df		= stats.df;
				res.stats.accuracy.t		= stats.tstat;
				res.stats.accuracy.p		= p;
			%confusion matrices
				conf	= res.confusion;
				nd		= find(size(conf)~=1,1,'last');
				
				if ~iscell(conf)
					res.stats.confusion.mean	= nanmean(conf,nd);
					res.stats.confusion.se		= nanstderr(conf,[],nd);
					
					if ~isempty(opt.confusion_model)						
						res.stats.confusion.corr	= cellfun(@(cm) ConfusionCorrelation(conf,nd,cm,opt.confcorr_method),opt.confusion_model);
					end
				end
		else
			res	= structfun2(@(r) DoIndividualStats(r,opt),res);
		end
	end
%------------------------------------------------------------------------------%
function b = IsClassificationResult(res) 
	b	= isstruct(res) && isfield(res,'accuracy') && isfield(res,'confusion');
%------------------------------------------------------------------------------%
function stat = ConfusionCorrelation(conf,dimSubject,confModel,strMethod)
	bMatchedConf = iscell(confModel);
	switch strMethod
		case 'group'
			confGroup	= squeeze(nanmean(conf,dimSubject));
			if bMatchedConf
				confModel = mean(cat(3,confModel{:}),3);
			end
			stat		= ConfCorr(confGroup,confModel);
		case 'subject'
			%extract each matrix
				cK				= num2cell(size(conf));
				cK{dimSubject}	= ones(size(conf,dimSubject),1);
				cConf			= squeeze(mat2cell(conf,cK{:}));
				cConf			= cellfun(@squeeze,cConf,'uni',false);
			%calculate the correlation for each confusion matrix
				if bMatchedConf
					stat	= cellfun(@ConfCorr, cConf, confModel);
				else
					stat	= cellfun(@(conf) ConfCorr(conf,confModel),cConf);
				end
				stat		= restruct(stat);
				stat		= structfun2(@StackCell,stat);
				stat		= rmfield(stat,{'tails','df','t','p','cutoff','m','b'});
			%calculate a t-test across subjects
				nd			= unless(find(size(stat.r)>1,1,'last'),1);
				stat.mr		= nanmean(stat.r,nd);
				stat.ser	= nanstderr(stat.r,[],nd);
				stat.mz		= nanmean(stat.z,nd);
				stat.sez	= nanstderr(stat.z,[],nd);
				
				[h,p,ci,stats]	= ttest(stat.z,0,0.05,'right',nd);
				
				stat.p	= p;
				stat.t	= stats.tstat;
				stat.df	= stats.df;
		case 'subjectjk'
			%extract each matrix
				cK				= num2cell(size(conf));
				cK{dimSubject}	= ones(size(conf,dimSubject),1);
				cConf			= squeeze(mat2cell(conf,cK{:}));
				cConf			= cellfun(@squeeze,cConf,'uni',false);
			%compute jackknifed means
				cConfJK	= jackknife(@(x) {nanmean(cat(dimSubject,x{:}),dimSubject)},cConf);
				if bMatchedConf
					confModelJK = jackknife(@(x) {mean(cat(3,x{:}),3)}, confModel);
				
			%calculate the correlation for each confusion matrix
					stat	= cellfun(@ConfCorr, cConfJK, confModelJK);
				else
					stat		= cellfun(@(conf) ConfCorr(conf,confModel),cConfJK);
				end
				stat		= restruct(stat);
				stat		= structfun2(@StackCell,stat);
				stat		= rmfield(stat,{'tails','df','t','p','cutoff','m','b'});
			%calculate a jackknife t-test across subjects
				nd			= unless(find(size(stat.r)>1,1,'last'),1);
				stat.mr		= nanmean(stat.r,nd);
				stat.ser	= nanstderrJK(stat.r,[],nd);
				stat.mz		= nanmean(stat.z,nd);
				stat.sez	= nanstderrJK(stat.z,[],nd);
				
				[h,p,ci,stats]	= ttestJK(stat.z,0,0.05,'right',nd);
				
				stat.p	= p;
				stat.t	= stats.tstat;
				stat.df	= stats.df;
	end
	
	stat.method	= strMethod;
%------------------------------------------------------------------------------%
function stat = ConfCorr(conf,confModel)
	sz		= size(conf);
	nd		= numel(sz);
	
	conf	= permute(conf,[3:nd 1 2]);
	conf	= reshape(conf,[unless(sz(3:nd),1) sz(1)*sz(2)]);
	
	confModel	= reshape(confModel,[],1);
	
	[r,stat]	= corrcoef2(confModel,conf,'twotail',false);
%------------------------------------------------------------------------------%
