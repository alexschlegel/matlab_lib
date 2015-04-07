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
	version				= struct('pipeline',20150403,...
							'capsuleFormat',20150331)
	defaultOptions
	implicitOptionNames
	explicitOptionNames
	analyses			= {'alex','lizier','seth'}
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
	%		fudge:		({}) Fudge specified details (e.g., {'stubsim'})
	%		nofigures:	(false) Suppress figures
	%		nowarnings:	(false) Suppress warnings
	%		progress:	(true) Show progress
	%		seed:		(randseed2) Seed to use for randomizing
	%		subSilent:	(true) Suppress status messages from TE, etc.
	%		szIm:		(200) Pixel height of debug images
	%		verbosData:	(true) Preserve extra data in simulation summary
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
	%		nTBlock:	(4) number of time points per block
	%		nTRest:		(4) number of time points per rest periods
	%		nRepBlock:	(12) number of repetitions of each block per run
	%		nRun:		(10) number of runs
	%
	%					-- Signal characteristics:
	%
	%		CRecurX:	(0.1) recurrence coefficient (should be <= 1)
	%		CRecurY:	(0.7) recurrence coefficient (should be <= 1)
	%		CRecurZ:	(0.5) recurrence coefficient (should be <= 1)
	%		normVar:	(false) normalize signal variances (approximately)
	%		preSource:	(false) include pre-source causal effects
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
	%					-- Batch processing and plot preparation
	%
	%		max_cores:	(1) Maximum number of cores to request for multitasking
	%		njobmax:	(1000) Maximum number of jobs per batch within MultiTask
	%		nIteration:	(10) Number of simulations per point in plot-data generation
	%		saveplot:	(false) Save individual plot capsules to mat files on generation
	%
	function obj = Pipeline(varargin)
		%user-defined parameters (with defaults)
		obj.defaultOptions	= { ...
			'DEBUG'			, false		, ...
			'fudge'			, {}		, ...
			'nofigures'		, false		, ...
			'nowarnings'	, false		, ...
			'progress'		, true		, ...
			'seed'			, randseed2	, ...
			'subSilent'		, true		, ...
			'szIm'			, 200		, ...
			'verbosData'	, true		, ...
			'verbosity'		, 1			, ...
			'nSubject'		, 20		, ...
			'nSig'			, 10		, ...
			'nSigCause'		, 10		, ...
			'nVoxel'		, 100		, ...
			'nTBlock'		, 4			, ...
			'nTRest'		, 4			, ...
			'nRepBlock'		, 12		, ...
			'nRun'			, 10		, ...
			'CRecurX'		, 0.1		, ...
			'CRecurY'		, 0.7		, ...
			'CRecurZ'		, 0.5		, ...
			'normVar'		, false		, ...
			'preSource'		, false		, ...
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
			'njobmax'		, 1000		, ...
			'nIteration'	, 10		, ...
			'saveplot'		, false		  ...
			};
		opt						= ParseArgs(varargin,obj.defaultOptions{:});
		obj.implicitOptionNames	= obj.defaultOptions(1:2:end);
		obj.explicitOptionNames	= varargin(1:2:end);
		unknownOptInd			= ~ismember(obj.explicitOptionNames,obj.implicitOptionNames);
		if any(unknownOptInd)
			error('Unrecognized option(s):%s',sprintf(' ''%s''',obj.explicitOptionNames{unknownOptInd}));
		end
		if ~iscell(opt.fudge)
			error('Invalid fudge: must be a cell.');
		end
		invalidFudgeInd			= ~ismember(opt.fudge,{'fakecause','oldplot','stubsim'});
		if any(invalidFudgeInd)
			error('Invalid fudge(s):%s',sprintf(' ''%s''',opt.fudge{invalidFudgeInd}));
		end
		opt.analysis			= CheckInput(opt.analysis,'analysis',[obj.analyses 'total']);
		opt.WStarKind			= CheckInput(opt.WStarKind,'WStarKind',{'gc','mvgc','te'});
		obj.uopt				= opt;
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
								2:size(aX,1),'te'); %#ok
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

		if ~u.preSource
			WZ(:)	= 0;
		end

		if u.WSumTweak
			if u.normVar ~= 0
				error('Combination WSumTweak and normVar not supported.');
			end
			tweakedWSum		= u.WSum/sqrt(u.nSigCause);
			sourceOut		= u.CRecurX.*sourceIn + sum(WZ.'.*preSourceIn,2) + (1-tweakedWSum-u.CRecurX).*randn(u.nSig,1);
			destOut			= u.CRecurY.*destIn + W.'*sourceIn + (1-tweakedWSum-u.CRecurY).*randn(u.nSig,1);
			preSourceOut	= u.CRecurZ.*preSourceIn + (1-u.CRecurZ).*randn(u.nSig,u.nSig);
		else
			switch u.normVar
				case 0
					sourceOut		= u.CRecurX.*sourceIn + sum(WZ.'.*preSourceIn,2) + (1-sum(WZ,1).'-u.CRecurX).*randn(u.nSig,1);
					destOut			= u.CRecurY.*destIn + W.'*sourceIn + (1-sum(W,1).'-u.CRecurY).*randn(u.nSig,1);
					preSourceOut	= u.CRecurZ.*preSourceIn + (1-u.CRecurZ).*randn(u.nSig,u.nSig);
				case 1
					sourceOut		= computeWeightedSumWithVarianceNormalization(obj,...
										{u.CRecurX,sourceIn},...
										{WZ.',preSourceIn},...
										{1-sum(WZ,1).'-u.CRecurX,randn(u.nSig,1)});
					destOut			= computeWeightedSumWithVarianceNormalization(obj,...
										{u.CRecurY,destIn},...
										{W.',sourceIn},...
										{1-sum(W,1).'-u.CRecurY,randn(u.nSig,1)});
					preSourceOut	= computeWeightedSumWithVarianceNormalization(obj,...
										{u.CRecurZ,preSourceIn},...
										{1-u.CRecurZ,randn(u.nSig,u.nSig)});
				case 2  % Alternative approach to variance normalization (TODO: remove?)
					sourceOut		= u.CRecurX.*sourceIn + sum(WZ.'.*preSourceIn,2) + sqrt(1-sum(WZ.^2,1).'-u.CRecurX^2).*randn(u.nSig,1);
					destOut			= u.CRecurY.*destIn + W.'*sourceIn + sqrt(1-sum(W.^2,1).'-u.CRecurY^2).*randn(u.nSig,1);
					preSourceOut	= u.CRecurZ.*preSourceIn + sqrt(1-u.CRecurZ^2).*randn(u.nSig,u.nSig);
				otherwise
					error('Invalid normVar value %d',u.normVar);
			end
		end

		if doDebug && ~u.WSumTweak
			coeffsumx	= u.CRecurX.*ones(size(sourceIn)) + sum(WZ.'.*ones(size(preSourceIn)),2) + (1-sum(WZ,1).'-u.CRecurX).*ones(u.nSig,1);
			coeffsumy	= u.CRecurY.*ones(size(destIn)) + W.'*ones(size(sourceIn)) + (1-sum(W,1).'-u.CRecurY).*ones(u.nSig,1);
			coeffsumz	= u.CRecurZ.*ones(size(preSourceIn)) + (1-u.CRecurZ).*ones(u.nSig,u.nSig);
			errors		= abs([coeffsumx coeffsumy coeffsumz] - 1);
			if any(errors > 1e-8)
				error('Coefficients do not add to one.');
			end
		end
	end

	function [sourceOut,destOut,preSourceOut] = applyRecurrenceRegionStyle(obj,sW,sourceIn,destIn,preSourceIn,doDebug) %#ok
		u				= obj.uopt;
		if u.WSumTweak || u.normVar ~= 0 || u.preSource
			error('WSumTweak, normVar, and preSource not supported for nonempty xCausAlpha.');
		end
		sourceOut		= sW.WXX.' * sourceIn + (1-sum(sW.WXX,1).').*randn(u.nSig,1);
		destOut			= sW.W.' * sourceIn + sW.WYY.' * destIn + (1-sum(sW.W).'-sum(sW.WYY).').*randn(u.nSig,1);
		preSourceOut	= preSourceIn;
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
						'kraskov_k'		, u.kraskov_k		, ...
						'silent'		, u.subSilent		  ...
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
		%obj	= obj.changeOptionDefault('verbosity',0);
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
			% TODO: Refactor/restructure: redundancy in similar handling of WA, WB,
			% and in similar handling of Train and Test
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

	%expected usage: product of cell arrays
	%needn't be a method, could be a free-standing function
	%TODO: with plot-code changes, may be obsolete (so, remove)
	function cprod = computeCartesianProduct(obj,varargin)
		if any(cellfun(@(a) ~iscell(a)||~isvector(a),varargin))
			error('Arguments must be cell vectors.');
		end
		if numel(varargin) == 0
			cprod	= cell(1,0);
		else
			left	= varargin{1};
			right	= computeCartesianProduct(obj,varargin{2:end});
			repleft	= repmat(left(:).',size(right,1),1);
			cprod	= [repleft(:) repmat(right,numel(left),1)];
		end
	end

	%expected usage: product of cell arrays
	%needn't be a method, could be a free-standing function
	%TODO: with plot-code changes, may be obsolete (so, remove)
	function cprod = computeLittleEndianCartesianProduct(obj,varargin)
		if any(cellfun(@(a) ~iscell(a)||~isvector(a),varargin))
			error('Arguments must be cell vectors.');
		end
		if numel(varargin) == 0
			cprod	= cell(1,0);
		else
			left		= computeLittleEndianCartesianProduct(...
							obj,varargin{1:end-1});
			right		= varargin{end};
			repright	= repmat(right(:).',size(left,1),1);
			cprod		= [repmat(left,numel(right),1) repright(:)];
		end
	end

	function out = computeWeightedSumWithVarianceNormalization(~,varargin)
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

	% TODO: Clean up.  This method is an abject mess.
	function [array,cLabel,label2index,getfield] = ...
				convertPlotCapsuleResultToArray(obj,capsule)
		u			= obj.uopt;
		result		= capsule.result;
		keys		= result{1}.keyTuple;
		keymaps		= arrayfun(@(k) {keys{k},@(r)forcenum(r.valueTuple{k})}, ...
						1:numel(keys),'uni',false);
		datamaps	= {	{'seed',	@(r)r.seed}, ...
						{'acc',		@(r)r.summary.alex.meanAccAllSubj}, ...
						{'stderr',	@(r)r.summary.alex.stderrAccAllSu}, ...
						{'alex_p',	@(r)r.summary.alex.p} ...
					  };
		stubmaps	= {};
		if ismember('stubsim',u.fudge)
			stubmaps	= arrayfun(@(k) {['(' keys{k} ')'], ...
							@(r)fetchopt(r.summary,keys{k})}, ...
							1:numel(keys),'uni',false);
		end
		maps		= [keymaps datamaps stubmaps];
		cLabel		= cellfun(@(m)m{1},maps,'uni',false);
		cArray		= cellfun(@(m)cellfun(@(r)m{2}(r),result), ...
						maps,'uni',false);
		array		= cat(1+numel(keys),cArray{:});
		label2index	= @getLabelIndex;
		getfield	= @getSubarrayForLabel;

		function n = fetchopt(summary,optname)
			if isfield(summary,'uopt') && isfield(summary.uopt,optname)
				n	= forcenum(summary.uopt.(optname));
			else
				n	= -Inf;
			end
		end

		function n = forcenum(n)
			if ~isnumeric(n)||~isscalar(n)
				n	= -Inf;
			elseif isnan(n)
				n	= Inf;
			end
		end

		function index = getLabelIndex(label)
			index	= find(strcmp(label,cLabel));
			if ~isscalar(index)
				error('Invalid or non-unique label %s',label);
			end
		end

		function values = getSubarrayForLabel(label,data)
			shape	= size(data);
			index	= getLabelIndex(label);
			data	= shiftdim(data,numel(keys));
			values	= reshape(data(index,:),shape(1:end-1));
		end
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
		% possibly two more below if xCausAlpha is nonempty)
		nW										= 4;
		[cW,cWCause]							= deal(cell(nW,1));
		for kW=1:nW
			[cW{kW},cWCause{kW}]				= generateW(obj,u.xCausAlpha);
		end
		[sW.WA,sW.WB,sW.WBlank,sW.WZ]			= deal(cW{:});
		%two "internal" causality matrices for nonempty xCausAlpha:
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

	function label = getOptLabel(~,optName)
		switch optName
			case 'acc'
				label	= 'Accuracy (%)';
			case 'WFullness'
				label	= 'W fullness';
			case 'WSum'
				label	= 'W column sum';
			case 'nTBlock'
				label	= 'Number of TRs per block';
			case 'nSubject'
				label	= 'Number of subjects';
			case 'nRun'
				label	= 'Number of runs';
			otherwise
				label	= optName;
		end
	end

	%TODO: comments
	function capsule = makePlotCapsule(obj,plotSpec,varargin)
		if ~ismember('oldplot',obj.uopt.fudge)
			capsule	= makePlotCapsuleNew(obj,plotSpec,varargin{:});
		else
			capsule	= makePlotCapsuleOld(obj,plotSpec,varargin{:});
		end
	end

	%TODO: comments
	function capsule = makePlotCapsuleNew(obj,plotSpec,varargin)
		opt					= ParseArgs(varargin,...
			'saveplot'		, obj.uopt.saveplot	  ...
			);
		plotSpec			= regularizePlotSpec(obj,plotSpec);

		pause(1);
		start_ms			= nowms;
		augSpec				= plotSpec;
		augSpec.varName		= ['kIteration' plotSpec.varName];
		augSpec.varValues	= [{num2cell(1:plotSpec.nIteration)} plotSpec.varValues];
		augSpec.valuesShape	= cellfun(@numel,augSpec.varValues);
		nSim				= prod(augSpec.valuesShape);

		if obj.uopt.verbosity > 0
			fprintf('Number of plot-variable combinations = %d\n',nSim);
		end

		rng(obj.uopt.seed,'twister');

		augSpec.seed		= randi(intmax,nSim,1);
		wrapperInterface	= @(i) makePlotTaskWrapper(obj,augSpec,i);
		cResult				= MultiTask(wrapperInterface, ...
								{num2cell(1:nSim)}, ...
								'njobmax',obj.uopt.njobmax, ...
								'nthread',obj.uopt.max_cores, ...
								'silent',(obj.uopt.max_cores<2));
		cResult				= reshape(cResult,augSpec.valuesShape);
		end_ms				= nowms;

		capsule.begun		= FormatTime(start_ms);
		capsule.id			= FormatTime(start_ms,'yyyymmdd_HHMMSS');
		capsule.version		= obj.version;
		capsule.plotSpec	= plotSpec;
		capsule.uopt		= obj.uopt;
		capsule.result		= cResult;
		capsule.elapsed_ms	= end_ms - start_ms;
		capsule.done		= FormatTime(end_ms);

		if opt.saveplot
			iflow_plot_capsule	= capsule; %#ok
			save([capsule.id '_iflow_plot_capsule.mat'],'iflow_plot_capsule');
		end
	end

	%TODO: comments
	function capsule = makePlotCapsuleOld(obj,plotSpec,varargin)
		opt	= ParseArgs(varargin,...
			'saveplot'		, obj.uopt.saveplot	  ...
			);
		plotSpec	= regularizePlotSpec(obj,plotSpec);

		pause(1);
		start_ms	= nowms;
		varName		= ['kIteration' plotSpec.varName];
		varValues	= [{num2cell(1:plotSpec.nIteration)} plotSpec.varValues];
		valueGrid	= obj.computeLittleEndianCartesianProduct(varValues{:});
		if isfield(plotSpec,'filter') && ~isempty(plotSpec.filter)
			for kG=1:size(valueGrid,1)
				[valueGrid{kG,2:end}]	= plotSpec.filter(obj.uopt,valueGrid{kG,2:end});
			end
		end

		cValue		= num2cell(valueGrid,2);
		nSim		= numel(cValue);

		if obj.uopt.verbosity > 0
			fprintf('Number of plot-variable combinations = %d (*)\n',nSim);
		end

		rng(obj.uopt.seed,'twister');

		cSeed				= num2cell(randi(intmax,nSim,1));

		vopt				= repmat(obj.uopt,nSim,1);
		[vopt.seed]			= deal(cSeed{:});
		[vopt.progress]		= deal(false);
		for kV=1:numel(varName)
			name			= varName{kV};
			if ~isfield(obj.uopt,name)
				continue;
			end
			vals			= valueGrid(:,kV);
			[vopt.(name)]	= deal(vals{:});
		end

		cVopt				= num2cell(vopt);
		parObj				= repmat(obj,nSim,1);
		[parObj.uopt]		= deal(cVopt{:});
		summary				= MultiTask(@simulateAllSubjects,...
								{num2cell(parObj)},...
								'nthread',obj.uopt.max_cores,...
								'silent',(obj.uopt.max_cores<2));

		result				= repmat(struct,nSim,1);
		[result.keyTuple]	= deal(varName);
		[result.valueTuple]	= deal(cValue{:});
		[result.seed]		= deal(cSeed{:});
		[result.summary]	= deal(summary{:});
		cResult				= num2cell(reshape(result,...
								cellfun(@numel,varValues)));

		end_ms				= nowms;
		capsule.begun		= FormatTime(start_ms);
		capsule.id			= FormatTime(start_ms,'yyyymmdd_HHMMSS');
		capsule.version		= obj.version;
		capsule.plotSpec	= plotSpec;
		capsule.uopt		= obj.uopt;
		capsule.result		= cResult;
		capsule.elapsed_ms	= end_ms - start_ms;
		capsule.done		= FormatTime(end_ms);

		if opt.saveplot
			iflow_plot_capsule	= capsule; %#ok
			save([capsule.id '_iflow_plot_capsule.mat'],'iflow_plot_capsule');
		end
	end

	function result = makePlotTaskWrapper(obj,augSpec,taskIndex)
		vind		= cell(1,numel(augSpec.varName));
		[vind{:}]	= ind2sub(augSpec.valuesShape,taskIndex);
		valueTuple	= arrayfun(@(j) augSpec.varValues{j}{vind{j}}, ...
						1:numel(vind),'uni',false);
		if isfield(augSpec,'filter') && ~isempty(augSpec.filter)
			[valueTuple{2:end}]	= augSpec.filter(obj.uopt,valueTuple{2:end});
		end

		vopt				= obj.uopt;
		vopt.seed			= augSpec.seed(taskIndex);
		vopt.progress		= false;
		for kV=1:numel(augSpec.varName)
			name			= augSpec.varName{kV};
			if isfield(vopt,name)
				vopt.(name)	= valueTuple{kV};
			end
		end
		vobj				= obj;
		vobj.uopt			= vopt;
		result.keyTuple		= augSpec.varName;
		result.valueTuple	= valueTuple;
		result.seed			= vopt.seed;
		result.summary		= simulateAllSubjects(vobj);
	end

	function note = noteVaryingOpts(obj,capsule)
		u			= obj.uopt; %#ok
		spec		= capsule.plotSpec;
		opt			= capsule.uopt;
		cNote		= {};

		%{
		if ~strcmp(spec.varName,'nSubject')
			cNote{end+1}	= sprintf('nSubject=%d',opt.nSubject);
		end
		if opt.CRecurX == 0 && opt.CRecurY == 0 && opt.CRecurZ == 0
			cNote{end+1}	= 'recur=0';
		elseif opt.CRecurX == u.CRecurX && opt.CRecurY ~= u.CRecurY && opt.CRecurZ == u.CRecurZ
			cNote{end+1}	= sprintf('recurY=%.2f',opt.CRecurY);
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
		if isfield(opt,'preSource') && opt.preSource == 0
			cNote{end+1}	= '~preSrc';
		end
		%}
		note		= strjoin(cNote,',');
	end

	function note = noteVaryingOptsOldFormat(obj,capsule)
		u			= obj.uopt; %#ok
		spec		= capsule.plotSpec;
		opt			= capsule.uopt;
		cNote		= {};

		if ~strcmp(spec.varName,'nSubject')
			cNote{end+1}	= sprintf('nSubject=%d',opt.nSubject);
		end
		%{
		if opt.CRecurX == 0 && opt.CRecurY == 0 && opt.CRecurZ == 0
			cNote{end+1}	= 'recur=0';
		elseif opt.CRecurX == u.CRecurX && opt.CRecurY ~= u.CRecurY && opt.CRecurZ == u.CRecurZ
			cNote{end+1}	= sprintf('recurY=%.2f',opt.CRecurY);
		elseif opt.CRecurX ~= u.CRecurX || opt.CRecurY ~= u.CRecurY || opt.CRecurZ ~= u.CRecurZ
			cNote{end+1}	= 'recur=?';
		end
		%}
		if isfield(opt,'WSquash') && opt.WSquash
			cNote{end+1}	= 'wsqsh';
		end
		if isfield(opt,'WSumTweak') && opt.WSumTweak
			cNote{end+1}	= 'wstwk';
		end
		if isfield(opt,'normVar') && opt.normVar ~= 0
			cNote{end+1}	= sprintf('normVar=%d',opt.normVar);
		end
		if isfield(opt,'preSource') && opt.preSource == 0
			cNote{end+1}	= '~preSrc';
		end
		note		= strjoin(cNote,',');
	end

	function plotSpec = regularizePlotSpec(obj,plotSpec)
		if ~isstruct(plotSpec)
			error('Plot spec must be struct.');
		end
		requiredFields	= {
			'varName'		, ...
			'varValues'		  ...
			};
		missingFields	= cellfun(@(f) ~isfield(plotSpec,f), requiredFields);
		if any(missingFields)
			error('Missing plot parameter(s):%s',sprintf(' ''%s''',requiredFields{missingFields}));
		end

		if ~iscell(plotSpec.varName)
			plotSpec.varName	= {plotSpec.varName};
			plotSpec.varValues	= {plotSpec.varValues};
		else
			if ~iscell(plotSpec.varValues)
				error('Plot-spec varValues must be cell when varName is cell.');
			end
			if ~isvector(plotSpec.varName) || ~isvector(plotSpec.varValues)
				error('Plot-spec varName and varValues cells must be nonempty vectors.');
			end
			if numel(plotSpec.varName) ~= numel(plotSpec.varValues)
				error('Plot-spec varName and varValues cells must have same length.');
			end
			plotSpec.varName	= plotSpec.varName(:).';
			plotSpec.varValues	= plotSpec.varValues(:).';
		end

		for kVV=1:numel(plotSpec.varValues)
			if ~iscell(plotSpec.varValues{kVV})
				plotSpec.varValues{kVV}	= num2cell(plotSpec.varValues{kVV});
			end
			plotSpec.varValues{kVV}		= plotSpec.varValues{kVV}(:).';
		end

		if ~isfield(plotSpec,'pseudoVar') || isempty(plotSpec.pseudoVar)
			plotSpec.pseudoVar	= {};
		elseif ~iscell(plotSpec.pseudoVar)
			plotSpec.pseudoVar	= {plotSpec.pseudoVar};
		else
			if ~isvector(plotSpec.pseudoVar)
				error('Plot-spec pseudoVar must be cell vector.');
			end
			plotSpec.pseudoVar	= plotSpec.pseudoVar(:).';
		end
		bogusPseudoInd	= ismember(plotSpec.pseudoVar,obj.implicitOptionNames) | ...
								~ismember(plotSpec.pseudoVar,plotSpec.varName);
		if any(bogusPseudoInd)
			error('Invalid plot-spec pseudo-variable(s):%s', ...
				sprintf(' ''%s''',plotSpec.pseudoVar{bogusPseudoInd}));
		end

		invalidInd	= ~ismember(plotSpec.varName,obj.implicitOptionNames) & ...
						~ismember(plotSpec.varName,plotSpec.pseudoVar);
		if any(invalidInd)
			error('Invalid plot-spec variable(s):%s',sprintf(' ''%s''',plotSpec.varName{invalidInd}));
		end
		sortedVars	= sort(plotSpec.varName);
		dupInd		= strcmp(sortedVars(1:end-1),sortedVars(2:end));
		if any(dupInd)
			error('Duplicate plot-spec variable(s):%s',sprintf(' ''%s''',sortedVars{dupInd}));
		end

		if ~isfield(plotSpec,'nIteration')
			plotSpec.nIteration	= obj.uopt.nIteration;
		end
	end

	function [h,legend] = renderMultiLinePlot(obj,capsule,xVarName,varargin)
		opt	= ParseArgs(varargin,...
			'yVarName'				, 'acc'				, ...
			'lineVarName'			, ''				, ...
			'lineVarValues'			, {}				, ...
			'lineLabels'			, {}				, ...
			'fixedVarValuePairs'	, {}				  ...
			);
		if ~isfield(capsule,'version') || ...
				~isfield(capsule.version,'capsuleFormat') || ...
				capsule.version.capsuleFormat ~= obj.version.capsuleFormat
			error('Incompatible capsule format.');
		end
		if isempty(opt.lineVarName) ~= isempty(opt.lineVarValues)
			error('Both lineVarName and lineVarValues %s', ...
				'must be specified, or neither.');
		end
		yVarName		= opt.yVarName;
		nLineVarValue	= numel(opt.lineVarValues);
		nLineLabel		= numel(opt.lineLabels);
		nPlotLine		= max([1 nLineVarValue]);
		if nLineLabel > 0 && nLineLabel ~= nPlotLine
			error('Inconsistent number of lineLabels.');
		elseif nLineLabel == 0
			if isempty(opt.lineVarName)
				opt.lineLabels	= {yVarName};
			else
				%TODO Fix. Type test is at wrong level
				isfrac			= @(n)n~=floor(n);
				if ~all(cellfun(@isnumeric,opt.lineVarValues(:)))
					template	= '%s=%s';
				elseif any(cellfun(isfrac,opt.lineVarValues(:)))
					template	= '%s=%.2f';
				else
					template	= '%s=%d';
				end
				vv2label		= @(vv)sprintf(template,opt.lineVarName,vv);
				opt.lineLabels	= cellfun(vv2label,opt.lineVarValues, ...
									'uni',false);
			end
		end
		fixedVars				= opt.fixedVarValuePairs(1:2:end);
		fixedVarValues			= opt.fixedVarValuePairs(2:2:end);
		if numel(fixedVars) ~= numel(fixedVarValues) || ...
				~all(cellfun(@ischar,fixedVars))
			error('Ill-formed fixedVarValuePairs.');
		end

		[data,~,label2index,getfield]	= ...
				convertPlotCapsuleResultToArray(obj,capsule);
		for kFV=1:numel(fixedVars)
			data	= constrainData(data,fixedVars{kFV},fixedVarValues{kFV});
			if numel(data) == 0
				error('Variables overconstrained.');
			end
		end
		if strcmp(yVarName,'acc')
			[facY,facE]	= deal(100); % Percentages
		else
			[facY,facE]	= deal(1,0);
		end
		[xvals,yvals,errorvals]	= deal(cell(1,nPlotLine));
		for kPL=1:nPlotLine
			plData		= data;
			if ~isempty(opt.lineVarName)
				plData	= constrainData(plData,opt.lineVarName, ...
								opt.lineVarValues{kPL});
			end
			sqzData		= squeeze(plData);
			if numel(size(sqzData)) > 3
				error('Variables underconstrained.');
			end
			% The aggregates below (min, max, mean) explicitly specify
			% dimension 1 in case nIteration == 1, in which case the
			% implicit aggregation dimension would *not* equal 1.
			allx			= getfield(xVarName,plData);
			minx			= min(allx,[],1);
			maxx			= max(allx,[],1);
			if any(minx(:) ~= maxx(:))
				error('Inconsistent x values.');
			end
			xvals{kPL}		= squeeze(maxx);
			yvals{kPL}		= squeeze(facY*mean(getfield(yVarName,plData),1));
			errorvals{kPL}	= squeeze(facE*mean(getfield('stderr',plData),1));
		end

		parennote	= noteVaryingOpts(obj,capsule);
		if ~isempty(parennote)
			parennote	= sprintf(' (%s)',parennote);
		end
		xlabel		= getOptLabel(obj,xVarName);
		ylabel		= getOptLabel(obj,yVarName);
		legend		= opt.lineLabels;
		title		= sprintf('%s vs %s%s',ylabel,xVarName,parennote);
		h			= alexplot(xvals,yvals,...
						'error'		, errorvals			, ...
						'title'		, title				, ...
						'xlabel'	, xlabel			, ...
						'ylabel'	, ylabel			, ...
						'legend'	, legend			, ...
						'errortype'	, 'bar'				  ...
						);

		function subdata = constrainData(data,varName,varValue)
			varIdx		= label2index(varName);
			lastDim		= numel(size(data));
			rdims		= 1:(lastDim-1);
			perm		= [varIdx lastDim rdims(rdims~=varIdx)];
			pdata		= permute(data,perm);
			sz_pdata	= size(pdata);
			varData		= permute(pdata(:,varIdx,:),[1 3 2]);
			varEq		= find(all(varData==varValue,2));
			pdata		= pdata(varEq,:);
			pdata		= reshape(pdata,[numel(varEq) sz_pdata(2:end)]);
			subdata		= ipermute(pdata,perm);
		end
	end

	function h = renderMultiLinePlotOldFormat(obj,cCapsule,capMeta,capIndices)
		if nargin < 4
			capIndices	= 1:numel(cCapsule);
		end
		szCapsule	= size(cCapsule);
		if szCapsule(1) == 0 || any(szCapsule(2:end) > 1)
			error('Invalid capsule cell dimensions.');
		end
		cap1		= cCapsule{1};
		if ~isfield(cap1,'version') || ...
				~isfield(cap1.version,'capsuleFormat') || ...
				cap1.version.capsuleFormat ~= obj.version.capsuleFormat
			error('Incompatible capsule format.');
		end
		spec1		= cap1.plotSpec;
		result1		= cap1.result;
		if numel(spec1.varName) > 1
			error('Multiple variables per capsule not supported this version.');
		end
		varName1_1	= spec1.varName{1};
		szResult	= size(result1);
		if any(cellfun(@(c) any(size(c.result) ~= szResult),cCapsule))
			error('Non-uniform capsule result sizes.');
		end
		if any(cellfun(@(c) ~strcmp(c.plotSpec.varName{1},varName1_1),cCapsule))
			error('Inconsistent capsule variable names.');
		end

		lineLabels	= arrayfun(@(i) sprintf('%s=%.2f',...
						capMeta.varName,capMeta.varValues(i)),...
						capIndices,'uni',false);
		xArray		= zeros([szResult(2) numel(capIndices)]);
		meanAcc		= zeros([szResult(1) size(xArray)]);
		stderrAcc	= zeros(size(meanAcc));

		for kI=1:size(meanAcc,3)
			result				= cCapsule{capIndices(kI)}.result;
			xArray(:,kI)		= cellfun(@(r) r.valueTuple{2},squeeze(result(1,:)));
			meanAcc(:,:,kI)		= cellfun(@(r) r.summary.alex.meanAccAllSubj,result);
			stderrAcc(:,:,kI)	= cellfun(@(r) r.summary.alex.stderrAccAllSu,result);
		end

		meanMean	= mean(meanAcc,1); % explicit dim (in case nIteration == 1)
		meanStderr	= mean(stderrAcc,1);
		%stderrMean	= stderr(meanAcc,0,1);  %Conventional stat, but not desired.

		parennote	= noteVaryingOptsOldFormat(obj,cap1);
		if ~isempty(parennote)
			parennote	= sprintf(' (%s)',parennote);
		end
		title		= sprintf('Accuracy as a function of %s%s',...
						varName1_1,parennote);
		xlabel		= getOptLabel(obj,varName1_1);
		ylabel		= 'Accuracy (%)';
		xvals		= num2cell(squeeze(xArray),1);
		yvals		= num2cell(squeeze(100*meanMean),1);
		errorvals	= num2cell(squeeze(100*meanStderr),1);
		%{
		fprintf('xvals has size%s\n',sprintf(' %d',size(xvals)));
		fprintf('yvals has size%s\n',sprintf(' %d',size(yvals)));
		for i=1:numel(xvals)
			disp(xvals{i}');
			disp(yvals{i}');
		end
		%}
		h			= alexplot(xvals,yvals,...
						'error'		, errorvals		, ...
						'title'		, title			, ...
						'xlabel'	, xlabel		, ...
						'ylabel'	, ylabel		, ...
						'legend'	, lineLabels	, ...
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
				summary		= simulateAllSubjectsCheckNaNOrStub(obj);
			catch ME
				warning(warningState);
				rethrow(ME);
			end
			warning(warningState);
		else
			summary			= simulateAllSubjectsCheckNaNOrStub(obj);
		end
	end

	function summary = simulateAllSubjectsCheckNaNOrStub(obj)
		summary.start_ms				= nowms;
		u								= obj.uopt;

		%initialize pseudo-random-number generator
		rng(u.seed,'twister');

		%perform simulations, or substitute stub if applicable;
		%in case of NaN params, set answers to NaN
		if any(cellfun(@(p) isnumeric(p)&&any(isnan(p(:))),struct2cell(u)))
			%NaN actions; augment as necessary
			summary.isMissing			= true;
			summary.alex.meanAccAllSubj	= NaN;
			summary.alex.stderrAccAllSu	= NaN;
			summary.alex.p				= NaN;
		elseif ismember('stubsim',u.fudge)
			%stub actions; revise as necessary
			summary.isMissing			= false;
			summary.uopt				= u;
			summary.alex.meanAccAllSubj	= 1.0*randn;
			summary.alex.stderrAccAllSu	= 0.2*randn;
			summary.alex.p				= 0.5*rand;
			%summary.alex.meanAccAllSubj	= u.WSum;
			%summary.alex.stderrAccAllSu	= 0.1*u.CRecurY;
		else
			summary.isMissing			= false;
			summary						= simulateAllSubjectsInternal(...
											obj,summary);
		end
		summary.end_ms					= nowms;
	end

	function summary = simulateAllSubjectsInternal(obj,summary)
		u			= obj.uopt;
		DEBUG		= u.DEBUG;

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
					'type',progresstypes{1+u.nofigures},...
					'log',false);
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
			% TODO: Factor out common code between alex (here) and lizier and seth (below)
			acc							= cellfun(@(r) r.alexAccSubj,results);
			[h,p_grouplevel,ci,stats]	= ttest(acc,0.5,'tail','right');

			summary.alex.meanAccAllSubj	= mean(acc);
			summary.alex.stderrAccAllSu	= stderr(acc);
			summary.alex.h				= h;
			summary.alex.p				= p_grouplevel;
			summary.alex.ci				= ci;
			summary.alex.stats			= stats;
			if DEBUG
				fprintf('Alex mean accuracy: %.2f%%\n',100*summary.alex.meanAccAllSubj);
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
		if u.verbosData
			summary.subjectResults			= results;
		end
	end

	function subjectStats = simulateSubject(obj,doDebug)
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
	% constructTestPlotData
	function plot_data = constructTestPlotData(varargin)
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsForBatchProcessing;
		pipeline	= pipeline.changeOptionDefault('nSubject',10);
		pipeline	= pipeline.changeOptionDefault('seed',0);
		pipeline	= pipeline.changeOptionDefault('analysis','alex');

		spec				= repmat(struct,4,1);

		spec(1).varName		= 'WSum';
		spec(1).varValues	= 0:0.05:0.3;

		spec(2).varName		= 'WSum';
		spec(2).varValues	= 0:0.05:0.3;
		spec(2).filter		= @(u,WSum) deal(WSum * (1-u.CRecurY)/0.3);

		spec(3).varName		= 'WFullness';
		spec(3).varValues	= 0.1:0.2:0.9;

		spec(4).varName		= 'nTBlock';
		spec(4).varValues	= 1:5;

		capMeta.varName		= 'CRecurY';
		capMeta.varValues	= [0 0.35 0.7];

		rng(pipeline.uopt.seed,'twister');

		nSpec				= numel(spec);
		nCapvar				= numel(capMeta.varValues);
		capsule				= cell(nCapvar,nSpec);
		capseeds			= randi(intmax,1,nCapvar);

		for kSpec=1:nSpec
			for kCapvar=1:nCapvar
				p2							= pipeline;
				p2.uopt.(capMeta.varName)	= capMeta.varValues(kCapvar);
				p2.uopt.seed				= capseeds(kCapvar);
				capsule{kCapvar,kSpec}		= p2.makePlotCapsule(spec(kSpec));
			end
		end

		pause(1);
		filename_prefix			= FormatTime(nowms,'yyyymmdd_HHMMSS'); %#ok
		plot_data.label			= sprintf('%dx%d capsules w/ nSubject=%d (except as noted)',...
									nCapvar,nSpec,pipeline.uopt.nSubject);
		plot_data.capMeta		= capMeta;
		plot_data.cCapsule		= capsule;
		%save([filename_prefix '_recurY_plot_data.mat'],'plot_data');
	end

	function cH = constructTestPlotsFromData(plot_data)
		pipeline	= Pipeline;
		meta		= plot_data.capMeta;
		cap			= plot_data.cCapsule;
		nFig		= size(cap,2);
		cH			= cell(1,nFig);
		for kF=1:nFig
			cH{kF}	= pipeline.renderMultiLinePlotOldFormat(cap(:,kF),meta);
		end
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
