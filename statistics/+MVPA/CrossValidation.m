function res = CrossValidation(d,target,chunk,varargin)
% MVPA.CrossValidation
% 
% Description:	perform an MVPA classification cross-validation
% 
% Syntax:	res = CrossValidation(d,target,chunk,<options>)
% 
% In:
% 	d		- an nSample x nFeature array of data
%	target	- an nSample x 1 array of the target for each sample
%	chunk	- an nSample x 1 integer array of the chunk for each sample. chunks
%			  with value 0 are excluded from the analysis.
%	<options>:
%		name:				('') an optional name for the cross-validation
%		partitioner:		(1) the partitioner to use. one of the following:
%								n:		perform leave-n-out cross validation
%								str:	the name of a valid partitioner class
%										in MVPA.Partitioner, to use that
%										partitioner with the default parameters
%								prt:	an MVPA.Partitioner.* object
%		classifier:			('SVM') the classifier to use. one of the following:
%								str:	the name of a valid classifier class in
%										MVPA.Classifier, to use that classifier
%										with the default parameters
%								cls:	an MVPA.Classifier.* object
%		zscore:				(false) how to z-score the data before
%							classification. one of the following:
%								'chunk':	z-score by chunk
%								'sample':	z-score each sample
%								'feature':	z-score each feature
%								'data':		z-score the entire dataset
%								false:		don't z-score
%		target_balancer:	(10) the number of target balancing folds to use.
%							i.e. if targets are unbalanced, each fold of the
%							cross-validation will perform this number of
%							training/testing iterations with balanced subsets of
%							the training set used for training.
%		average:			(false) true to average samples with the same target
%							and chunk before classifying
%		seed:				(randseed2) the seed to use for randomizing, or
%							false to skip seeding the random number generator
%		error:				(true) true to fail if an error occurs
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results
% 
% Updated: 2016-02-02
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
res	= struct('error',false);

%parse the inputs
	opt	= ParseArgs(varargin,...
			'name'				, ''		, ...
			'partitioner'		, 1			, ...
			'classifier'		, 'SVM'		, ...
			'zscore'			, false		, ...
			'target_balancer'	, 10		, ...
			'average'			, false		, ...
			'seed'				, []		, ...
			'error'				, true		, ...
			'silent'			, false		  ...
			);
	
	assert(isscalar(opt.partitioner),'partitioner option must be a scalar');
	
	%should we z-score?
		bZscore	= true;
		switch class(opt.zscore)
			case 'char'
				opt.zscore	= CheckInput(opt.zscore,'zscore',{'chunk','sample','feature','data'});
			otherwise
				assert(~notfalse(opt.zscore),'zscore option must be a string or false');
				bZscore	= false;
		end
	
	%format the targets
		if ~iscell(target)
			target	= num2cell(target);
		end
		res.target			= reshape(cellfun(@tostring,target,'uni',false),[],1);
		res.uniquetargets	= unique(res.target);
		nTarget				= numel(res.uniquetargets);
	
	%format the chunks
		res.chunk			= reshape(chunk,[],1);
		
		%eliminate zero-chunk samples from the data
			bChunkDiscard				= res.chunk==0;
			
			res.chunk(bChunkDiscard)	= [];
			d(bChunkDiscard,:)			= [];
		
		res.uniquechunks	= unique(res.chunk);
		nChunk				= numel(res.uniquechunks);
	
	if isempty(opt.seed)
		opt.seed	= randseed2;
	end
	
	[res.num_sample,res.num_feature]	= size(d);

%seed the random number generator
	if notfalse(opt.seed)
		rng(opt.seed,'twister');
	end

%get the partitioner
	if isa(opt.partitioner,'MVPA.Partitioner.Base')
		prt	= opt.partitioner;
	elseif ischar(opt.partitioner)
		try
			prt	= MVPA.Partitioner.(opt.partitioner);
		catch me
			error('%s is not a valid partitioner class',opt.partitioner);
		end
	elseif isscalar(opt.partitioner)
		prt	= MVPA.Partitioner.LeaveNOut('n',opt.partitioner);
	else
		error('invalid partitioner');
	end

%get the classifier
	if isa(opt.classifier,'MVPA.Classifier.Base')
		cls	= opt.classifier;
	elseif ischar(opt.classifier)
		try
			cls	= MVPA.Classifier.(opt.classifier);
		catch me
			error('%s is not a valid classifier class',opt.classifier);
		end
	else
		error('invalid classifier');
	end

%store the input parameters
	res.param	= rmfield(opt,{'error','silent','isoptstruct','opt_extra'});
	
	res.param.partitioner	= prt.option;
	res.param.classifier	= cls.option;

%z-score the data
	if bZscore
		switch opt.zscore
			case 'chunk'
				for kC=1:nChunk
					bSample			= res.chunk==res.uniquechunks(kC);
					d(bSample,:)	= zscore(d(bSample,:),[],1);
				end
			case 'sample'
				d	= zscore(d,[],2);
			case 'feature'
				d	= zscore(d,[],1);
			case 'data'
				d(:)	= zscore(d(:));
		end
	end
	
%average the data
	if opt.average
		dAvg	= NaN(nTarget,nChunk,res.num_feature);
		bUse	= false(nTarget,nChunk);
		
		for kT=1:nTarget
			bTarget	= strcmp(res.target,res.uniquetargets{kT});
			
			for kC=1:nChunk
				bChunk	= res.chunk==res.uniquechunks(kC);
				
				bAvg	= bTarget & bChunk;
				
				bUse(kT,kC)	= any(bAvg);
				
				if bUse(kT,kC)
					dAvg(kT,kC,:)	= mean(d(bAvg,:),1);
				end
			end
		end
		
		[kTargetUse,kChunkUse]	= find(bUse);
		kSampleUse				= sub2ind([nTarget nChunk],kTargetUse,kChunkUse);
		
		res.target	= res.uniquetargets(kTargetUse);
		res.chunk	= res.uniquechunks(kChunkUse);
		
		d	= reshape(dAvg,nTarget*nChunk,res.num_feature);
		d	= d(kSampleUse,:);
		
		res.num_sample	= size(d,1);
	end

%partition the data
	[cKChunkTrain,cKChunkTest]	= prt.Partition(nChunk);
	nFold						= numel(cKChunkTrain);

%perform the cross validation
	%convert targets and chunks to indices
		[b,kTargetSample]	= ismember(res.target,res.uniquetargets);
		[b,kChunkSample]	= ismember(res.chunk,res.uniquechunks);
	
	res.accuracy	= NaN(nFold,1);
	res.confusion	= zeros(nTarget);
	
	if ~opt.silent
		progress('action','init',...
			'total'		, nFold											, ...
			'label'		, 'performing classification cross-validation'	, ...
			'silent'	, opt.silent									  ...
			);
	end
	
	for kF=1:nFold
		if opt.error
			[acc,conf]	= CVFold(cKChunkTrain{kF},cKChunkTest{kF});
			
			%mean accuracy for this fold
				res.accuracy(kF)	= mean(acc);
			
			%update the confusion matrix
				res.confusion	= res.confusion + conf;
		else
			try
				[acc,conf]	= CVFold(cKChunkTrain{kF},cKChunkTest{kF});
			
				%mean accuracy for this fold
					res.accuracy(kF)	= mean(acc);
				
				%update the confusion matrix
					res.confusion	= res.confusion + conf;
			catch me
				res.error	= me;
				warning('Cross-validation failed (%s): %s',opt.name,me.message);
				
				if ~opt.silent
					progress('action','end');
				end
				
				break;
			end
		end
		
		if ~opt.silent
			progress;
		end
	end
	
	%some basic stats
		res.mean	= mean(res.accuracy);
		res.se		= stderr(res.accuracy);

%------------------------------------------------------------------------------%
function [acc,conf] = CVFold(kChunkTrain,kChunkTest)
% perform one cross-validation fold
	%samples in each partition
		kSampleTrain	= find(ismember(kChunkSample,kChunkTrain));
		kSampleTest		= find(ismember(kChunkSample,kChunkTest));
	
	%targets of each sample
		kTargetTrain	= kTargetSample(kSampleTrain);
		kTargetTest		= kTargetSample(kSampleTest);
	
	%check for target balancing
		if notfalse(opt.target_balancer)
			%do we have the same number of samples for each target?
				kTargetTrainU		= unique(kTargetTrain);
				cKSampleTarget		= arrayfun(@(kt) kSampleTrain(kTargetTrain==kt),kTargetTrainU,'uni',false);
				nPerTarget			= cellfun(@numel,cKSampleTarget);
				bDoTargetBalance	= ~uniform(nPerTarget);
			
			if bDoTargetBalance
				nBalanced		= min(nPerTarget);
				
				[kSampleTrain,kTargetTrain]	= deal(cell(opt.target_balancer,1));
				for kB=1:opt.target_balancer
					cKSampleTrainBalanced	= cellfun(@(ks) RandomSubset(ks,nBalanced),cKSampleTarget,'uni',false);
					kSampleTrain{kB}		= cat(1,cKSampleTrainBalanced{:});
					kTargetTrain{kB}		= kTargetSample(kSampleTrain{kB});
				end
			else
				kSampleTrain	= {kSampleTrain};
				kTargetTrain	= {kTargetTrain};
			end
		else
			kSampleTrain	= {kSampleTrain};
			kTargetTrain	= {kTargetTrain};
		end
	
	%train and test for each subfold
		nSubFold	= numel(kSampleTrain);
		
		[kTargetFold,kPredictFold]	= deal(cell(nSubFold,1));
		for kSF=1:nSubFold
			cls.Train(d(kSampleTrain{kSF},:),kTargetTrain{kSF});
			
			kTargetFold{kSF}	= kTargetTest;
			kPredictFold{kSF}	= cls.Predict(d(kSampleTest,:));
		end
	
	%combine the subfolds
		kTargetFold		= cat(1,kTargetFold{:});
		kPredictFold	= cat(1,kPredictFold{:});
	
	%accuracy for the fold
		acc	= kTargetFold==kPredictFold;
	
	%confusion matrix for the fold
		kConfusion	= sub2ind([nTarget nTarget],kTargetFold,kPredictFold);
		kConfusionU	= unique(kConfusion);
		
		conf				= zeros(nTarget);
		conf(kConfusionU)	= arrayfun(@(kc) sum(kConfusion==kc),kConfusionU);
end
%------------------------------------------------------------------------------%
function xSub = RandomSubset(x,n)
	nX				= numel(x);
	[dummy,kRandom]	= sort(rand(nX,1));
	xSub			= x(kRandom(1:n));
end
%------------------------------------------------------------------------------%

end
