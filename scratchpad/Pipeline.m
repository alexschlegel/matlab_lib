% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
%
% This class is a reworking of Alex's script 20150116_alex_tests.m
% and now incorporates the changes from 20150123_alex_tests.m
% --------------------------------------------------------------------

classdef Pipeline

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
	version				= struct('pipeline',20150501.2114,...
							'capsuleFormat',20150423)
	defaultOptions
	implicitOptionNames
	explicitOptionNames
	notableOptionNames
	unlikelyOptionNames
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
	%					-- Debugging/diagnostic options
	%
	%		DEBUG:		(false) Display debugging information
	%		fudge:		({}) Fudge specified details (e.g., {'stubsim'})
	%		nofigures:	(false) Suppress figures
	%		nowarnings:	(false) Suppress warnings
	%		progress:	(true) Show progress
	%		seed:		(randseed2) Seed to use for randomizing (false for none)
	%		subSilent:	(true) Suppress status messages from TE, etc.
	%		szIm:		(200) Pixel height of debug images
	%		verbosData:	(true) Preserve extra data in simulation summary
	%		verbosity:	(1) Extra diagnostic output level (0=none, 10=most)
	%
	%					-- Subjects
	%
	%		nSubject:	(20) number of subjects
	%
	%					-- Size of the various spaces
	%
	%		nSig:		(10) total number of functional signals
	%		nSigCause:	(10) number of functional signals of X that cause Y
	%		nVoxel:		(100) number of voxels into which the functional components are mixed
	%
	%					-- Time
	%
	%		nTBlock:	(4) number of time points per block
	%		nTRest:		(4) number of time points per rest periods
	%		nRepBlock:	(12) number of repetitions of each block per run
	%		nRun:		(10) number of runs
	%
	%					-- Signal characteristics
	%
	%		CRecurX:	(0.1) recurrence coefficient (should be <= 1)
	%		CRecurY:	(0.7) recurrence coefficient (should be <= 1)
	%		CRecurZ:	(0.5) recurrence coefficient (should be <= 1)
	%		normVar:	(false) normalize signal variances (approximately)
	%		preSource:	(false) include pre-source causal effects
	%		SNR:		(false) signal-to-noise ratio (positive real, or false if N/A)
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
	%					-- Hemodynamic response
	%
	%		hrf:		(false) convolve signals with hemodynamic response function
	%		hrfOptions:	({}) options to quasiHRF kernel generator
	%
	%					-- Analysis
	%
	%		analysis:	('alex') analysis mode:  'alex', 'lizier', 'seth', or 'total'
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
			'SNR'			, false		, ...
			'WFullness'		, 0.1		, ...
			'WSmooth'		, false		, ...
			'WSquash'		, false		, ...
			'WSum'			, 0.2		, ...
			'WSumTweak'		, false		, ...
			'xCausAlpha'	, []		, ...
			'doMixing'		, true		, ...
			'noiseMix'		, 0.1		, ...
			'hrf'			, false		, ...
			'hrfOptions'	, {}		, ...
			'analysis'		, 'alex'	, ...
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
		obj.notableOptionNames	= { 'nSubject', 'nSig', 'nSigCause', ...
									'nVoxel', 'nTBlock', 'nTRest', ...
									'nRepBlock', 'nRun', 'CRecurX', ...
									'CRecurY', 'CRecurZ', 'SNR', ...
									'WFullness', 'WSum', 'noiseMix', ...
									'hrf'  ...
								  };
		obj.unlikelyOptionNames	= { 'normVar', 'preSource', 'WSmooth', ...
									'WSquash', 'WSumTweak', 'xCausAlpha', ...
									'doMixing'  ...
								  };
		unknownOptInd			= ~ismember(obj.explicitOptionNames,obj.implicitOptionNames);
		if any(unknownOptInd)
			error('Unrecognized option(s):%s',sprintf(' ''%s''',obj.explicitOptionNames{unknownOptInd}));
		end
		if ~iscell(opt.fudge)
			error('Invalid fudge: must be a cell.');
		end
		invalidFudgeInd			= ~ismember(opt.fudge,{'fakecause','stubsim'});
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
					sourceNoise		= (1-sum(WZ,1).'-u.CRecurX).*randn(u.nSig,1);
					if ~notfalse(u.SNR)
						destNoise	= (1-sum(W,1).'-u.CRecurY).*randn(u.nSig,1);
					else
						destNoise	= 0;
					end
					sourceOut		= u.CRecurX.*sourceIn + sum(WZ.'.*preSourceIn,2) + sourceNoise;
					destOut			= u.CRecurY.*destIn + W.'*sourceIn + destNoise;
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
		if u.WSumTweak || u.normVar ~= 0 || u.preSource || notfalse(u.SNR)
			error('WSumTweak, normVar, preSource, and SNR not supported for nonempty xCausAlpha.');
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

	% TODO: should be a function, not a method--but is there a nice built-in for this?
	function s = asString(~,value)
		s	= toString(value);

		function s = toString(value)
			if iscell(value)
				s	= strjoin(cellfun(@toString,value(:).','uni',false));
			elseif ischar(value)
				s	= value(:).'; % TODO: maybe improve?
			elseif islogical(value)
				s	=  sprintf('%d',value);
			elseif ~isnumeric(value)
				s	= '??'; % TODO: improve
			elseif ~isscalar(value)
				s	=  strjoin(arrayfun(@toString,value(:).','uni',false));
			elseif value ~= floor(value)
				s	=  sprintf('%.2f',value); % TODO: refine
			else
				s	=  sprintf('%d',value);
			end
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
		obj	= obj.changeSeedDefaultAndConsume(0);
	end

	function obj = changeOptionDefault(obj,optionName,newDefault)
		if ~ismember(optionName,obj.explicitOptionNames)
			obj.uopt.(optionName)	= newDefault;
		end
	end

	function obj = changeSeedDefaultAndConsume(obj,seed)
		obj	= obj.changeOptionDefault('seed',seed);
		obj	= obj.consumeRandomizationSeed;
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

	function obj = consumeRandomizationSeed(obj)
		if notfalse(obj.uopt.seed)
			rng(obj.uopt.seed,'twister');
		end
		obj.uopt.seed	= false;
	end

	% TODO: Clean up.  This method's functionality should be made into
	% a separate class, whose methods would include something like
	% "getfield" (currently a return value), a label2index mapping method,
	% and something like constrainData (currently an inner function in
	% renderMultiLinePlot).
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
		cArray		= cellfun(@(m)cellfun(@(r)appsafe(m{2},r),result), ...
						maps,'uni',false);
		array		= cat(1+numel(keys),cArray{:});
		label2index	= @getLabelIndex;
		getfield	= @getSubarrayForLabel;

		function v = appsafe(fn,arg)
			try
				v	= fn(arg);
			catch ME %#ok
				v	= -Inf;
			end
		end

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

	%Find min v in varDomain such that fn(v) <= goal
	%It is assumed that varDomain is monotonically increasing
	%It is assumed that fn is monotonically nonincreasing
	%
	% Sample quick test:
	%>> p=Pipeline('nSubject',2,'nRun',5,'nTBlock',2);
	%>> d=p.findThreshold
	function domainValue = findThreshold(obj,varargin)
		opt	= ParseArgs(varargin, ...
				'varName'		, 'nRepBlock'	, ...
				'varDomain'		, 1:24			, ...
				'fn'			, @get_p_value	, ...
				'projection'	, @project_p	, ...
				'goal'			, 0				  ...
				);
		minidx				= 1;
		maxidx				= numel(opt.varDomain);
		best_d				= NaN;
		while minidx <= maxidx
			idx				= floor((minidx+maxidx)/2);
			d				= opt.varDomain(idx);
			p				= opt.fn(d);
			%fprintf('f(%d)=%g\n',d,p);
			if p <= opt.goal
				best_d		= d;
				maxidx		= idx-1;
			else
				minidx		= idx+1;
			end
		end
		domainValue			= best_d;

		function p = get_p_value(d)
			pobj					= obj;
			pobj.uopt.(opt.varName)	= d;
			pobj.uopt.nofigures		= true;
			pobj.uopt.progress		= false;
			summary					= simulateAllSubjects(pobj);
			p						= opt.projection(summary);
		end

		function p = project_p(summary)
			p						= summary.alex.p;
		end

		% For testing
		%{
		function p = hyperbola(d)
			p			= 1/d;
		end
		%}
	end

	function [block,target] = generateBlockDesign(obj,doDebug)
		u			= obj.uopt;
		block		= blockdesign(1:2,u.nRepBlock,u.nRun,'seed',false);
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
			showSigPlot(obj,X,Y,block,'Functional');
		end
	end

	function [X,Y] = generateSignalNoiseMixtureWithNormVar(obj,block,target,sW,doDebug)
		u			= obj.uopt;

		if u.nSig ~= u.nSigCause
			error('For SNR with normVar, nSig must equal nSigCause.');
		end
		if ~u.doMixing
			error('For SNR with normVar, doMixing must be true.');
		end
		if u.WSmooth || u.WSquash || u.WSumTweak || ~isempty(u.xCausAlpha)
			error('For SNR with normVar, cannot have WSmooth, WSquash, WSumTweak, or xCausAlpha.');
		end

		nTRun		= numel(target{1});	%number of time points per run
		nVoxel		= u.nVoxel;
		nSig		= u.nSig;
		nNoise		= nVoxel-nSig;
		funcidx		= 1:nSig;
		noiseidx	= (nSig+1):nVoxel;
		[X,Y]		= deal(zeros(nTRun,u.nRun,nVoxel));

		% Abbreviating MixX as M, a given signal x(i) at time T is
		% computed as the value from time T-1 of
		%
		%   M(i,1)*x(1) + M(i,2)*x(2) + ....
		%
		% For the purposes of signal-to-noise computation, components
		% 1 through nSig (the functional signals) are considered to be
		% the *signal*; the remaining nNoise components are noise.
		%
		% The variance of functional signal i at time T (abbrev xi@T)
		% is approximately
		%
		%   M(i,1)^2*var(x1@(T-1)) + M(i,2)^2*var(x2@(T-1)) + ....
		%
		% (This approximation assumes that the functional signals are
		% not cross-correlated, although to some degree they are.)
		%
		% Assume variances of functional signals are all equal, and
		% invariant over time, and that variances of noise components
		% are all 1.  Let vfx denote the variance of each functional
		% signal.  Then, for i in funcidx (i.e., i in 1:nSig), we have
		%
		%   vfx == vfx*(M(i,1)^2 + M(i,2)^2 + ... + M(i,nSig)^2) +
		%          (M(i,nSig+1)^2 + ... + M(i,nVoxel)^2).
		%
		% Hence
		%
		%   vfx*(1-(M(i,1)^2 + M(i,2)^2 + ... + M(i,nSig)^2)) ==
		%       M(i,nSig+1)^2 + ... + M(i,nVoxel)^2,
		%
		% or
		%
		% (1) vfx == (M(i,nSig+1)^2 + ... + M(i,nVoxel)^2) /
		%            (1-(M(i,1)^2 + M(i,2)^2 + ... + M(i,nSig)^2)).
		%
		% We define signal-to-noise ratio as vfx*nSig/nNoise.  Then for
		% a given SNR, vfx == SNR*nNoise/nSig.  To obtain desired vfx,
		% we can adjust either the numerator or denominator of Eq (1).
		% For simplicity, we set denominator at 0.5 and calibrate
		% elements of M accordingly.
		%
		% The case of MixY is similar to that of MixX, but there is an
		% extra term in the recurrence for Y, so the variance of y(i)
		% is approximately
		%
		%   M(i,1)^2*var(y(1)) + ... + M(i,nVoxel)^2*var(y(nVoxel)) +
		%       W(1,i)^2*var(x(1)) + ... + W(nSig,i)^2*var(x(nSig)).
		%
		% Let vfy denote the variance of each functional signal in y.
		% For i in funcidx we have
		%
		%   vfy == vfy*(M(i,1)^2 + ... + M(i,nSig)^2) +
		%          (M(i,nSig+1)^2 + ... + M(i,nVoxel)^2) +
		%          vfx*(W(1,i)^2 + ... + W(nSig,i)^2).
		%
		% If our target value for vfy is the same as vfx, then we have
		%
		%   vfy == vfy*(M(i,1)^2 + ... M(i,nSig)^2 +
		%               W(1,i)^2 + .. + W(nSig,i)^2) +
		%          (M(i,nSig+1)^2 + ... + M(i,nVoxel)^2),
		%
		% or
		%
		% (2) vfy == (M(i,nSig+1)^2 + ... + M(i,nVoxel)^2) /
		%            (1-(M(i,1)^2 + ... + M(i,nSig)^2 +
		%                W(1,i)^2 + ... + W(nSig,i)^2)).
		%
		% Note that W(1,i)^2 + ... + W(nSig,i)^2 cannot exceed WSum^2.
		% If, as in the case of x, we make M(i,1)^2 + ... + M(i,nSig)^2
		% equal to 0.5, then for WSum <= 0.5, the presence of the W
		% terms adds at most 0.25, and hence affects the denominator by
		% at most a factor of two.  On this basis we ignore the effect
		% of W for now, though as a future refinement we may wish to
		% take it into account.

		MixXSig		= randn(nSig,nSig);
		MixXNoise	= randn(nSig,nNoise);
		sumSqXSig	= sum(MixXSig.^2,2);
		sumSqXNoise	= sum(MixXNoise.^2,2);
		scaleXSig	= sqrt(0.5./sumSqXSig);
		scaleXNoise	= sqrt((0.5*u.SNR*nNoise/nSig)./sumSqXNoise);
		MixXSig		= repmat(scaleXSig,1,nSig).*MixXSig;
		MixXNoise	= repmat(scaleXNoise,1,nNoise).*MixXNoise;
		MixX		= [MixXSig MixXNoise];

		MixYSig		= randn(nSig,nSig);
		MixYNoise	= randn(nSig,nNoise);
		sumSqYSig	= sum(MixYSig.^2,2);
		sumSqYNoise	= sum(MixYNoise.^2,2);
		scaleYSig	= sqrt(0.5./sumSqYSig);
		scaleYNoise	= sqrt((0.5*u.SNR*nNoise/nSig)./sumSqYNoise);
		MixYSig		= repmat(scaleYSig,1,nSig).*MixYSig;
		MixYNoise	= repmat(scaleYNoise,1,nNoise).*MixYNoise;
		MixY		= [MixYSig MixYNoise];

		if doDebug
			sumSqXSig	= sum(MixXSig.^2,2);
			sumSqXNoise	= sum(MixXNoise.^2,2);
			vfx			= sumSqXNoise ./ (1 - sumSqXSig);
			SNRx		= vfx * (nSig/nNoise);
			fprintf('scaleXSig.''   =%s\n',sprintf(' %.3f',scaleXSig.'));
			fprintf('scaleXNoise.'' =%s\n',sprintf(' %.3f',scaleXNoise.'));
			fprintf('sumSqXSig.''   =%s\n',sprintf(' %.3f',sumSqXSig.'));
			fprintf('sumSqXNoise.'' =%s\n',sprintf(' %.3f',sumSqXNoise.'));
			fprintf('vfx.''         =%s\n',sprintf(' %.3f',vfx.'));
			fprintf('SNRx.''        =%s\n',sprintf(' %.3f',SNRx.'));

			sumSqYSig	= sum(MixYSig.^2,2);
			sumSqYNoise	= sum(MixYNoise.^2,2);
			vfy			= sumSqYNoise ./ (1 - sumSqYSig);
			SNRy		= vfy * (nSig/nNoise);
			fprintf('scaleYSig.''   =%s\n',sprintf(' %.3f',scaleYSig.'));
			fprintf('scaleYNoise.'' =%s\n',sprintf(' %.3f',scaleYNoise.'));
			fprintf('sumSqYSig.''   =%s\n',sprintf(' %.3f',sumSqYSig.'));
			fprintf('sumSqYNoise.'' =%s\n',sprintf(' %.3f',sumSqYNoise.'));
			fprintf('vfy.''         =%s\n',sprintf(' %.3f',vfy.'));
			fprintf('SNRy.''        =%s\n',sprintf(' %.3f',SNRy.'));
		end

		nPrev		= nVoxel;

		for kR=1:u.nRun
			sW.W	= sW.WBlank;
			for kT=1:nTRun
				%previous values
				if kT==1
					xPrev	= randn(nPrev,1);
					yPrev	= randn(nPrev,1);
				else
					xPrev	= squeeze(X(kT-1,kR,1:nPrev));
					yPrev	= squeeze(Y(kT-1,kR,1:nPrev));
				end

				%X=source, Y=destination
				X(kT,kR,funcidx)	= MixX*xPrev;
				X(kT,kR,noiseidx)	= randn(nNoise,1);

				Y(kT,kR,funcidx)	= MixY*yPrev + sW.W.'*xPrev(funcidx);
				Y(kT,kR,noiseidx)	= randn(nNoise,1);

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
			showSigPlot(obj,X,Y,block,'SNR-based');
		end
	end

	function [X,Y] = generateSignalsWithOptions(obj,block,target,sW,doDebug)
		u		= obj.uopt;

		if notfalse(u.SNR) && u.normVar
			[X,Y]	= generateSignalNoiseMixtureWithNormVar(obj,block,target,sW,doDebug);
		else
			%generate the functional signals
			[X,Y]	= generateFunctionalSignals(obj,block,target,sW,doDebug);

			%mix between voxels (if applicable)
			if u.doMixing
				if ~notfalse(u.SNR)
					X		= mapToVoxels(X,0,true);
					Y		= mapToVoxels(Y,0,true);
				else
					X		= mapToVoxels(X,0,true);
					Y		= mapToVoxels(Y,u.nVoxel,false);
				end
				if doDebug
					showSigPlot(obj,X,Y,block,'Mixed Voxel');
				end
			end
		end

		if u.hrf
			kernel	= quasiHRF(u.hrfOptions{:});
			X		= convCols(X,kernel);
			Y		= convCols(Y,kernel);

			if doDebug
				showSigPlot(obj,X,Y,block,'Post-HRF');
			end
		end

		function C = convCols(C,kernel)
			n1				= size(C,1);
			nCol			= numel(C)/n1;
			for kCol=1:nCol
				C_hat		= conv(C(:,kCol),kernel);
				C(:,kCol)	= C_hat(1:n1);
			end
		end

		function S = mapToVoxels(S,preextension_width,isPostNoise)
			% Dimensions of S are (time,run,sig)
			sz				= size(S);
			nTRun			= numel(target{1});	%number of time points per run
			nT				= nTRun*u.nRun;		%total number of time points
			if sz(1) ~= nTRun || sz(2) ~= u.nRun
				error('Unexpected dimensions.');
			end
			sigwid			= sz(3);
			S				= reshape(S,nT,sigwid);
			if preextension_width > sigwid
				noisewid	= preextension_width - sigwid;
				sigvar		= var(S(:));
				noisecoeff	= sqrt((sigwid/noisewid)*(sigvar/u.SNR));
				noise		= noisecoeff*randn(nT,noisewid);
				S			= [S noise];
				if doDebug
					weightedsv	= sigwid*sigvar;
					weightednv	= noisewid*var(noise(:));
					fprintf('Weighted variances for SNR: sig=%g, noise=%g, sig:noise=%g, post-sig=%g\n', ...
						weightedsv,weightednv,weightedsv/weightednv,size(S,2)*var(S(:)));
				end
			end
			S				= S*randn(size(S,2),u.nVoxel);
			if isPostNoise
				S			= S + u.noiseMix*randn(size(S));
			end
			S				= reshape(S,nTRun,u.nRun,u.nVoxel);
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
			case 'nRepBlock'
				label	= 'Number of blocks per run';
			case 'nRun'
				label	= 'Number of runs';
			case 'nSubject'
				label	= 'Number of subjects';
			case 'nTBlock'
				label	= 'Number of TRs per block';
			case 'SNR'
				label	= 'Signal-to-noise ratio';
			case 'WFullness'
				label	= 'W fullness';
			case 'WSum'
				label	= 'W column sum';
			otherwise
				label	= optName;
		end
	end

	%TODO: comments
	function capsule = makePlotCapsule(obj,plotSpec,varargin)
		obj					= consumeRandomizationSeed(obj);
		opt					= ParseArgs(varargin,...
			'saveplot'		, obj.uopt.saveplot	  ...
			);
		plotSpec			= regularizePlotSpec(obj,plotSpec);

		pause(1);
		start_ms			= nowms;
		itVarName			= ['kIteration' plotSpec.varName];
		itVarValues			= [{num2cell(1:plotSpec.nIteration)} plotSpec.varValues];
		itValuesShape		= cellfun(@numel,itVarValues);
		nSim				= prod(itValuesShape);

		if obj.uopt.verbosity > 0
			fprintf('Number of plot-variable combinations = %d\n',nSim);
		end

		seed				= randperm(intmax('uint32'),nSim).';
		rngState			= rng;
		cResult				= MultiTask(@taskWrapper, ...
								{num2cell(1:nSim)}, ...
								'njobmax',obj.uopt.njobmax, ...
								'cores',obj.uopt.max_cores, ...
								'silent',(obj.uopt.max_cores<2));
		rng(rngState);
		end_ms				= nowms;

		capsule.begun		= FormatTime(start_ms);
		capsule.id			= FormatTime(start_ms,'yyyymmdd_HHMMSS');
		capsule.version		= obj.version;
		capsule.plotSpec	= plotSpec;
		capsule.uopt		= obj.uopt;
		capsule.result		= reshape(cResult,itValuesShape);
		capsule.elapsed_ms	= end_ms - start_ms;
		capsule.done		= FormatTime(end_ms);

		if opt.saveplot
			iflow_plot_capsule	= capsule; %#ok
			save([capsule.id '_iflow_plot_capsule.mat'],'iflow_plot_capsule');
		end

		function result = taskWrapper(taskIndex)
			vind		= cell(1,numel(itVarName));
			[vind{:}]	= ind2sub(itValuesShape,taskIndex);
			valueTuple	= arrayfun(@(j) itVarValues{j}{vind{j}}, ...
							1:numel(vind),'uni',false);
			if isfield(plotSpec,'transform') && ~isempty(plotSpec.transform)
				[valueTuple{2:end}]	= plotSpec.transform(valueTuple{2:end});
			end

			vopt				= obj.uopt;
			vopt.seed			= seed(taskIndex);
			vopt.nofigures		= true;
			vopt.progress		= false;
			for kV=1:numel(itVarName)
				name			= itVarName{kV};
				if isfield(vopt,name)
					vopt.(name)	= valueTuple{kV};
				end
			end
			vobj				= obj;
			vobj.uopt			= vopt;
			result.keyTuple		= itVarName;
			result.valueTuple	= valueTuple;
			result.seed			= vopt.seed;
			result.summary		= simulateAllSubjects(vobj);
		end
	end

	function note = noteFixedVars(obj,fixedVars,fixedVarValues)
		[~,ix]	= sort(lower(fixedVars));
		binding	= arrayfun(@(i)sprintf('%s=%s',fixedVars{i}, ...
						asString(obj,fixedVarValues{i})), ...
						ix,'uni',false);
		note	= strjoin(binding,',');
	end

	function note = noteMiscOpts(obj,capsule,getConstVarVal,optsToExclude)
		binding		= {};
		names		= [obj.notableOptionNames obj.unlikelyOptionNames];
		[~,ix]		= sort(lower(names));

		for kName=1:numel(names)
			name		= names{ix(kName)};
			val			= getConstVarVal(name);
			defval		= obj.uopt.(name);
			include		= ismember(name,obj.notableOptionNames);
			if ~include && ~isempty(val)
				include	= ~(ischar(val) && strcmp(val,defval) || ...
							islogical(val) && val == defval || ...
							isnumeric(val) && val == defval);
			end
			if include && ~isempty(val) && ~ismember(name,optsToExclude)
				binding{end+1}	= sprintf('%s=%s',name,asString(obj,val)); %#ok
			end
		end
		binding{end+1}	= sprintf('vcap-vplot=%.2f-%07.2f', ...
							capsule.version.pipeline, ...
							mod(obj.version.pipeline,10000));
		note			= {};
		while numel(binding) > 0
			idx			= min(8,numel(binding));
			note{end+1}	= strjoin(binding(1:idx),', '); %#ok
			binding		= binding(idx+1:end);
		end
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

	function h = renderMultiLinePlot(obj,capsule,xVarName,varargin)
		opt	= ParseArgs(varargin,...
			'yVarName'				, 'acc'				, ...
			'lineVarName'			, ''				, ...
			'lineVarValues'			, {}				, ...
			'lineLabels'			, {}				, ...
			'horizVarName'			, ''				, ...
			'horizVarValues'		, {}				, ...
			'vertVarName'			, ''				, ...
			'vertVarValues'			, {}				, ...
			'fixedVarValuePairs'	, {}				  ...
			);
		if ~isfield(capsule,'version') || ...
				~isfield(capsule.version,'capsuleFormat') || ...
				capsule.version.capsuleFormat ~= obj.version.capsuleFormat
			error('Incompatible capsule format.');
		end
		checkBothOrNeither('line');
		checkBothOrNeither('horiz');
		checkBothOrNeither('vert');
		if ~isempty(opt.horizVarName) || ~isempty(opt.vertVarName)
			h			= makeMultiplot;
			return;
		end
		yVarName		= opt.yVarName;
		nLineVarValue	= numel(opt.lineVarValues);
		nLineLabel		= numel(opt.lineLabels);
		nPlotLine		= max([1 nLineVarValue]);
		if nLineLabel > 0
			if nLineLabel ~= nPlotLine
				error('Inconsistent number of lineLabels.');
			end
			if obj.uopt.verbosity > 0
				fprintf('%s %s\n', ...
					'Use of ''lineLabels'' option is error-prone', ...
					'and is not recommended.');
			end
		else
			if isempty(opt.lineVarName)
				opt.lineLabels	= {yVarName};
			else
				vv2label		= @(vv)sprintf('%s=%s',opt.lineVarName,...
									asString(obj,vv));
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

		[data,cLabel,label2index,getfield]	= ...
				convertPlotCapsuleResultToArray(obj,capsule);
		for kFV=1:numel(fixedVars)
			data	= constrainData(data,fixedVars{kFV},fixedVarValues{kFV});
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
			if numel(plData) == 0
				error('Variables overconstrained.');
			elseif numel(size(squeeze(plData))) > 3
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

		parennote	= noteFixedVars(obj,fixedVars,fixedVarValues);
		if ~isempty(parennote)
			parennote	= sprintf(' (%s)',parennote);
		end
		xlabel		= getOptLabel(obj,xVarName);
		ylabel		= getOptLabel(obj,yVarName);
		title		= sprintf('%s vs %s%s',ylabel,xVarName,parennote);
		h			= alexplot(xvals,yvals,...
						'error'		, errorvals			, ...
						'title'		, title				, ...
						'xlabel'	, xlabel			, ...
						'ylabel'	, ylabel			, ...
						'legend'	, opt.lineLabels	, ...
						'errortype'	, 'bar'				  ...
						);
		set(h.hTitle,'FontSize',12);
		pos			= get(h.hA,'Position');
		pos([2 4])	= pos([2 4]) + [0.07 -0.07];
		set(h.hA,'Position',pos);
		axes('Position',[0 0 1 1],'Visible','off');
		text(0.02,0.07,noteMiscOpts(obj,capsule,@getConstVarVal,fixedVars));

		function checkBothOrNeither(prefix)
			name	= [prefix 'VarName'];
			values	= [prefix 'VarValues'];
			if isempty(opt.(name)) ~= isempty(opt.(values))
				error(['Both %s and %s must be specified, ' ...
					'or neither.'],name,values);
			end
		end

		% constrainData: See also comments at convertPlotCapsuleResultToArray.
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

		function val = getConstVarVal(varName)
			if ~ismember(varName,cLabel)
				if isfield(capsule.uopt,varName)
					val	= capsule.uopt.(varName);
				else
					val	= [];
				end
			else
				allv	= getfield(varName,data);
				val		= min(allv(:));
				if val ~= max(allv(:))
					val	= [];
				end
			end
		end

		function mp = makeMultiplot
			nH						= max(1,numel(opt.horizVarValues));
			nV						= max(1,numel(opt.vertVarValues));
			figGrid					= cell(nV,nH);
			subopt					= opt;
			subopt.horizVarName		= '';
			subopt.vertVarName		= '';
			subopt.horizVarValues	= {};
			subopt.vertVarValues	= {};
			for kH=1:nH
				for kV=1:nV
					subopt.fixedVarValuePairs ...
									= cat(2,opt.fixedVarValuePairs, ...
										getPair('horiz',kH), ...
										getPair('vert',kV));
					suboptcell		= opt2cell(subopt);
					figGrid{kV,kH}	= renderMultiLinePlot(obj, ...
										capsule,xVarName,suboptcell{:});
				end
			end
			hFGrid	= cellfun(@(h) h.hF,figGrid);
			set(hFGrid,'Position',[0 0 600 350]);

			mp						= multiplot(figGrid);

			PostSetLegend(figGrid{end});

			function pair = getPair(direction,index)
				name	= opt.([direction 'VarName']);
				cValue	= opt.([direction 'VarValues']);
				if isempty(name)
					pair	= {};
				else
					pair	= {name,cValue{index}};
				end
			end
		end
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

	function showSigPlot(obj,X,Y,block,kindOfSig)
		if obj.uopt.nofigures
			return;
		end
		u		= obj.uopt;
		nTRun	= size(X,1);	%number of time points per run

		tPlot	= reshape(1:nTRun,[],1);
		xPlot	= X(:,1,1);
		yPlot	= Y(:,1,1);

		title	= [kindOfSig ' (Run 1, Signal 1)'];
		h		= alexplot(tPlot,{xPlot yPlot},...
			'title'		, title			, ...
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
		obj								= consumeRandomizationSeed(obj);
		u								= obj.uopt;
		summary.start_ms				= nowms;

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
			% NOTE: It may appear that the second assignment below, in
			% overwriting summary, is wiping out the fields of summary
			% that are already present.  However, those fields are
			% retained because summary is an *input* to the RHS, and is
			% updated, not replaced, by simulateAllSubjectsInternal.
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
		% TODO:  With the recent changes to progress.m, the 'log'
		% option is no longer supported.  If support is not restored
		% with future changes to progress.m, should remove 'log' from
		% call below.
		if u.progress
			progresstypes	= {'figure','commandline'};
			progress('action','init','total',u.nSubject, ...
					'label','simulating each subject', ...
					'type',progresstypes{1+u.nofigures}, ...
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
		sW				= generateStructOfWs(obj,doDebug);

		%block design
		[block,target]	= generateBlockDesign(obj,doDebug);

		%generate test signals
		[XTest,YTest]	= generateSignalsWithOptions(obj,block,target,sW,doDebug);

		%preprocess and analyze test signals according to analysis mode(s)
		subjectStats	= analyzeTestSignals(obj,block,target,XTest,YTest,doDebug);
	end
end

methods (Static)
	% constructTestPlotData
	%
	% Quick test:
	%  pd=Pipeline.constructTestPlotData('fudge',{'stubsim'})
	%  cH=Pipeline.constructTestPlotsFromData(pd)
	function plot_data = constructTestPlotData(varargin)
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsForBatchProcessing;
		pipeline	= pipeline.changeOptionDefault('nSubject',10);
		pipeline	= pipeline.changeOptionDefault('analysis','alex');
		pipeline	= pipeline.changeSeedDefaultAndConsume(0);

		spec				= repmat(struct,4,1);

		spec(1).varName		= {'WSum','CRecurY','WSumFrac'};
		spec(1).varValues	= {NaN,[0 0.35 0.7],(0:0.05:0.3)/0.3};
		spec(1).pseudoVar	= 'WSumFrac';
		spec(1).transform	= @(~,CRecurY,WSumFrac) deal(...
								WSumFrac*(1-CRecurY),CRecurY,WSumFrac);

		spec(2).varName		= {'WFullness','CRecurY'};
		spec(2).varValues	= {0.1:0.2:0.9,[0 0.35 0.7]};

		spec(3).varName		= {'nTBlock','CRecurY'};
		spec(3).varValues	= {1:5,[0 0.35 0.7]};

		spec(4).varName		= {'SNR','CRecurY'};
		spec(4).varValues	= {0.1*(1:5),[0 0.35 0.7]};

		nSpec				= numel(spec);
		capsule				= cell(1,nSpec);

		for kSpec=1:nSpec
			capsule{kSpec}	= pipeline.makePlotCapsule(spec(kSpec));
		end

		pause(1);
		filename_prefix			= FormatTime(nowms,'yyyymmdd_HHMMSS'); %#ok
		plot_data.label			= sprintf('%dx%d capsules w/ nSubject=%d (except as noted)',...
									1,nSpec,pipeline.uopt.nSubject);
		plot_data.cCapsule		= capsule;
		%save([filename_prefix '_recurY_plot_data.mat'],'plot_data');
	end

	function cH = constructTestPlotsFromData(plot_data)
		pipeline	= Pipeline;
		cap			= plot_data.cCapsule;
		nFig		= numel(cap);
		cH			= cell(1,nFig);
		for kF=1:nFig
			spec	= cap{kF}.plotSpec;
			cH{kF}	= pipeline.renderMultiLinePlot(cap{kF},spec.varName{1}, ...
						'lineVarName'	, spec.varName{2}	, ...
						'lineVarValues'	, spec.varValues{2}	  ...
						);
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
