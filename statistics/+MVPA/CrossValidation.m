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
%		partitioner:		(1) the partitioner to use. one of the following:
%								n: perform leave-n-out cross validation
%		classifier:			('svm') the classifier to ues. one of the following:
%								'svm': use a support vector machine classifier
%		zscore:				('chunk') how to z-score the data before
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
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results
% 
% Updated: 2015-05-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
res	= struct;

%parse the inputs
	opt	= ParseArgs(varargin,...
			'partitioner'		, 1			, ...
			'classifier'		, 'svm'		, ...
			'zscore'			, 'chunk'	, ...
			'target_balancer'	, 10		, ...
			'average'			, false		, ...
			'silent'			, false		  ...
			);
	
	assert(isscalar(opt.partitioner),'partitioner option must be a scalar');
	
	opt.classifier	= CheckInput(opt.classifier,'classifier',{'svm'});
	
	bZscore	= true;
	switch class(opt.zscore)
		case 'char'
			opt.zscore	= CheckInput(opt.zscore,'zscore',{'chunks'});
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

%get the classifier
	switch opt.classifier
		case 'svm'
			fTrain	= @CVTrainSVM;
			fTest	= @CVTestSVM;
	end

%partition the data
	[kTrain,kTest]	= MVPA.LeaveNOutPartitioner(nChunk,opt.partitioner);
	nFold			= size(kTrain,1);

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
		[acc,kTarget,kPredict]	= CVFold(kTrain(kF,:),kTest(kF,:),opt.target_balancer);
		
		%mean accuracy for this fold
			res.accuracy(kF)	= mean(acc);
		
		%update the confusions
			kConfusion					= sub2ind([nTarget nTarget],kTarget,kPredict);
			kConfusionU					= unique(kConfusion);
			nAdd						= arrayfun(@(kc) sum(kConfusion==kc),kConfusionU);
			res.confusion(kConfusionU)	= res.confusion(kConfusionU) + nAdd;
		
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
		sTrain	= fTrain(d(kSampleTrain,:),kTargetTrain);
		
		kTarget		= reshape(kTargetTest,[],1);
		kPredict	= fTest(d(kSampleTest,:),sTrain);
		
		acc	= kTarget==kPredict;
	end
end
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function sTrain = CVTrainSVM(d,kTarget)
	sTrain	= svmtrain(d,kTarget);
end
%------------------------------------------------------------------------------%
function kPredict = CVTestSVM(d,sTrain)
	kPredict	= svmclassify(sTrain,d);
end
%------------------------------------------------------------------------------%

end
