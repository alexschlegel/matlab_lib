% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
%
% This class is a reworking of Alex's script 20150116_alex_tests.m
% and now incorporates the changes from 20150123_alex_tests.m
% --------------------------------------------------------------------

classdef Pipeline

%cuts/pastes/modifications of Bennet's pipeline. trying to understand the
%pipeline as a whole better, and a big long string of code works better for me
%for that purpose.

%here we will generate two W causality matrices, generate fMRI data for two
%ROIS (X and Y) that represent a block design in which the two conditions (A
%and B) differ only in the pattern of directed connectivity from X to Y.  Can we
%classify between the two conditions based on the recovered pattern of
%connectivity from X to Y?


% Simplest invocation (as of 2015-02-03):  Pipeline.debugSimulation;
% use "Pipeline.runSimulation" to randomize behavior and suppress
% diagnostic output.  Other parameterless invocations (added later):
%	quickest, no graphics:		Pipeline.speedupDebugSimulation
%	no graphics, but not quick:	Pipeline.textOnlyDebugSimulation
%

properties
	uopt
end
properties (SetAccess = private)
	analyses			= {'alex','lizier','seth'}
	explicitOptionNames
	infodyn_teCalc
end

methods
	% Pipeline - constructor for Pipeline class
	%
	% Syntax:	pipeline = Pipeline(<options>)
	%
	% In:
	%	<options>:
	%					-- Debugging/diagnostic options:
	%
	%		DEBUG:		(false) Display debugging information
	%		fudge:		({}) Fudge specified details (e.g., {'fakecause'})
	%		nofigures:	(false) Suppress figures
	%		nowarnings:	(false) Suppress warnings
	%		progress:	(true) Show progress
	%		seed:		(randseed2) Seed to use for randomizing
	%		szIm:		(200) Pixel height of debug images
	%		verbosity:	(1) Extra diagnostic output level (0=none, 10=most)
	%
	%					-- Subjects
	%
	%		nSubject:	(20) number of subjects
	%
	%					-- Size of the various spaces:
	%
	%		nSig:		(10) total number of functional signals
	%		nSigCause:	(10) number of functional signals of X that cause Y
	%		nVoxel:		(100) number of voxels into which the functional components are mixed
	%
	%					-- Time:
	%
	%		nTBlock:	(1) number of time points per block
	%		nTRest:		(4) number of time points per rest periods
	%		nRepBlock:	(20) number of repetitions of each block per run
	%		nRun:		(10) number of runs
	%
	%					-- Signal characteristics:
	%
	%		CRecurX:	(0.1) recurrence coefficient (should be <= 1)
	%		CRecurY:	(0.7) recurrence coefficient (should be <= 1)
	%		CRecurZ:	(0.5) recurrence coefficient (should be <= 1)
	%		normVar:	(false) normalize signal variances (approximately)
	%		WFullness:	(0.1) fullness of W matrices
	%		WSmooth:	(false) omit W fullness filter, instead using WFullness for "pseudo-sparsity"
	%		WSquash:	(false) flip the W fullness filter, making nonzero elements nearly equal
	%		WSum:		(0.2) sum of W columns (sum(W)+CRecurY/X must be <=1)
	%		WSumTweak:	(false) use altered recurrence with tweaked W column sums
	%		xCausAlpha:	([]) inter-region causal weight (empty, or 0 <= alpha <= 1)
	%
	%					-- Mixing
	%
	%		doMixing:	(true) should we even mix into voxels?
	%		noiseMix:	(0.1) magnitude of noise introduced in the voxel mixing
	%
	%					-- Analysis
	%
	%		analysis:	('total') analysis mode:  'alex', 'lizier', 'seth', or 'total'
	%		kraskov_k:	(4) Kraskov K for Lizier's multivariate transfer entropy calculation
	%		loadJavaTE:	(false) Load Lizier's infodynamics JAR for calculating TE
	%		max_aclags:	(1000) GrangerCausality parameter to limit running time
	%		WStarKind:	('gc') what kind of causality to use in W* computations ('gc', 'mvgc', 'te')
	%
	%					-- Batch processing
	%
	%		max_cores:	(1) Maximum number of cores to request for multitasking
	%		saveplot:	(true) Save individual plot capsules to mat files on generation
	%
	function obj = Pipeline(varargin)
		%user-defined parameters (with defaults)
		opt	= ParseArgs(varargin,...
			'DEBUG'			, false		, ...
			'fudge'			, {}		, ...
			'nofigures'		, false		, ...
			'nowarnings'	, false		, ...
			'progress'		, true		, ...
			'seed'			, randseed2	, ...
			'szIm'			, 200		, ...
			'verbosity'		, 1			, ...
			'nSubject'		, 20		, ...
			'nSig'			, 10		, ...
			'nSigCause'		, 10		, ...
			'nVoxel'		, 100		, ...
			'nTBlock'		, 1			, ...
			'nTRest'		, 4			, ...
			'nRepBlock'		, 20		, ...
			'nRun'			, 10		, ...
			'CRecurX'		, 0.1		, ...
			'CRecurY'		, 0.7		, ...
			'CRecurZ'		, 0.5		, ...
			'normVar'		, false		, ...
			'WFullness'		, 0.1		, ...
			'WSmooth'		, false		, ...
			'WSquash'		, false		, ...
			'WSum'			, 0.2		, ...
			'WSumTweak'		, false		, ...
			'xCausAlpha'	, []		, ...
			'doMixing'		, true		, ...
			'noiseMix'		, 0.1		, ...
			'analysis'		, 'total'	, ...
			'kraskov_k'		, 4			, ...
			'loadJavaTE'	, false		, ...
			'max_aclags'	, 1000		, ...
			'WStarKind'		, 'gc'		, ...
			'max_cores'		, 1			, ...
			'saveplot'		, true		  ...
			);
		if isfield(opt,'opt_extra') && isstruct(opt.opt_extra)
			extraOpts	= opt2cell(opt.opt_extra);
			if numel(extraOpts) > 0
				error('Unrecognized option ''%s''',extraOpts{1});
			end
		end
		invalidFudges			= ~ismember(opt.fudge,{'fakecause'});
		if any(invalidFudges)
			error('Invalid fudge(s):%s',sprintf(' ''%s''',opt.fudge{invalidFudges}));
		end
		opt.analysis			= CheckInput(opt.analysis,'analysis',[obj.analyses 'total']);
		opt.WStarKind			= CheckInput(opt.WStarKind,'WStarKind',{'gc','mvgc','te'});
		obj.uopt				= opt;
		obj.explicitOptionNames	= varargin(1:2:end);
		if isempty(obj.infodyn_teCalc) && opt.loadJavaTE
			try
				obj.infodyn_teCalc	= javaObject('infodynamics.measures.continuous.kraskov.TransferEntropyCalculatorMultiVariateKraskov');
			catch err
				fprintf('Warning:  Instantiation of infodynamics TE calculator raised error:\n');
				disp(err);
			end
		end
	end

	function subjectStats = analyzeTestSignals(obj,block,target,XTest,YTest,doDebug)
		u		= obj.uopt;

		modeInds	= cellfun(@(m) any(strcmp(u.analysis,{m,'total'})),obj.analyses);
		modes		= obj.analyses(modeInds);
		for kMode=1:numel(modes)
			switch modes{kMode}
				case 'alex'
					subjectStats.alexAccSubj	= analyzeTestSignalsModeAlex(obj,block,target,XTest,YTest,doDebug);
				case 'lizier'
					subjectStats.lizierTEs		= analyzeTestSignalsMultivariate(obj,block,target,XTest,YTest,'te',doDebug);
				case 'seth'
					subjectStats.sethGCs		= analyzeTestSignalsMultivariate(obj,block,target,XTest,YTest,'mvgc',doDebug);
				otherwise
					error('Bug: missing case for %s.',modes{kMode});
			end
		end
	end

	function alexAccSubj = analyzeTestSignalsModeAlex(obj,~,target,XTest,YTest,doDebug)
		u		= obj.uopt;

		if u.doMixing
			%unmix and keep the top nSigCause components
			nTRun	= numel(target{1});	%number of time points per run
			nT		= nTRun*u.nRun;		%total number of time points

			[~,XUnMix]	= pca(reshape(XTest,nT,u.nVoxel));
			XUnMix		= reshape(XUnMix,nTRun,u.nRun,u.nVoxel);

			[~,YUnMix]	= pca(reshape(YTest,nT,u.nVoxel));
			YUnMix		= reshape(YUnMix,nTRun,u.nRun,u.nVoxel);
		else
			[XUnMix,YUnMix]	= deal(XTest,YTest);
		end

		XUnMix	= XUnMix(:,:,1:u.nSigCause);
		YUnMix	= YUnMix(:,:,1:u.nSigCause);

		%calculate W*
		%calculate the Granger Causality from X components to Y components for each
		%run and condition
		WAs = calculateW_stars(obj,target,XUnMix,YUnMix,'A');
		WBs = calculateW_stars(obj,target,XUnMix,YUnMix,'B');

		%classify between W*A and W*B
		[alexAccSubj,p_binom] = classifyBetweenWs(obj,WAs,WBs);

		if doDebug
			mWAs	= mean(cat(3,WAs{:}),3);
			mWBs	= mean(cat(3,WBs{:}),3);

			showTwoWs(obj,mWAs,mWBs,'W^*_A and W^*_B');
			fprintf('mean W*A column sums:  %s\n',sprintf('%.3f ',sum(mWAs)));
			fprintf('mean W*B column sums:  %s\n',sprintf('%.3f ',sum(mWBs)));
			fprintf('accuracy: %.2f%%\n',100*alexAccSubj);
			fprintf('p(binom): %.3f\n',p_binom);
		end
	end

	%X,Y dims are time, run, signal
	%kind is causality kind ('mvgc', 'te')
	%return one causality for each condition
	function causalities = analyzeTestSignalsMultivariate(obj,~,target,X,Y,kind,doDebug)
		u			= obj.uopt;
		conds		= {'A' 'B'};
		causalities	= zeros(numel(conds),1);

		%concatenate data for all runs to create a single hypothetical megarun
		megatarget	= {cat(1,target{:})};
		megaX		= reshape(X,[],1,size(X,3));
		megaY		= reshape(Y,[],1,size(Y,3));

		for kC=1:numel(conds)
			sigs			= extractSignalsForCondition(obj,...
								megatarget,megaX,megaY,conds{kC});
			s				= sigs{1};
			causalities(kC)	= calculateCausality(obj,...
								squeeze(s.Xall),squeeze(s.Yall),...
								s.kNext,kind);
			reportResult	= (u.verbosity >= 5);
			if reportResult && strcmp(kind,'mvgc')
				%TODO: possibly temporary GC diagnostic
				mvgc		= causalities(kC);
				fprintf('Multivariate GC X->Y for cond %s is %g\n',conds{kC},mvgc);
			end
			if reportResult && strcmp(kind,'te')
				%TODO: possibly temporary TE verification
				aX			= squeeze(s.XFudge);
				aY			= squeeze(s.YFudge);
				aTE1		= calculateCausality(obj,aX,aY,...
								2:size(aX,1),'te');
				%FIXME: redundant, alternate computation
				aTE1		= TransferEntropy(aX,aY,...
								'kraskov_k', u.kraskov_k);
				aTE2		= calculateLizierMVCTE(obj,aX,aY);
				fprintf('Multivariate TEs X->Y for cond %s are %.6f, %.6f\n',...
					conds{kC},aTE1,aTE2);
				if abs(aTE1 - aTE2) > 1e-8
					error('Bug in TE calculation.');
				end
			end
		end
		if doDebug
			fprintf('\n%ss =\n\n',upper(kind));
			disp(causalities);
		end
	end

	function [sourceOut,destOut,preSourceOut] = applyRecurrence(obj,sW,sourceIn,destIn,preSourceIn,doDebug)
		if isfield(sW,'WXX')
			[sourceOut,destOut,preSourceOut] = applyRecurrenceRegionStyle(obj,sW,sourceIn,destIn,preSourceIn,doDebug);
		else
			[sourceOut,destOut,preSourceOut] = applyRecurrenceLizierStyle(obj,sW,sourceIn,destIn,preSourceIn,doDebug);
		end
	end

	function [sourceOut,destOut,preSourceOut] = applyRecurrenceLizierStyle(obj,sW,sourceIn,destIn,preSourceIn,doDebug)
		u	= obj.uopt;
		W	= sW.W;
		WZ	= sW.WZ;

		if u.WSumTweak
			if u.normVar ~= 0
				error('Combination WSumTweak and normVar not supported.');
			end
			tweakedWSum		= u.WSum/sqrt(u.nSigCause);
			sourceOut		= u.CRecurX.*sourceIn + sum(WZ'.*preSourceIn,2) + (1-tweakedWSum-u.CRecurX).*randn(u.nSig,1);
			destOut			= u.CRecurY.*destIn + W'*sourceIn + (1-tweakedWSum-u.CRecurY).*randn(u.nSig,1);
			preSourceOut	= u.CRecurZ.*preSourceIn + (1-u.CRecurZ).*randn(u.nSig,u.nSig);
		else
			switch u.normVar
				case 0
					sourceOut		= u.CRecurX.*sourceIn + sum(WZ'.*preSourceIn,2) + (1-sum(WZ,1)'-u.CRecurX).*randn(u.nSig,1);
					destOut			= u.CRecurY.*destIn + W'*sourceIn + (1-sum(W,1)'-u.CRecurY).*randn(u.nSig,1);
					preSourceOut	= u.CRecurZ.*preSourceIn + (1-u.CRecurZ).*randn(u.nSig,u.nSig);
				case 1
					sourceOut		= applyVarianceNormalizationToWeightedSum(obj,...
										{u.CRecurX,sourceIn},...
										{WZ',preSourceIn},...
										{1-sum(WZ,1)'-u.CRecurX,randn(u.nSig,1)});
					destOut			= applyVarianceNormalizationToWeightedSum(obj,...
										{u.CRecurY,destIn},...
										{W',sourceIn},...
										{1-sum(W,1)'-u.CRecurY,randn(u.nSig,1)});
					preSourceOut	= applyVarianceNormalizationToWeightedSum(obj,...
										{u.CRecurZ,preSourceIn},...
										{1-u.CRecurZ,randn(u.nSig,u.nSig)});
				case 2  % Alternative approach to variance normalization (TODO: remove?)
					sourceOut		= u.CRecurX.*sourceIn + sum(WZ'.*preSourceIn,2) + sqrt(1-sum(WZ.^2,1)'-u.CRecurX^2).*randn(u.nSig,1);
					destOut			= u.CRecurY.*destIn + W'*sourceIn + sqrt(1-sum(W.^2,1)'-u.CRecurY^2).*randn(u.nSig,1);
					preSourceOut	= u.CRecurZ.*preSourceIn + sqrt(1-u.CRecurZ^2).*randn(u.nSig,u.nSig);
				otherwise
					error('Invalid normVar value %d',u.normVar);
			end
		end

		if doDebug && ~u.WSumTweak
			coeffsumx	= u.CRecurX.*ones(size(sourceIn)) + sum(WZ'.*ones(size(preSourceIn)),2) + (1-sum(WZ,1)'-u.CRecurX).*ones(u.nSig,1);
			coeffsumy	= u.CRecurY.*ones(size(destIn)) + W'*ones(size(sourceIn)) + (1-sum(W,1)'-u.CRecurY).*ones(u.nSig,1);
			coeffsumz	= u.CRecurZ.*ones(size(preSourceIn)) + (1-u.CRecurZ).*ones(u.nSig,u.nSig);
			errors		= abs([coeffsumx coeffsumy coeffsumz] - 1);
			if any(errors > 1e-8)
				error('Coefficients do not add to one.');
			end
		end
	end

	function [sourceOut,destOut,preSourceOut] = applyRecurrenceRegionStyle(obj,sW,sourceIn,destIn,preSourceIn,doDebug)
		u				= obj.uopt;
		sourceOut		= sW.WXX' * sourceIn + (1-sum(sW.WXX,1)').*randn(u.nSig,1);
		destOut			= sW.W' * sourceIn + sW.WYY' * destIn + (1-sum(sW.W)'-sum(sW.WYY)').*randn(u.nSig,1);
		preSourceOut	= preSourceIn;
	end

	function out = applyVarianceNormalizationToWeightedSum(~,varargin)
		coeffSigPairs	= varargin;
		nPair			= numel(coeffSigPairs);
		if nPair < 1
			error('No arguments.');
		end
		firstPair		= coeffSigPairs{1};
		sizeSigs		= size(firstPair{2});
		weightedSum		= zeros(sizeSigs);
		sumSqCoeffs		= zeros(sizeSigs);
		for kP=1:nPair
			pair		= coeffSigPairs{kP};
			coeff		= pair{1};
			sig			= pair{2};
			sqCoeff		= coeff.^2;
			if all(size(coeff) == size(sig))
				term	= coeff.*sig;
			else
				term	= coeff*sig;
			end
			if sizeSigs(2) == 1
				term	= sum(term,2);
				sqCoeff	= sum(sqCoeff,2);
			end
			weightedSum	= weightedSum + term;
			sumSqCoeffs	= sumSqCoeffs + sqCoeff;
		end
		out				= weightedSum./sqrt(sumSqCoeffs);
	end

	function c = calculateCausality(obj,X,Y,indicesOfSamples,kind)
		u	= obj.uopt;
		if ismember('fakecause',u.fudge)
			c = randn^2; %Fudge: return random causality
			return;
		end
		switch kind
			case 'gc'
				c	= GrangerCausalityUni(X,Y,...
						'samples'		, indicesOfSamples	  ...
						);
			case 'mvgc'
				c	= GrangerCausality(X,Y,...
						'samples'		, indicesOfSamples	, ...
						'max_aclags'	, u.max_aclags		  ...
						);
			case 'te'
				c	= TransferEntropy(X,Y,...
						'samples'		, indicesOfSamples	, ...
						'kraskov_k'		, u.kraskov_k		  ...
						);
			otherwise
				error('Unrecognized causality kind %s',kind);
		end
	end

	%calculateLizierMVCTE: obsolescent, deprecated, soon to be removed.
	function TE = calculateLizierMVCTE(obj,X,Y)
		u		= obj.uopt;
		teCalc	= obj.infodyn_teCalc;
		teCalc.initialise(1,size(X,2),size(Y,2)); % Use history length 1 (Schreiber k=1)
		teCalc.setProperty('k',num2str(u.kraskov_k)); % Use Kraskov parameter K=4 for 4 nearest points
		teCalc.setObservations(X,Y);
		TE		= teCalc.computeAverageLocalOfObservations();
	end

	%calculate the Causality from X components to Y components for each
	%run and for the specified condition
	% conditionName is 'A' or 'B'
	function W_stars = calculateW_stars(obj,target,X,Y,conditionName)
		u		= obj.uopt;
		sigs	= extractSignalsForCondition(obj,target,X,Y,conditionName);
		W_stars	= repmat({zeros(u.nSigCause)},[u.nRun 1]);

		for kR=1:u.nRun
			s	= sigs{kR};

			for kX=1:u.nSigCause
				X	= s.Xall(:,:,kX);

				for kY=1:u.nSigCause
					Y					= s.Yall(:,:,kY);
					W_stars{kR}(kX,kY)	= calculateCausality(obj,X,Y,...
											s.kNext,u.WStarKind);
				end
			end
		end
	end

	function obj = changeDefaultsForBatchProcessing(obj)
		obj	= obj.changeOptionDefault('nofigures',true);
		obj	= obj.changeOptionDefault('nowarnings',true);
		obj	= obj.changeOptionDefault('progress',false);
		obj	= obj.changeOptionDefault('verbosity',0);
	end

	function obj = changeDefaultsToDebug(obj)
		obj	= obj.changeOptionDefault('DEBUG',true);
		obj	= obj.changeOptionDefault('seed',0);
	end

	function obj = changeOptionDefault(obj,optionName,newDefault)
		if ~ismember(optionName,obj.explicitOptionNames)
			obj.uopt.(optionName)	= newDefault;
		end
	end

	function [acc,p_binom] = classifyBetweenWs(obj,WAs,WBs)
		u	= obj.uopt;
		P	= cvpartition(u.nRun,'LeaveOut');

		res	= zeros(P.NumTestSets,1);
		for kP=1:P.NumTestSets
			WATrain	= cellfun(@(W) reshape(W,1,[]), WAs(P.training(kP)),'uni',false);
			WBTrain	= cellfun(@(W) reshape(W,1,[]), WBs(P.training(kP)),'uni',false);

			WATest	= cellfun(@(W) reshape(W,1,[]), WAs(P.test(kP)),'uni',false);
			WBTest	= cellfun(@(W) reshape(W,1,[]), WBs(P.test(kP)),'uni',false);

			WATrain	= cat(1,WATrain{:});
			WBTrain	= cat(1,WBTrain{:});
			WATest	= cat(1,WATest{:});
			WBTest	= cat(1,WBTest{:});

			WTrain	= [WATrain; WBTrain];
			WTest	= [WATest; WBTest];

			lblTrain	= reshape(repmat({'A' 'B'},[u.nRun-1 1]),[],1);
			lblTest		= {'A';'B'};

			sSVM	= svmtrain(WTrain,lblTrain);
			pred	= svmclassify(sSVM,WTest);
			res(kP)	= sum(strcmp(pred,lblTest));
		end

		%one-tailed binomial test
		Nbin	= 2*u.nRun;
		Pbin	= 0.5;
		Xbin	= sum(res);
		p_binom	= 1 - binocdf(Xbin-1,Nbin,Pbin);
		%accuracy
		acc		= Xbin/Nbin;
	end

	% TODO: clean up comments
	% X,Y dims are [time, run, which_signal].
	% conditionName is 'A' or 'B'
	%
	% Return cell array indexed by run.  Each cell holds a struct with
	%   X,Y,XLag,YLag,XFudge,YFudge corresponding to specified condition.
	%   Dimensions of these signal slices are [time, 1, which_signal].
	function signals = extractSignalsForCondition(~,target,X,Y,conditionName)
		nRun	= numel(target);
		signals = cell(nRun,1);

		%TODO: Many of the members of sigs below are obsolescent, to be removed.
		for kR=1:nRun
			ind			= strcmp(target{kR},conditionName);
			indshift	= [0; ind(1:end-1)];
			kLag		= find(ind);
			k			= find(indshift);	% i.e., kLag + 1;
			kFudge		= find(ind | indshift);
			sigs.kNext	= k;
			sigs.Xall	= X(:,kR,:);
			sigs.Yall	= Y(:,kR,:);
			sigs.X		= X(k,kR,:);
			sigs.Y		= Y(k,kR,:);
			sigs.XLag	= X(kLag,kR,:);
			sigs.YLag	= Y(kLag,kR,:);
			sigs.XFudge	= X(kFudge,kR,:);
			sigs.YFudge	= Y(kFudge,kR,:);
			signals{kR}	= sigs;
		end
	end

	function [block,target] = generateBlockDesign(obj,doDebug)
		u			= obj.uopt;
		designSeed	= randi(intmax('uint32'));
		rngState	= rng;
		block		= blockdesign(1:2,u.nRepBlock,u.nRun,'seed',designSeed);
		rng(rngState);
		target		= arrayfun(@(run) block2target(block(run,:),u.nTBlock,u.nTRest,{'A','B'}),reshape(1:u.nRun,[],1),'uni',false);

		if doDebug
			nTRun	= numel(target{1});	%number of time points per run
			fprintf('TRs per run: %d\n',nTRun);
			showBlockDesign(obj,block);
		end
	end

	function [X,Y] = generateFunctionalSignals(obj,block,target,sW,doDebug)
		u		= obj.uopt;
		nTRun	= numel(target{1});	%number of time points per run

		[X,Y]	= deal(zeros(nTRun,u.nRun,u.nSig));
		Z		= zeros(nTRun,u.nRun,u.nSig,u.nSig);

		for kR=1:u.nRun
			sW.W	= sW.WBlank;
			for kT=1:nTRun
				%previous values
				if kT==1
					xPrev	= randn(u.nSig,1);
					yPrev	= randn(u.nSig,1);
					zPrev	= randn(u.nSig,u.nSig);
				else
					xPrev	= squeeze(X(kT-1,kR,:));
					yPrev	= squeeze(Y(kT-1,kR,:));
					zPrev	= squeeze(Z(kT-1,kR,:,:));
				end

				%X=source, Y=destination, Z=pre-source
				[X(kT,kR,:),Y(kT,kR,:),Z(kT,kR,:,:)]	= applyRecurrence(obj,sW,xPrev,yPrev,zPrev,doDebug);

				%causality matrix for the next sample
				switch target{kR}{kT}
					case 'A'
						sW.W	= sW.WA;
					case 'B'
						sW.W	= sW.WB;
					otherwise
						sW.W	= sW.WBlank;
				end
			end
		end

		if doDebug
			showFunctionalSigStats(obj,X,Y);
			showFunctionalSigPlot(obj,X,Y,block);
		end
	end

	function [X,Y] = generateSignalsMaybeMixed(obj,block,target,sW,doDebug)
		u		= obj.uopt;

		%generate the functional signals
		[X,Y]	= generateFunctionalSignals(obj,block,target,sW,doDebug);

		%mix between voxels (if applicable)
		if u.doMixing
			nTRun	= numel(target{1});	%number of time points per run
			nT		= nTRun*u.nRun;		%total number of time points
			X		= reshape(reshape(X,nT,u.nSig)*randn(u.nSig,u.nVoxel),nTRun,u.nRun,u.nVoxel) + u.noiseMix*randn(nTRun,u.nRun,u.nVoxel);
			Y		= reshape(reshape(Y,nT,u.nSig)*randn(u.nSig,u.nVoxel),nTRun,u.nRun,u.nVoxel) + u.noiseMix*randn(nTRun,u.nRun,u.nVoxel);
		end
	end

	function sW = generateStructOfWs(obj,doDebug)
		u										= obj.uopt;

		%the two causality matrices (and other control causality matrices)
		%(four causality matrices altogether in the standard case;
		% possibly two more below if xCausAlpha is non-empty)
		nW										= 4;
		[cW,cWCause]							= deal(cell(nW,1));
		for kW=1:nW
			[cW{kW},cWCause{kW}]				= generateW(obj,u.xCausAlpha);
		end
		[sW.WA,sW.WB,sW.WBlank,sW.WZ]			= deal(cW{:});
		%two "internal" causality matrices for non-empty xCausAlpha:
		if ~isempty(u.xCausAlpha)
			[sW.WXX,WXXCause]					= generateW(obj,1);
			[sW.WYY,WYYCause]					= generateW(obj,1-u.xCausAlpha);
		end

		if doDebug
			[WACause,WBCause,WBlankCause,WZCause]	= deal(cWCause{:});
			showTwoWs(obj,WACause,WBCause,'W_A and W_B');
			showTwoWs(obj,WBlankCause,WZCause,'W_{blank} and W_Z');
			if isfield(sW,'WXX')
				showTwoWs(obj,WXXCause,WYYCause,'W_{XX} and W_{YY}');
			end
			fprintf('WA column sums:  %s\n',sprintf('%.3f ',sum(WACause)));
			fprintf('WB column sums:  %s\n',sprintf('%.3f ',sum(WBCause)));
			if isfield(sW,'WYY')
				fprintf('sum(WA)+sum(WYY): %s\n',sprintf('%.3f ',sum(WACause)+sum(WYYCause)));
				fprintf('sum(WB)+sum(WYY): %s\n',sprintf('%.3f ',sum(WBCause)+sum(WYYCause)));
			else
				fprintf('sum(WA)+CRecurY: %s\n',sprintf('%.3f ',sum(WACause)+u.CRecurY));
				fprintf('sum(WB)+CRecurY: %s\n',sprintf('%.3f ',sum(WBCause)+u.CRecurY));
			end
		end
	end

	function [W,WCause] = generateW(obj,alpha)
		if obj.uopt.WSmooth
			[W,WCause]	= generateWPseudoSparse(obj);
		else
			[W,WCause]	= generateWSparse(obj);
		end
		if ~isempty(alpha)
			[W,WCause]	= deal(alpha*W,alpha*WCause);
		end
	end

	function [W,WCause] = generateWPseudoSparse(obj)
		u								= obj.uopt;
		%generate a random WCause
		WCause							= rand(u.nSigCause);
		%drive some (or many) elements toward zero (pseudo-sparsity)
		WCause							= WCause.^(1/u.WFullness);
		%normalize each column to the specified sum
		WCause							= WCause*u.WSum./repmat(sum(WCause,1),[u.nSigCause 1]);
		%insert into the full matrix
		W								= zeros(u.nSig);
		W(1:u.nSigCause,1:u.nSigCause)	= WCause;
	end

	function [W,WCause] = generateWSparse(obj)
		u								= obj.uopt;
		WFullness						= u.WFullness;

		%generate a random WCause
		WCause							= rand(u.nSigCause);
		%make it sparse
		if u.WSquash
			WCause(1-WCause>WFullness)	= 0;
		else
			WCause(WCause>WFullness)	= 0;
		end
		%normalize each column to the specified mean
		WCause							= WCause*u.WSum./repmat(sum(WCause,1),[u.nSigCause 1]);
		WCause(isnan(WCause))			= 0;

		%insert into the full matrix
		W								= zeros(u.nSig);
		W(1:u.nSigCause,1:u.nSigCause)	= WCause;
	end

	%TODO: comments
	function capsule = makePlotCapsule(obj,plotSpec,varargin)
		opt	= ParseArgs(varargin,...
			'saveplot'		, obj.uopt.saveplot	  ...
			);
		if ~isstruct(plotSpec)
			error('Plot spec must be struct.');
		end
		requiredFields	= {
			'xlabel'		, ...
			'varName'		, ...
			'varValues'		, ...
			'nIteration'	  ...
			};
		missingFields	= cellfun(@(f) ~isfield(plotSpec,f), requiredFields);
		if any(missingFields)
			error('Missing plot parameter(s):%s',sprintf(' ''%s''',requiredFields{missingFields}));
		end

		pause(1);
		start_ms	= nowms;
		varName		= plotSpec.varName;
		values		= plotSpec.varValues;
		nValue		= numel(values);
		nIteration	= plotSpec.nIteration;
		nSim		= nValue * nIteration;

		if ~iscell(values)
			values	= num2cell(values);
		end

		rng(obj.uopt.seed,'twister');

		cValue				= reshape(repmat(values(:)',nIteration,1),1,[]);
		cSeed				= num2cell(randi(intmax,1,nSim));

		vopt				= repmat(obj.uopt,1,nSim);
		[vopt.(varName)]	= deal(cValue{:});
		[vopt.seed]			= deal(cSeed{:});
		[vopt.progress]		= deal(false);

		cVopt				= num2cell(vopt);
		parObj				= repmat(obj,1,nSim);
		[parObj.uopt]		= deal(cVopt{:});
		summary				= MultiTask(@simulateAllSubjects,...
								{num2cell(parObj)},...
								'nthread',obj.uopt.max_cores,...
								'silent',true);

		result				= repmat(struct,1,nSim);
		[result.varName]	= deal(varName);
		[result.varValue]	= deal(cValue{:});
		[result.seed]		= deal(cSeed{:});
		[result.summary]	= deal(summary{:});
		cResult				= num2cell(reshape(result,nIteration,nValue));

		end_ms				= nowms;
		capsule.begun		= FormatTime(start_ms);
		capsule.id			= FormatTime(start_ms,'yyyymmdd_HHMMSS');
		capsule.format		= 2;
		capsule.plotSpec	= plotSpec;
		capsule.opt			= obj.uopt;
		capsule.result		= cResult;
		capsule.elapsed_ms	= end_ms - start_ms;
		capsule.done		= FormatTime(end_ms);

		if opt.saveplot
			iflow_plot_capsule	= capsule;
			save([capsule.id '_iflow_plot_capsule.mat'],'iflow_plot_capsule');
		end
	end

	function note = noteVaryingOpts(obj,capsule)
		u			= obj.uopt;
		spec		= capsule.plotSpec;
		opt			= capsule.opt;
		cNote		= {};

		if ~strcmp(spec.varName,'nSubject')
			cNote{end+1}	= sprintf('nSubject=%d',opt.nSubject);
		end
		if opt.CRecurX == 0 && opt.CRecurY == 0 && opt.CRecurZ == 0
			cNote{end+1}	= 'recur=0';
		elseif opt.CRecurX ~= u.CRecurX || opt.CRecurY ~= u.CRecurY || opt.CRecurZ ~= u.CRecurZ
			cNote{end+1}	= 'recur=?';
		end
		if isfield(opt,'WSquash') && opt.WSquash
			cNote{end+1}	= 'wsqsh';
		end
		if isfield(opt,'WSumTweak') && opt.WSumTweak
			cNote{end+1}	= 'wstwk';
		end
		if isfield(opt,'normVar') && opt.normVar ~= 0
			cNote{end+1}	= sprintf('normVar=%d',opt.normVar);
		end
		note		= strjoin(cNote,',');
	end

	function h = renderMultiLinePlot(obj,cCapsule,var2Spec,var2Indices)
		if nargin < 4
			var2Indices	= 1:numel(cCapsule);
		end
		szCapsule	= size(cCapsule);
		if szCapsule(1) == 0 || any(szCapsule(2:end) > 1)
			error('Invalid capsule cell dimensions.');
		end
		cap1		= cCapsule{1};
		if cap1.format ~= 2
			error('Incompatible capsule format.');
		end
		spec1		= cap1.plotSpec;
		result1		= cap1.result;
		varName1	= spec1.varName;
		szResult	= size(result1);
		if any(cellfun(@(c) any(size(c.result) ~= szResult),cCapsule))
			error('Non-uniform capsule result sizes.');
		end
		if any(cellfun(@(c) ~strcmp(varName1,c.plotSpec.varName),cCapsule))
			error('Inconsistent capsule variable names.');
		end
		% TODO: Verify consistent variable values across subcapsules.

		var2Labels	= arrayfun(@(i) sprintf('%s=%.2f',...
						var2Spec.varName,var2Spec.varValues(i)),...
						var2Indices,'uni',false);
		acc			= zeros([szResult numel(var2Indices)]);

		for kI=1:size(acc,3)
			acc(:,:,kI)	= cellfun(@(r) r.summary.alex.acc,...
								cCapsule{var2Indices(kI)}.result);
		end

		meanAcc		= mean(acc);
		stderrAcc	= stderr(acc);

		parennote	= noteVaryingOpts(obj,cap1);
		if ~isempty(parennote)
			parennote	= sprintf(' (%s)',parennote);
		end
		title		= sprintf('Accuracy as a function of %s%s',...
						varName1,parennote);
		ylabel		= 'Accuracy (%)';
		xvals		= cellfun(@(r) r.varValue, result1(1,:));
		yvals		= num2cell(100*meanAcc,[1 2]);
		errorvals	= num2cell(100*stderrAcc,[1 2]);
		h			= alexplot(xvals,yvals,...
						'error'		, errorvals		, ...
						'title'		, title			, ...
						'xlabel'	, spec1.xlabel	, ...
						'ylabel'	, ylabel		, ...
						'legend'	, var2Labels	, ...
						'errortype'	, 'bar'			  ...
						);
	end

	function showBlockDesign(obj,block)
		if obj.uopt.nofigures
			return;
		end
		figure;
		imagesc(block);
		colormap('gray');
		title('block design (blk=A, wht=B)');
		xlabel('block');
		ylabel('run');
	end

	function showFunctionalSigPlot(obj,X,Y,block)
		if obj.uopt.nofigures
			return;
		end
		u		= obj.uopt;
		nTRun	= size(X,1);	%number of time points per run

		tPlot	= reshape(1:nTRun,[],1);
		xPlot	= X(:,1,1);
		yPlot	= Y(:,1,1);

		h		= alexplot(tPlot,{xPlot yPlot},...
			'title'		, 'Run 1'		, ...
			'xlabel'	, 't'			, ...
			'ylabel'	, 'Amplitude'	, ...
			'legend'	, {'X','Y'}		  ...
			);

		yLim	= get(h.hA,'ylim');
		yMin	= yLim(1);
		yMax	= yLim(2);

		col	= {[0.25 0.25 0.25]; [0.75 0.75 0.75]};

		for kB=1:size(block,2)
			blockCur	= block(1,kB);
			colCur		= col{blockCur};

			kStart		= u.nTRest + 1 + (kB-1)*(u.nTBlock+u.nTRest);
			kEnd		= kStart + u.nTBlock;

			tStart	= tPlot(kStart);
			tEnd	= tPlot(kEnd);

			hP	= patch([tStart;tStart;tEnd;tEnd],[yMin;yMax;yMax;yMin],colCur);
			set(hP,'EdgeColor',colCur);
			MoveToBack(h.hA,hP);
		end
	end

	function showFunctionalSigStats(obj,X,Y)
		u		= obj.uopt;
		nTRun	= size(X,1);	%number of time points per run

		XCause	= X(:,:,1:u.nSigCause);
		YCause	= Y(:,:,1:u.nSigCause);

		%cMeasure	= {'mean','range','std','std(d/dx)'};
		cFMeasure	= {@mean,@range,@std,@(x) std(diff(x))};

		cXMeasure	= cellfun(@(f) f(reshape(permute(XCause,[1 3 2]),nTRun*u.nSigCause,u.nRun)),cFMeasure,'uni',false);
		cYMeasure	= cellfun(@(f) f(reshape(permute(YCause,[1 3 2]),nTRun*u.nSigCause,u.nRun)),cFMeasure,'uni',false);

		cXMMeasure	= cellfun(@mean,cXMeasure,'uni',false);
		cYMMeasure	= cellfun(@mean,cYMeasure,'uni',false);

		[~,p,~,kstats]	= cellfun(@ttest2,cXMeasure,cYMeasure,'uni',false);
		tstat			= cellfun(@(s) s.tstat,kstats,'uni',false);

		fprintf('XCause mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',cXMMeasure{:});
		fprintf('YCause mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',cYMMeasure{:});
		fprintf('p      mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',p{:});
		fprintf('tstat  mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',tstat{:});
	end

	function showTwoWs(obj,W1,W2,figTitle)
		if obj.uopt.nofigures
			return;
		end
		u				= obj.uopt;
		imDims			= [u.szIm NaN];
		graySeparator	= 0.8*ones(u.szIm,round(1.5*u.szIm/u.nSigCause));

		im	= normalize([W1 W2]);
		im	= [imresize(im(:,1:u.nSigCause),imDims,'nearest') graySeparator imresize(im(:,u.nSigCause+1:end),imDims,'nearest')];
		figure; imshow(im);
		title(figTitle);
	end

	function summary = simulateAllSubjects(obj)
		u					= obj.uopt;
		if u.nowarnings
			warningState	= warning('off','all');
			try
				summary		= simulateAllSubjectsInternal(obj);
			catch ME
				warning(warningState);
				rethrow(ME);
			end
			warning(warningState);
		else
			summary			= simulateAllSubjectsInternal(obj);
		end
	end

	function summary = simulateAllSubjectsInternal(obj)
		u			= obj.uopt;
		DEBUG		= u.DEBUG;
		summary		= struct('start_ms',nowms);

		%initialize pseudo-random-number generator
		rng(u.seed,'twister');

		%run each subject
		results	= cell(u.nSubject,1);

		% Note that this method's caller could be using the 'progress'
		% function *externally*.  Therefore, in case of ~u.progress,
		% it does NOT suffice to suppress the progress reports below
		% through the 'silent' option:  instead we must avoid the
		% calls to 'progress' altogether.
		if u.progress
			progresstypes	= {'figure','commandline'};
			progress(u.nSubject,'label','simulating each subject',...
					'type',progresstypes{1+u.nofigures});
		end
		for kS=1:u.nSubject
			doDebug		= DEBUG && kS==1;
			results{kS}	= simulateSubject(obj,doDebug);

			if u.progress
				progress;
			end
		end

		%evaluate the classifier accuracies
		if isfield(results{1},'alexAccSubj')
			acc							= cellfun(@(r) r.alexAccSubj,results);
			[~,p_grouplevel,~,stats]	= ttest(acc,0.5,'tail','right');

			summary.alex.acc			= mean(acc);
			summary.alex.p				= p_grouplevel;
			if DEBUG
				fprintf('Alex mean accuracy: %.2f%%\n',100*summary.alex.acc);
				fprintf('Alex group-level: t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p_grouplevel);
			end
		end
		if isfield(results{1},'lizierTEs')
			% TODO: Factor out common code between lizier (here) and seth (below)
			TEsCondA					= cellfun(@(r) r.lizierTEs(1),results);
			TEsCondB					= cellfun(@(r) r.lizierTEs(2),results);
			[h,p_grouplevel,ci,stats]	= ttest(TEsCondA,TEsCondB);
			summary.lizier.h			= h;
			summary.lizier.p			= p_grouplevel;
			summary.lizier.ci			= ci;
			summary.lizier.stats		= stats;
			if DEBUG
				fprintf('Lizier h: %d  (ci=[%.4f,%.4f])\n',h,ci(1),ci(2));
				fprintf('Lizier group-level: t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p_grouplevel);
			end
		end
		if isfield(results{1},'sethGCs')
			% TODO: Factor out common code between lizier (above) and seth (here)
			GCsCondA					= cellfun(@(r) r.sethGCs(1),results);
			GCsCondB					= cellfun(@(r) r.sethGCs(2),results);
			[h,p_grouplevel,ci,stats]	= ttest(GCsCondA,GCsCondB);
			summary.seth.h				= h;
			summary.seth.p				= p_grouplevel;
			summary.seth.ci				= ci;
			summary.seth.stats			= stats;
			if DEBUG
				fprintf('Seth h: %d  (ci=[%.4f,%.4f])\n',h,ci(1),ci(2));
				fprintf('Seth group-level: t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p_grouplevel);
			end
		end
		summary.subjectResults			= results;
		summary.end_ms					= nowms;
	end

	function subjectStats = simulateSubject(obj,doDebug)
		u	= obj.uopt;

		%causality matrices
		sW	= generateStructOfWs(obj,doDebug);

		%block design
		[block,target] = generateBlockDesign(obj,doDebug);

		%generate test signals
		[XTest,YTest]	= generateSignalsMaybeMixed(obj,block,target,sW,doDebug);

		%preprocess and analyze test signals according to analysis mode(s)
		subjectStats = analyzeTestSignals(obj,block,target,XTest,YTest,doDebug);
	end
end

methods (Static)
	function plot_data = constructQuickFudgedPlotData(varargin)
	%   pd=Pipeline.constructTestPlotData('saveplot',false,'fudge',{'fakecause'},'nSubject',1,'nRun',2)
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsForBatchProcessing;
		pipeline	= pipeline.changeOptionDefault('fudge',{'fakecause'});
		pipeline	= pipeline.changeOptionDefault('nSubject',1);
		pipeline	= pipeline.changeOptionDefault('nRun',2);
		pipeline	= pipeline.changeOptionDefault('seed',0);
		pipeline	= pipeline.changeOptionDefault('analysis','alex');
		pipeline	= pipeline.changeOptionDefault('saveplot',false);

		spec.xlabel		= 'W fullness';
		spec.varName	= 'WFullness';
		spec.varValues	= 0.05:0.05:0.25;
		spec.nIteration	= 5;
		capsule{1}		= pipeline.makePlotCapsule(spec);

		spec.xlabel		= 'W column sum';
		spec.varName	= 'WSum';
		spec.varValues	= [0.05 0.1 0.2 0.3 0.4];
		spec.nIteration	= 5;
		capsule{2}		= pipeline.makePlotCapsule(spec);

		spec.xlabel		= 'Number of TRs per block';
		spec.varName	= 'nTBlock';
		spec.varValues	= 1:5;
		spec.nIteration	= 5;
		capsule{3}		= pipeline.makePlotCapsule(spec);

		pause(1);
		filename_prefix			= FormatTime(nowms,'yyyymmdd_HHMMSS');
		plot_data.label			= sprintf('Three fudged capsules w/ fakecause, etc.');
		plot_data.cCapsule		= capsule;
		save([filename_prefix '_iflow_fudged_plot_data.mat'],'plot_data');
	end

	% constructTestPlotData
	function plot_data = constructTestPlotData(varargin)
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsForBatchProcessing;
		pipeline	= pipeline.changeOptionDefault('nSubject',10);
		pipeline	= pipeline.changeOptionDefault('seed',0);
		pipeline	= pipeline.changeOptionDefault('analysis','alex');

		spec				= repmat(struct,4,1);

		spec(1).xlabel		= 'Number of subjects';
		spec(1).varName		= 'nSubject';
		spec(1).varValues	= [1 2 5 10 20];

		spec(2).xlabel		= 'Number of runs';
		spec(2).varName		= 'nRun';
		spec(2).varValues	= 2:2:10;

		spec(3).xlabel		= 'W fullness';
		spec(3).varName		= 'WFullness';
		spec(3).varValues	= 0.05:0.05:0.25;

		spec(4).xlabel		= 'Number of TRs per block';
		spec(4).varName		= 'nTBlock';
		spec(4).varValues	= 1:5;

		[spec(:).nIteration]	= deal(10);

		var2Spec.label		= 'W column sum';
		var2Spec.varName	= 'WSum';
		var2Spec.varValues	= 0.1*(1:5);

		nSpec				= numel(spec);
		nVar2				= numel(var2Spec.varValues);
		capsule				= cell(nVar2,nSpec);

		for kSpec=1:nSpec
			for kVar2=1:nVar2
				p2							= pipeline;
				p2.uopt.(var2Spec.varName)	= var2Spec.varValues(kVar2);
				capsule{kVar2,kSpec}		= p2.makePlotCapsule(spec(kSpec));
			end
		end

		pause(1);
		filename_prefix			= FormatTime(nowms,'yyyymmdd_HHMMSS');
		plot_data.label			= sprintf('%dx%d capsules w/ nSubject=%d (except as noted)',...
									nVar2,nSpec,pipeline.uopt.nSubject);
		plot_data.var2Spec		= var2Spec;
		plot_data.cCapsule		= capsule;
		save([filename_prefix '_iflow_plot_data.mat'],'plot_data');
	end

	% createDebugPipeline - static method for creating debug-pipeline
	%
	% Syntax:	pipeline = Pipeline.createDebugPipeline(<options>)
	%
	% In:
	%	<options>:
	%		See Pipeline constructor above for description of <options>,
	%		but note that this method overrides the default debugging options
	%
	function pipeline = createDebugPipeline(varargin)
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsToDebug;
	end

	% debugSimulation - static method for running debug-pipeline
	%
	% Syntax:	summary = Pipeline.debugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
	function summary = debugSimulation(varargin)
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		summary		= pipeline.simulateAllSubjects;
	end

	% runSimulation - static method for running pipeline
	%
	% Syntax:	summary = Pipeline.runSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See Pipeline constructor above for description of <options>
	%
	function summary = runSimulation(varargin)
		pipeline	= Pipeline(varargin{:});
		summary		= pipeline.simulateAllSubjects;
	end

	% speedupDebugSimulation - static method for running sped-up
	%                          debug-pipeline
	%
	% Syntax:	summary = Pipeline.speedupDebugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
	function summary = speedupDebugSimulation(varargin)
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		pipeline	= pipeline.changeOptionDefault('nSubject',...
						ceil(pipeline.uopt.nSubject/3));
		pipeline	= pipeline.changeOptionDefault('nofigures',true);
		summary		= pipeline.simulateAllSubjects;
	end

	% textOnlyDebugSimulation - static method for running figure-free
	%                           debug-pipeline
	%
	% Syntax:	summary = Pipeline.textOnlyDebugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
	function summary = textOnlyDebugSimulation(varargin)
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		pipeline	= pipeline.changeOptionDefault('nofigures',true);
		summary		= pipeline.simulateAllSubjects;
	end

	% xWDebugSimulation - static method for running debug-pipeline with
	%                     extra "internal" W matrices
	%
	% Syntax:	summary = Pipeline.xWDebugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
	function summary = xWDebugSimulation(varargin)
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		pipeline	= pipeline.changeOptionDefault('xCausAlpha',0.8);
		pipeline	= pipeline.changeOptionDefault('WSum',0.8);
		summary		= pipeline.simulateAllSubjects;
	end
end
end
