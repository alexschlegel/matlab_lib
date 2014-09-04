function [res,str] = MVPAClassify(strPathNII,cTarget,kChunk,varargin)
% MVPAClassify
% 
% Description:	perform MVPA classification using PyMVPA
% 
% Syntax:	res = MVPAClassify(strPathNII,cTarget,kChunk,<options>)
% 
% In:
% 	strPathNII	- the path to the nX x nY x nZ x nS NIfTI file to analyze
%	cTarget		- an nSx1 cell specifying the target of each sample
%	kChunk		- an nSx1 array specifying the chunk of each sample
%	<options>:
%		mask_path:			(<none>) the path to a mask NIfTI file to apply to
%							the data, or a cell of mask paths
%		mask_balancer:		('none') the strategy to use if non-uniformly sized
%							masks are specified. one of the following:
%								'erode': erode each mask to be the same size
%								'bootstrap': bootstrap subsets of masks. a
%									subset of the voxels in each mask will be
%									randomly chosen (based on the smallest
%									mask), and the classification performed on
%									that mask subset.
%								'none': nothing will be done to correct for
%									uneven mask sizes
%		mask_balancer_count:(25) the number of bootstrap iterations to perform
%							for each mask when balancing (see above)
%		classifier:			('LinearCSVMC') the classifier to use. suggestions:
%								LinearCSVMC, SMLR
%		classifier_param:	(<none>) a struct specifying parameter values for
%							the classifier. field names signify parameter names.
%							e.g. struct('lm',0.1).
%		allway:				(true) true to perform an all-way classification
%		twoway:				(false) true to perform every pairwise
%							classification
%		permutation_test:	(false) true to perform Monte Carlo significance
%							testing on the accuracies
%		permutation_count:	(1000) the number of permutations to perform during
%							Monte Carlo testing
%		sensitivities:		(false) true to save the L1-normed classification
%							sensitivities
%		sensitivity_stats:	(false) true to calculate some stats for the
%							sensitivities that probably aren't even correct
%		average:			(false) true to average samples from the same target
%							and chunk
%		spatiotemporal:		(false) true to do a spatiotemporal analysis
%		selection:			(1) the number/fraction of features to select for
%							classification, based on a one-way ANOVA. if a
%							number less than one is passed, it is interpreted as
%							a fraction. if an integer greater than one is
%							passed, it is interpreted as an absolute number of
%							features to keep.
%		save_selected:		(false) true to save a map for each classification
%							showing the fraction of folds in which each voxels
%							was selected. note that selected voxels cannot be
%							saved if permutation testing is selected (outta
%							control RAM).
%		target_subset:		(<all>) a cell specifying the subset of targets to
%							include in the analysis
%		target_blank:		(<none>) a string specifying the 'blank' target that
%							should be eliminated before classifying
%		zscore:				(true) true to zscore within chunks
%		zscore_attr:		('chunks') the sample attribute to use for zscoring.
%							either a sample attribute name or an nSample x 1
%							array.
%		leaveout:			(1) the number of samples to leave out of each fold
%		target_balancer:	(true) true to do balancing for unbalanced targets
%		balancer_count:		(10) the number of permutations to perform for
%							unbalanced targets
%		mean_control:		(false) true to perform a control classification on
%							the mean pattern values
%		nan_remove:			('none') specify how to remove NaNs from the data.
%							one of the following:
%								'none':	don't remove NaNs. scripts will die!
%								'sample':	remove samples with any NaNs in them
%								'feature':	remove feature dimensions in which
%											any sample has a NaN
%		script_path:		(<none>) a path to which to save the python script
%							that performs the classification analysis
%		run:				(true) true to actually run the analysis
%		force:				(true) true to force the analysis to run even if the
%							output files already exist
% 
% Out:
% 	res	- a struct array of analysis results (one struct array element for each
%		  mask)
% 
% Updated: 2013-11-02
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent strTemplate;

if isempty(strTemplate)
	strPathTemplate	= PathAddSuffix(mfilename('fullpath'),'','py');
	strTemplate		= fget(strPathTemplate);
end

opt	= ParseArgsOpt(varargin,...
		'mask_path'				, {'None'}		, ...
		'mask_balancer'			, 'none'		, ...
		'mask_balancer_count'	, 25			, ...
		'classifier'			, 'LinearCSVMC'	, ...
		'classifier_param'		, []			, ...
		'allway'				, true			, ...
		'twoway'				, false			, ...
		'permutation_test'		, false			, ...
		'permutation_count'		, 1000			, ...
		'sensitivities'			, false			, ...
		'sensitivity_stats'		, false			, ...
		'average'				, false			, ...
		'spatiotemporal'		, false			, ...
		'selection'				, 1				, ...
		'save_selected'			, false			, ...
		'target_subset'			, []			, ...
		'target_blank'			, ''			, ...
		'zscore'				, true			, ...
		'zscore_attr'			, 'chunks'		, ...
		'leaveout'				, 1				, ...
		'target_balancer'		, true			, ...
		'balancer_count'		, 10			, ...
		'mean_control'			, false			, ...
		'nan_remove'			, 'none'		, ...
		'script_path'			, []			, ...
		'run'					, true			, ...
		'force'					, true			  ...
		);

opt.save_selected	= opt.save_selected && ~opt.permutation_test;

if opt.selection<0 || (opt.selection>1 && ~isint(opt.selection))
	error('Uninterpretable selection parameter.');
end

cPathMask	= ForceCell(opt.mask_path);
nMask		= numel(cPathMask);

%file paths
	bSaveScript	= ~isempty(opt.script_path);
	if bSaveScript
		strDirScript	= PathGetDir(opt.script_path);
		CreateDirPath(strDirScript);
		
		strPathScript	= opt.script_path;
	else
		strPathScript	= GetTempFile('ext','py');
	end
	
	strPathAttr		= PathAddSuffix(strPathScript,'','attr');
	strPathResult	= PathAddSuffix(strPathScript,'','mat');

if opt.force || ~bSaveScript || (bSaveScript && ~FileExists(strPathResult))
%perform the analysis
	%parse the mask balancing method
		bMaskBalancer	= false;
		if nMask>1 && ~isequal(opt.mask_balancer,'none')
			nVoxelMask		= sum(reshape(getfield(NIfTIRead(cPathMask{1}),'data')~=0,[],1));
			
			for kM=2:nMask
				if sum(reshape(getfield(NIfTIRead(cPathMask{kM}),'data')~=0,[],1))~=nVoxelMask
					bMaskBalancer	= true;
					break;
				end
			end
			
			if bMaskBalancer && isequal(opt.mask_balancer,'erode')
			%erode the masks to be the same size
				if bSaveScript
					[strDirScript,strFileScript]	= PathSplit(strPathScript);
					[dummy,cFileMask,cExtMask]		= cellfun(@(f) PathSplit(f,'favor','nii.gz'),cPathMask,'uni',false);
					cPathOut						= cellfun(@(f,e) PathUnsplit(strDirScript,[strFileScript '-' f '-erode'],e),cFileMask,cExtMask,'uni',false);
				else
					cPathOut		= [];
				end
				
				bMaskBalancer	= false;
				cPathMask		= NIfTIMaskErode(cPathMask,'output',cPathOut,'silent',true);
			end
		end

	cTarget	= cellfun(@tostring,cTarget,'UniformOutput',false);
	
	cTargetUnique	= unique(cTarget);
	if isempty(opt.target_subset)
		opt.target_subset	= cTargetUnique;
	end
	
	%save the attribute file
		attr.target	= cTarget;
		attr.chunk	= kChunk;
		
		strAttr	= struct2table(attr,'heading',false);
		
		fput(strAttr,strPathAttr);
	
	%fill the script template
		%misc.
			s.creation_time		= FormatTime(nowms);
		%paths
			s.path_attribute	= strPathAttr;
			s.path_data			= strPathNII;
			s.path_result		= strPathResult;
		%masks
			s.path_mask				= join(cellfun(@(x) conditional(isequal(x,'None'),x,['''' x '''']),cPathMask,'UniformOutput',false),',');
			s.do_mask_balancer		= pybool(bMaskBalancer);
			s.mask_balancer_count	= opt.mask_balancer_count;
		%target subset
			s.do_target_subset	= pybool(any(~ismember(cTargetUnique,opt.target_subset)));
			s.target_subset		= join(cellfun(@(x) ['''' x ''''],opt.target_subset,'UniformOutput',false),',');
		%target blank
			s.do_target_blank	= pybool(~isempty(opt.target_blank));
			s.target_blank		= opt.target_blank;
		%classifier
			s.classifier		= opt.classifier;
			
			if ~isempty(opt.classifier_param)
				s.classifier_param	= join(cellfun(@(p,v) [p '=' conditional(ischar(v),['''' v ''''],tostring(v))],fieldnames(opt.classifier_param),struct2cell(opt.classifier_param),'UniformOutput',false),', ');
			else
				s.classifier_param	= '';
			end
		%average samples?
			s.do_average		= pybool(opt.average);
		%spatiotemporal
			s.do_spatiotemporal	= pybool(opt.spatiotemporal);
		%feature selection
			s.do_selection			= pybool(opt.selection~=1);
			s.do_selection_fraction	= pybool(opt.selection<1);
			s.do_selection_n		= pybool(opt.selection>1);
			s.selection_parameter	= opt.selection;
			s.do_save_selected		= pybool(opt.save_selected);
		%permutation testing
			s.do_permutation_test	= pybool(opt.permutation_test);
			s.permutation_count		= opt.permutation_count;
		%z-score
			s.do_zscore	= pybool(opt.zscore);
			
			bCustomZScore		= ~ischar(opt.zscore_attr);
			s.do_custom_zscore	= pybool(bCustomZScore);
			if bCustomZScore
				s.zscore_attr		= 'zscore';
				s.zscore_attr_val	= join(opt.zscore_attr,',');
			else	
				s.zscore_attr		= opt.zscore_attr;
				s.zscore_attr_val	= '';
			end
		%partitioner
			s.nfold_leaveout	= opt.leaveout;
		%balance?
			[b,kTarget]			= ismember(cTarget,cTargetUnique);
			hTarget				= hist(kTarget,1:numel(cTargetUnique));
			bDoBalancer			= opt.target_balancer && ~uniform(hTarget);
			s.do_balancer		= pybool(bDoBalancer);
			s.balancer_count	= opt.balancer_count;
		%mean control
			s.do_mean_control	= pybool(opt.mean_control);
		%NaNs
			s.nan_dimension	= switch2(opt.nan_remove,'none',-1,'sample',0,'feature',1);
		%allway/twoway
			s.do_allway	= pybool(opt.allway);
			s.do_twoway	= pybool(opt.twoway);
		%sensitivities
			s.do_sensitivities	= pybool(opt.sensitivities);
		
		strScript	= StringFillTemplate(strTemplate,s);
	
	%save the script
		fput(strScript,strPathScript);
	%run the script
		if opt.run
			[ec,str]	= RunBashScript(['python ' strPathScript],'silent',true);
		end
	
	%parse the results
		if opt.run
			if ec==0
				%load the results
					resPy	= load(strPathResult);
				
				%parse the results
					res	= cell(nMask,1);
					
					for kM=1:nMask
						res{kM}.target	= split(resPy.(pykey('target',kM)),9);
						nTarget			= numel(res{kM}.target);
						
						if opt.allway
							res{kM}.allway.accuracy.result	= resPy.(pykey('allway_accuracy',kM));
							
							if bDoBalancer
								res{kM}.allway.accuracy.result	= mean(reshape(res{kM}.allway.accuracy.result,opt.balancer_count,[]),1)';
							end
							
							res{kM}.allway.accuracy.stats	= AccuracyStats(res{kM}.allway.accuracy.result,1/nTarget);
							res{kM}.allway.confusion		= resPy.(pykey('allway_confusion',kM));
							
							if opt.permutation_test
								res{kM}.allway.accuracy.stats.permutation_p	= resPy.(pykey('allway_pvalue',kM));
							end
							
							if opt.mean_control
								res{kM}.allway.mean_control.accuracy.result	= resPy.(pykey('mean_allway_accuracy',kM));
								
								res{kM}.allway.mean_control.accuracy.stats	= AccuracyStats(res{kM}.allway.mean_control.accuracy.result,1/nTarget);
								res{kM}.allway.mean_control.confusion		= resPy.(pykey('mean_allway_confusion',kM));
								
								if opt.permutation_test
									res{kM}.allway.mean_control.accuracy.stats.permutation_p	= resPy.(pykey('mean_allway_pvalue',kM));
								end
							end
							
							if opt.sensitivities
								res{kM}.allway.sensitivity.result	= resPy.(pykey('allway_sensitivity',kM));
								res{kM}.allway.sensitivity.stats	= SensitivityStats(res{kM}.allway.sensitivity.result);
							end
							
							if opt.save_selected
								if bMaskBalancer
									res{kM}.allway.selected.path	= arrayfun(@(kb) resPy.(pykey('selected_allway',[kM kb])),(1:opt.mask_balancer_count)','UniformOutput',false);
								else
									res{kM}.allway.selected.path	= resPy.(pykey('selected_allway',kM));
								end
							end
						end
						
						if opt.twoway
							res{kM}.twoway.accuracy.result	= cell(nTarget);
							
							if opt.mean_control
								res{kM}.twoway.mean_control.accuracy.result	= cell(nTarget);
							end
							
							if opt.sensitivities
								res{kM}.twoway.sensitivity.result	= cell(nTarget);
							end
							
							if opt.save_selected
								res{kM}.twoway.selected.path	= cell(nTarget);
							end
							
							for k1=1:nTarget
								for k2=k1+1:nTarget
									res{kM}.twoway.accuracy.result{k1,k2}	= resPy.(pykey('twoway_accuracy',[kM k1 k2]));
									
									if bDoBalancer
										res{kM}.twoway.accuracy.result{k1,k2}	= mean(reshape(res{kM}.twoway.accuracy.result{k1,k2},opt.balancer_count,[]),1)';
									end
									
									res{kM}.twoway.accuracy.result{k2,k1}	= res{kM}.twoway.accuracy.result{k1,k2};
									
									if opt.mean_control
										res{kM}.twoway.mean_control.accuracy.result{k1,k2}	= resPy.(pykey('mean_twoway_accuracy',[kM k1 k2]));
										
										if bDoBalancer
											res{kM}.twoway.mean_control.accuracy.result{k1,k2}	= mean(reshape(res{kM}.twoway.mean_control.accuracy.result{k1,k2},opt.balancer_count,[]),1)';
										end
										
										res{kM}.twoway.mean_control.accuracy.result{k2,k1}	= res{kM}.twoway.mean_control.accuracy.result{k1,k2};
									end
									
									if opt.sensitivities
										res{kM}.twoway.sensitivity.result{k1,k2}	= resPy.(pykey('twoway_sensitivity',[kM k1 k2]));
										res{kM}.twoway.sensitivity.result{k2,k1}	= res{kM}.twoway.sensitivity.result{k1,k2};
									end
									
									if opt.save_selected
										if bMaskBalancer
											res{kM}.twoway.selected.path{k1,k2}	= arrayfun(@(kb) resPy.(pykey('selected_twoway',[k1 k2 kM kb])),(1:opt.mask_balancer_count)','UniformOutput',false);
										else
											res{kM}.twoway.selected.path{k1,k2}	= resPy.(pykey('selected_twoway',[k1 k2 kM]));
										end
										
										res{kM}.twoway.selected.path{k2,k1}	= res{kM}.twoway.selected.path{k1,k2};
									end
								end
							end
							
							res{kM}.twoway.accuracy.stats		= AccuracyStats(res{kM}.twoway.accuracy.result,0.5);
							
							if opt.permutation_test
								res{kM}.twoway.accuracy.stats.permutation_p	= NaN(nTarget,nTarget)
								
								for k1=1:nTarget
									for k2=1:nTarget
										res{kM}.twoway.accuracy.stats.permutation_p(k1,k2)	= resPy.(pykey('twoway_pvalue',[kM k1 k2]));
										res{kM}.twoway.accuracy.stats.permutation_p(k2,k1)	= res{kM}.twoway.accuracy.stats.permutation_p(k1,k2);
									end
								end
							end
							
							if opt.mean_control && opt.permutation_test
								res{kM}.twoway.mean_control.accuracy.stats.permutation_p	= NaN(nTarget,nTarget)
								
								for k1=1:nTarget
									for k2=1:nTarget
										res{kM}.twoway.mean_control.accuracy.stats.permutation_p(k1,k2)	= resPy.(pykey('mean_twoway_pvalue',[kM k1 k2]));
										res{kM}.twoway.mean_control.accuracy.stats.permutation_p(k2,k1)	= res{kM}.twoway.mean_control.accuracy.stats.permutation_p(k1,k2);
									end
								end
							end
							
							if opt.sensitivities
								res{kM}.twoway.sensitivity.stats	= SensitivityStats(res{kM}.twoway.sensitivity.result);
							end
						end
					end
				
				res	= cat(1,res{:});
			else
				error(['python script error (' strPathScript ')']);
			end
			
			%save the results
				save(strPathResult,'res');
		else
			res	= struct;
		end
	
	%delete the temporary files
		if ~bSaveScript
			delete(strPathAttr);
			delete(strPathScript);
			delete(strPathResult);
		end
else
%load the results
	load(strPathResult);
end

%------------------------------------------------------------------------------%
function strBool = pybool(b)
	strBool = conditional(b,'True','False');
end
%------------------------------------------------------------------------------%
function strKey = pykey(strName,idx)
	strKey	= join([strName; reshape(arrayfun(@(x) num2str(x-1),idx,'UniformOutput',false),[],1)],'_');
end
%------------------------------------------------------------------------------%
function stats = AccuracyStats(res,fChance)
	res	= ForceCell(res);
	
	stats.mean	= cellfun(@mean,res);
	stats.se	= cellfun(@(x) unless(stderr(x),NaN),res);
	
	bStat	= ~cellfun(@isempty,res);
	
	n	= cellfun(@numel,res);
	
	%one-tailed binomial test
		if ~opt.permutation_test
			stats.bino_p	= NaN(size(res));
			
			s	= round(stats.mean.*n);
			
			stats.bino_p(bStat)	= 1 - binocdf(s(bStat)-1,n(bStat),fChance);
		end
	%chi-squared goodness of fit test
		if ~opt.permutation_test
			warning('off','stats:chi2gof:LowCounts');
			
			[stats.chi2_p,stats.chi2_stat,stats.chi2_df]	= deal(NaN(size(res)));
			
			nExpected	= arrayfun(@(x) x*[1-fChance fChance],n,'UniformOutput',false);
			[h,p,stat]	= cellfun(@(x,e) chi2gof(x,'ctrs',[0 1],'expected',e),res(bStat),nExpected(bStat),'UniformOutput',false);
			
			stats.chi2_p(bStat)		= cell2mat(p);
			stats.chi2_stat(bStat)	= cellfun(@(s) s.chi2stat,stat);
			stats.chi2_df(bStat)	= cellfun(@(s) s.df,stat);
		end
end
%------------------------------------------------------------------------------%
function stats = SensitivityStats(res)
	res	= ForceCell(res);
	
	%calculate the mean
		stats.mean	= cellfun(@(x) reshape(mean(x),1,1,[]),res,'UniformOutput',false);
		
		if numel(res)>1
			nRes				= size(res,1);
			kDiag				= sub2ind([nRes nRes],1:nRes,1:nRes);
			stats.mean(kDiag)	= {NaN(size(stats.mean{1,2}))};
		end
		
		stats.mean	= cell2mat(stats.mean);
	
	stats.n		= cellfun(@(x) size(x,1),res);
	
	if opt.sensitivity_stats
	%this method isn't valid otherwise (probaby isn't valid any way)
	%correct for artificially low variance, like jackknife (i think)
		bBlank		= cellfun(@isempty,res);
		res(bBlank)	= {NaN(size(res{find(~bBlank,1)}))};
		
		
		
		se	= cell2mat(cellfun(@(x) reshape(stderr(x),1,1,[]),res,'UniformOutput',false));
		df	= repto(stats.n-1,size(se));
		
		stats.se	= df.*se;
		stats.t		= stats.mean./stats.se;
		stats.p		= arrayfun(@t2p,stats.t,df);
	end
	
	%squeeze
		stats	= structfun2(@squeeze,stats);
end
%------------------------------------------------------------------------------%

end
