function res = CrossValidation(d,cTarget,kChunk,varargin)
% MVPA.CrossValidation
% 
% Description:	perform an MVPA classification cross-validation
% 
% Syntax:	res = CrossValidation(data,cTarget,kChunk,<options>)
% 
% In:
% 	d		- an nSample x nFeature array of data
%	cTarget	- an nSample x 1 array of the target for each sample
%	kChunk	- an nSample x 1 integer array of the chunk for each sample. chunks
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
%								false:		don't z-score
%		target_balancer:	(10) the number of target balancing folds to use.
%							i.e. if targets are unbalanced, each fold of the
%							cross-validation will perform this number of
%							training/testing iterations with balanced subsets of
%							the training set used for training.
%		average:			(false) true to average samples with the same target
%							and chunk before classifying
%		error:				(true) true to fail if an error occurs
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results
% 
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
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
			'error'				, true		, ...
			'silent'			, false		  ...
			);
	
	assert(isscalar(opt.partitioner),'partitioner option must be a scalar');
	
	bZscore	= true;
	switch class(opt.zscore)
		case 'char'
			opt.zscore	= CheckInput(opt.zscore,'zscore',{'chunk'});
		otherwise
			assert(~notfalse(opt.zscore),'zscore option must be a string or false');
			bZscore	= false;
	end
	
	if ~iscell(cTarget)
		cTarget	= num2cell(cTarget);
	end
	res.target			= reshape(cellfun(@tostring,cTarget,'uni',false),[],1);
	res.uniquetargets	= unique(res.target);
	nTarget				= numel(res.uniquetargets);
	
	res.chunk			= reshape(kChunk,[],1);
	res.uniquechunks	= unique(res.chunk);
	nChunk				= numel(res.uniquechunks);
	
	[res.samples,res.features]	= size(d);

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

%z-score the data
	if bZscore
		switch opt.zscore
			case 'chunks'
				for kC=1:nChunk
					bSample			= res.chunk==res.uniquechunks(kC);
					d(bSample,:)	= zscore(d(bSample,:),[],1);
				end
		end
	end
	
%average the data
	if opt.average
		cTargetNew	= reshape(repmat(res.uniquetargets,[1 nChunk]),[],1);
		kChunkNew	= reshape(repmat(reshape(res.uniquechunks,1,[]),[nTarget 1]),[],1);
		nSampleNew	= numel(cTargetNew);
		dNew		= NaN(nSampleNew,nFeature);
		
		bUse	= false(nSampleNew,1);
		
		for kS=1:nSampleNew
			target	= cTargetNew{kS};
			chunk	= kChunkNew(kS);
			
			bAverage	= strcmp(res.target,target) & res.chunk==chunk;
			bUse(kS)	= any(bAverage);
			
			if bUse(kS)
				dNew(kS,:)	= mean(d(bAverage,:),1);
			end
		end
		
		res.target	= cTargetNew(bUse);
		res.chunk	= kChunkNew(bUse);
		d			= dNew(bUse,:);
		res.samples	= size(d,1);
	end

%partition the data
	[kTrain,kTest]	= prt.Partition(nChunk);
	nFold			= numel(kTrain);

%perform the cross validation
	%temporarily convert targets to integers
		cTarget			= res.target;
		[b,res.target]	= ismember(res.target,res.uniquetargets);
	
	res.accuracy	= NaN(nFold,1);
	res.confusion	= zeros(nTarget);
	
	progress('action','init',...
		'total'		, nFold											, ...
		'label'		, 'performing classification cross-validation'	, ...
		'silent'	, opt.silent									  ...
		);
	for kF=1:nFold
		try
			[acc,kTarget,kPredict]	= CVFold(kTrain{kF},kTest{kF},opt.target_balancer);
			
			%mean accuracy for this fold
				res.accuracy(kF)	= mean(acc);
			
			%update the confusions
				kConfusion					= sub2ind([nTarget nTarget],kTarget,kPredict);
				kConfusionU					= unique(kConfusion);
				nAdd						= arrayfun(@(kc) sum(kConfusion==kc),kConfusionU);
				res.confusion(kConfusionU)	= res.confusion(kConfusionU) + nAdd;
		catch me
			if opt.error
				rethrow(me);
			else
				res.error	= me;
				warning('Cross-validation failed (%s): %s',opt.name,me.message);
				progress('action','end');
				break;
			end
		end
		
		progress;
	end
	
	%restore the target labels
		res.target	= cTarget;
	
	%some basic stats
		res.mean	= mean(res.accuracy);
		res.se		= stderr(res.accuracy);

%------------------------------------------------------------------------------%
function [acc,kTarget,kPredict] = CVFold(kTrainFold,kTestFold,targetBalance)
% perform one cross-validation fold
	%chunks in each partition
		kChunkTrain	= res.uniquechunks(kTrainFold);
		kChunkTest	= res.uniquechunks(kTestFold);
	
	%samples in each partition
		kSampleTrain	= find(ismember(res.chunk,kChunkTrain));
		kSampleTest		= find(ismember(res.chunk,kChunkTest));
	
	%targets of each sample
		kTargetTrain	= res.target(kSampleTrain);
		kTargetTest		= res.target(kSampleTest);
	
	%check for and perform target balancing
		bDoTargetBalance	= false;
		if notfalse(targetBalance)
			%do we have the same number of samples for each target?
				kTargetTrainU		= unique(kTargetTrain);
				cKSampleTarget		= arrayfun(@(kt) kSampleTrain(kTargetTrain==kt),kTargetTrainU,'uni',false);
				nPerTarget			= cellfun(@numel,cKSampleTarget);
				bDoTargetBalance	= ~uniform(nPerTarget);
			
			if bDoTargetBalance
				nBalanced	= min(nPerTarget);
				
				[acc,kTarget,kPredict]	= deal(cell(targetBalance,1));
				for kB=1:targetBalance
					%choose a random balanced subset of training samples
						cKTrainBalanced	= cellfun(@(k) randFrom(k,[nBalanced 1]),cKSampleTarget,'uni',false);
						kTrainBalanced	= cat(1,cKTrainBalanced{:});
						
						[acc{kB},kTarget{kB},kPredict{kB}]	= CVFold(kTrainBalanced,kTestFold,false);
				end
				
				[acc,kTarget,kPredict]	= varfun(@(x) cat(1,x{:}),acc,kTarget,kPredict);
			end
		end
	
	if ~bDoTargetBalance
		cls.Train(d(kSampleTrain,:),kTargetTrain);
		
		kTarget		= reshape(kTargetTest,[],1);
		kPredict	= cls.Predict(d(kSampleTest,:));
		
		acc	= kTarget==kPredict;
	end
end
%------------------------------------------------------------------------------%

end
