% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
%
% Cleanup and revision of Pipeline.m
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
	% version numbers represent date; to distinguish versions within same day,
	% append decimal fractions, e.g., 20150514.1122
	version				= struct('pipeline',20150514,...
							'capsuleFormat',20150514)
	defaultOptions
	implicitOptionNames
	explicitOptionNames
	notableOptionNames
	unlikelyOptionNames
	analyses			= {'alex','lizier','seth'}
end

methods
	function obj = Pipeline(varargin)
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
	%		nSubject:	(15) number of subjects
	%
	%					-- Signal characteristics
	%
	%		nSigCause:	(10) number of functional signals of X that cause Y
	%		nSig:		(100) total number of functional signals
	%		nVoxel:		(<nSig>) number of voxels into which the functional signals are mixed
	%		SNR:		(0.2) the ratio of total variances of the causal to non-causal functional signals
	%		WStrength:	(0.5) sum of W columns (|WStrength|+|CRecur| must be <=1)
	%		WFullness:	(0.25) fullness of W matrices
	%		CRecur:		(0) recurrence coefficient (|WStrength|+|CRecur| must be <=1)
	%
	%					-- Time
	%
	%		nTBlock:	(10) number of time points per block
	%		nTRest:		(4) number of time points per rest periods
	%		nRepBlock:	(5) number of repetitions of each block per run
	%		nRun:		(15) number of runs
	%
	%					-- Mixing
	%
	%		doMixing:	(true) should we even mix into voxels?
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
	%		max_aclags:	(1000) GrangerCausality parameter to limit running time
	%		WStarKind:	('gc') what kind of causality to use in W* computations ('gc', 'mvgc', 'te')
	%
	%					-- Batch processing and plot preparation
	%
	%		max_cores:	(1) Maximum number of cores to request for multitasking
	%		njobmax:	(1000) Maximum number of jobs per batch within MultiTask
	%
	%		min_p:		(1e-6) Lower bound to impose on p-values when computing logarithms
	%		nIteration:	(10) Number of simulations per point in plot-data generation

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
			'nSubject'		, 15		, ...
			'nSigCause'		, 10		, ...
			'nSig'			, 100		, ...
			'nVoxel'		, []		, ...
			'SNR'			, 0.2		, ...
			'WStrength'		, 0.5		, ...
			'WFullness'		, 0.25		, ...
			'nTBlock'		, 10		, ...
			'nTRest'		, 4			, ...
			'nRepBlock'		, 5			, ...
			'nRun'			, 15		, ...
			'CRecur'		, 0			, ...
			'doMixing'		, true		, ...
			'hrf'			, false		, ...
			'hrfOptions'	, {}		, ...
			'analysis'		, 'alex'	, ...
			'kraskov_k'		, 4			, ...
			'max_aclags'	, 1000		, ...
			'WStarKind'		, 'gc'		, ...
			'max_cores'		, 1			, ...
			'njobmax'		, 1000		, ...
			'min_p'			, 1e-6		, ...
			'nIteration'	, 10		  ...
			};
		opt						= ParseArgs(varargin,obj.defaultOptions{:});
		obj.implicitOptionNames	= obj.defaultOptions(1:2:end);
		obj.explicitOptionNames	= varargin(1:2:end);
		obj.notableOptionNames	=	{
										'nSubject'
										'nSig'
										'nSigCause'
										'nVoxel'
										'SNR'
										'WStrength'
										'WFullness'
										'nTBlock'
										'nTRest'
										'nRepBlock'
										'nRun'
										'CRecur'
										'hrf'
										'nIteration'
									};
		obj.unlikelyOptionNames	=	{
										'doMixing'
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
		opt.nVoxel				= unless(opt.nVoxel,opt.nSig);
		opt.analysis			= CheckInput(opt.analysis,'analysis',[obj.analyses 'total']);
		opt.WStarKind			= CheckInput(opt.WStarKind,'WStarKind',{'gc','mvgc','te'});
		obj.uopt				= opt;
	end

	function subjectStats = analyzeTestSignals(obj,block,target,XTest,YTest,doDebug)
		u		= obj.uopt;

		modes	= conditional(strcmp(u.analysis,'total'),obj.analyses,ForceCell(u.analysis));
		nMode	= numel(modes);

		for kMode=1:nMode
			strMode	= modes{kMode};

			switch strMode
				case 'alex'
					subjectStats.alexAccSubj	= analyzeTestSignalsModeAlex(obj,block,target,XTest,YTest,doDebug);
				case 'lizier'
					subjectStats.lizierTEs		= analyzeTestSignalsMultivariate(obj,block,target,XTest,YTest,'te',doDebug);
				case 'seth'
					subjectStats.sethGCs		= analyzeTestSignalsMultivariate(obj,block,target,XTest,YTest,'mvgc',doDebug);
				otherwise
					error('Bug: missing case for %s.',strMode);
			end
		end
	end

	function alexAccSubj = analyzeTestSignalsModeAlex(obj,~,target,XTest,YTest,doDebug)
		u		= obj.uopt;

		%unmix from voxel to "functional" space
		if u.doMixing
			nTRun	= numel(target{1});	%number of time points per run
			nT		= nTRun*u.nRun;		%total number of time points

			[~,XUnMix]	= pca(reshape(XTest,nT,u.nVoxel));
			XUnMix		= reshape(XUnMix,nTRun,u.nRun,u.nVoxel);

			[~,YUnMix]	= pca(reshape(YTest,nT,u.nVoxel));
			YUnMix		= reshape(YUnMix,nTRun,u.nRun,u.nVoxel);
		else
			[XUnMix,YUnMix]	= deal(XTest,YTest);
		end

		%keep the top nSigCause components
		XUnMix	= XUnMix(:,:,1:u.nSigCause);
		YUnMix	= YUnMix(:,:,1:u.nSigCause);

		%calculate W*
		%calculate the directed connectivity from X components to Y components for each
		%run and condition
		WStarA = calculateW_stars(obj,target,XUnMix,YUnMix,'A');
		WStarB = calculateW_stars(obj,target,XUnMix,YUnMix,'B');

		%classify between W*A and W*B
		[alexAccSubj,p_binom] = classifyBetweenWs(obj,WStarA,WStarB);

		if doDebug
			mWStarA	= mean(cat(3,WStarA{:}),3);
			mWStarB	= mean(cat(3,WStarB{:}),3);

			showTwoWs(obj,mWStarA,mWStarB,'W^*_A and W^*_B');
			fprintf('mean W*A column sums:  %s\n',sprintf('%.3f ',sum(mWStarA)));
			fprintf('mean W*B column sums:  %s\n',sprintf('%.3f ',sum(mWStarB)));
			fprintf('accuracy: %.2f%%\n',100*alexAccSubj);
			fprintf('p(binom): %.3f\n',p_binom);
		end
	end

	function causalities = analyzeTestSignalsMultivariate(obj,~,target,X,Y,kind,doDebug)
	%X,Y dims are time, run, signal
	%kind is causality kind ('mvgc', 'te')
	%return one causality for each condition
		u			= obj.uopt;
		conds		= {'A' 'B'};
		nCond		= numel(conds);
		causalities	= zeros(nCond,1);

		%concatenate data for all runs to create a single hypothetical megarun
		megatarget	= {cat(1,target{:})};
		megaX		= reshape(X,[],1,size(X,3));
		megaY		= reshape(Y,[],1,size(Y,3));

		for kC=1:nCond
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
				TE			= causalities(kC);
				fprintf('Multivariate TE X->Y for cond %s is %.6f\n',conds{kC},TE);
			end
		end
		if doDebug
			fprintf('\n%ss =\n\n',upper(kind));
			disp(causalities);
		end
	end

	function [sourceOut,destOut] = applyRecurrence(obj,sW,sourceIn,destIn,doDebug)
	% sourceIn and destIn are nSig x 1
		u	= obj.uopt;
		W	= sW.W;

		%do this so the recurrence works regardless of whether our Ws are
		%nSigCause x nSigCause or nSig x nSig with zeros for everything but the
		%causal signals
			nW			= size(W,1);
			nNoW		= u.nSig - nW;
			WStrength	= [reshape(sum(W,1),[],1); zeros(nNoW,1)];

		sourceNoise	= (1             - u.CRecur).*randn(u.nSig,1);
		destNoise	= (1 - WStrength - u.CRecur).*randn(u.nSig,1);

		sourceOut		= u.CRecur.*sourceIn + sourceNoise;
		destOut			= u.CRecur.*destIn   + destNoise;
		destOut(1:nW)	= destOut(1:nW) + W.'*sourceIn(1:nW);

		if doDebug
			coeffsumx		= u.CRecur.*ones(u.nSig,1) + (1             - u.CRecur);
			coeffsumy		= u.CRecur.*ones(u.nSig,1) + (1 - WStrength - u.CRecur);
			coeffsumy(1:nW)	= coeffsumy(1:nW) + W.'*ones(nW,1);
			errors		= abs([coeffsumx; coeffsumy] - 1);
			if any(errors > 1e-8)
				error('Coefficients do not add to one.');
			end
		end
	end

	function s = asString(~,value)
	% TODO: should be a function, not a method--but is there a nice built-in for this?
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

	function c = calculateCausality(obj,X,Y,indicesOfSamples,kind)
		u	= obj.uopt;
		if any(strcmp('fakecause',u.fudge))
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
				error('Unrecognized causality kind ''%s''',kind);
		end
	end

	function WStars = calculateW_stars(obj,target,X,Y,conditionName)
	%calculate the Causality from X components to Y components for each
	%run and for the specified condition
	% conditionName is 'A' or 'B'
		u		= obj.uopt;
		sigs	= extractSignalsForCondition(obj,target,X,Y,conditionName);
		WStars	= repmat({zeros(u.nSigCause)},[u.nRun 1]);

		for kR=1:u.nRun
			s	= sigs{kR};

			for kX=1:u.nSigCause
				X	= s.Xall(:,:,kX);

				for kY=1:u.nSigCause
					Y					= s.Yall(:,:,kY);
					WStars{kR}(kX,kY)	= calculateCausality(obj,X,Y,...
											s.kNext,u.WStarKind);
				end
			end
		end
	end

	function obj = changeDefaultsForBatchProcessing(obj)
		obj	= obj.changeOptionDefault('nofigures',true);
		obj	= obj.changeOptionDefault('nowarnings',true);
		obj	= obj.changeOptionDefault('progress',false);
	end

	function obj = changeDefaultsToDebug(obj)
		obj	= obj.changeOptionDefault('DEBUG',true);
		obj	= obj.changeSeedDefaultAndConsume(0);
	end

	function obj = changeOptionDefault(obj,optionName,newDefault)
		if ~ismember(optionName,obj.implicitOptionNames)
			error('Unrecognized option ''%s''',optionName);
		end
		if ~ismember(optionName,obj.explicitOptionNames)
			obj.uopt.(optionName)	= newDefault;
		end
	end

	function obj = changeSeedDefaultAndConsume(obj,seed)
		obj	= obj.changeOptionDefault('seed',seed);
		obj	= obj.consumeRandomizationSeed;
	end

	function [acc,p_binom] = classifyBetweenWs(obj,WAStar,WBStar)
		u	= obj.uopt;
		P	= cvpartition(u.nRun,'LeaveOut');

		WStar	= [WAStar; WBStar];
		WStar	= cellfun(@(W) reshape(W,1,[]),WStar,'uni',false);

		lblTrain	= reshape(repmat({'A' 'B'},[u.nRun-1 1]),[],1);
		lblTest		= {'A';'B'};

		res	= zeros(P.NumTestSets,1);
		for kP=1:P.NumTestSets
			kTrain	= repmat(P.training(kP),[2 1]);
			kTest	= repmat(P.test(kP),[2 1]);

			WTrain	= cat(1,WStar{kTrain});
			WTest	= cat(1,WStar{kTest});

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

	function obj = consumeRandomizationSeed(obj)
		if notfalse(obj.uopt.seed)
			rng(obj.uopt.seed,'twister');
		end
		obj.uopt.seed	= false;
	end

	function [array,cLabel,label2index,getfield] = convertPlotCapsuleResultToArray(obj,capsule)
	% TODO: Clean up.  This method's functionality should be made into
	% a separate class, whose methods would include something like
	% "getfield" (currently a return value), a label2index mapping method,
	% and something like constrainData (currently an inner function in
	% renderMultiLinePlot).
		u			= obj.uopt;
		result		= capsule.result;
		keys		= result{1}.keyTuple;
		keymaps		= arrayfun(@(k) {keys{k},@(r)forcenum(r.valueTuple{k})}, ...
						1:numel(keys),'uni',false);
		datamaps	= {	{'seed',			@(r)r.seed}, ...
						{'acc',				@(r)r.summary.alex.meanAccAllSubj}, ...
						{'stderr',			@(r)r.summary.alex.stderrAccAllSu}, ...
						{'alex_ci',			@get_alex_ci}, ...
						{'alex_ci_err',		@get_alex_ci_err}, ...
						{'alex_log10_p',	@get_alex_log10_p}, ...
						{'alex_p',			@(r)r.summary.alex.p}, ...
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

		function x = bound_to_unit_interval(x)
			x	= min(max(0,x),1); % Note: maps NaN to zero
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

		function val = get_alex_ci(r)
			ci	= bound_to_unit_interval(r.summary.alex.ci);
			val	= mean(ci);
		end

		function err = get_alex_ci_err(r)
			ci	= bound_to_unit_interval(r.summary.alex.ci);
			err	= (ci(2)-ci(1))/2;
		end

		function val = get_alex_log10_p(r)
			p	= max(u.min_p,min(r.summary.alex.p,1)); % Note: maps NaN to 1
			val	= log(p)/log(10);
		end

		function index = getLabelIndex(label)
			index	= find(strcmp(label,cLabel));
			if ~isscalar(index)
				error('Invalid or non-unique label ''%s''',label);
			end
		end

		function values = getSubarrayForLabel(label,data)
			shape		= size(data);
			subshape	= shape(1:end-1);
			if strcmp(label,'zeros')
				values	= zeros(subshape);
			else
				index	= getLabelIndex(label);
				data	= shiftdim(data,numel(keys));
				values	= reshape(data(index,:),subshape);
			end
		end
	end

	function signals = extractSignalsForCondition(~,target,X,Y,conditionName)
	% TODO: clean up comments
	% X,Y dims are [time, run, signal].
	% conditionName is 'A' or 'B'
	%
	% Return cell array indexed by run.  Each cell holds a struct with
	%   k,X,Y corresponding to specified condition. Dimensions of these signal
	%   slices are [time, 1, signal].
		nRun	= numel(target);
		signals = cell(nRun,1);

		for kR=1:nRun
			bCondition	= strcmp(target{kR},conditionName);
			bShift		= [0; bCondition(1:end-1)];
			sigs.kNext	= find(bShift);
			sigs.Xall	= X(:,kR,:);
			sigs.Yall	= Y(:,kR,:);
			signals{kR}	= sigs;
		end
	end

	function domainValue = findThreshold(obj,varargin)
	%Find min v in varDomain such that fn(v) <= goal
	%It is assumed that varDomain is monotonically increasing
	%It is assumed that fn is monotonically nonincreasing
	%
	% Sample quick test:
	%>> p=Pipeline('nSubject',2,'nRun',5,'nTBlock',2);
	%>> d=p.findThreshold
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
		u				= obj.uopt;
		nTRun			= numel(target{1});	%number of time points per run

		[X,Y]	= deal(zeros(nTRun,u.nRun,u.nSig));

		for kR=1:u.nRun
			%initial causality matrix
			sW.W	= sW.WBlank;

			%generate each sample
			for kT=1:nTRun
				%previous values
				if kT==1
					xPrev	= randn(u.nSig,1);
					yPrev	= randn(u.nSig,1);
				else
					xPrev	= squeeze(X(kT-1,kR,:));
					yPrev	= squeeze(Y(kT-1,kR,:));
				end

				%X=source, Y=destination
				[X(kT,kR,:),Y(kT,kR,:)]	= applyRecurrence(obj,sW,xPrev,yPrev,doDebug);

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

		%set the SNR as specified
			X	= setSignalSNR(obj,X,doDebug);
			Y	= setSignalSNR(obj,Y,doDebug);

		if doDebug
			showFunctionalSigStats(obj,X,Y);
			showSigPlot(obj,X,Y,block,'Functional');
		end
	end

	function [X,Y] = generateSignalsWithOptions(obj,block,target,sW,doDebug)
		u		= obj.uopt;

		%generate the functional signals
		[X,Y]	= generateFunctionalSignals(obj,block,target,sW,doDebug);

		%mix between voxels (if applicable)
		if u.doMixing
			X	= mapToVoxels(X);
			Y	= mapToVoxels(Y);

			if doDebug
				showSigPlot(obj,X,Y,block,'Mixed Voxel');
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
			n1		= size(C,1);
			nCol	= numel(C)/n1;

			for kCol=1:nCol
				C_hat		= conv(C(:,kCol),kernel);
				C(:,kCol)	= C_hat(1:n1);
			end
		end

		function S = mapToVoxels(S)
		% Dimensions of S are (time,run,sig)
			[nTRun,nRun,nSig]	= size(S);
			nT					= nTRun * nRun;

			S	= reshape(S,nT,nSig);
			S	= S*randn(nSig,u.nVoxel);
			S	= reshape(S,nTRun,nRun,u.nVoxel);
		end
	end

	function sW = generateStructOfWs(obj,doDebug)
		u	= obj.uopt;

		cName	= {'A';'B';'Blank'};
		cNameW	= cellfun(@(n) sprintf('W%s',n),cName,'uni',false);
		nW		= numel(cNameW);

		cW	= arrayfun(@(k) generateW(obj),(1:nW)','uni',false);

		sW	= cell2struct(cW,cNameW);

		if doDebug
			showTwoWs(obj,sW.WA,sW.WB,'W_A and W_B');

			fprintf('WA column sums:  %s\n',sprintf('%.3f ',sum(sW.WA)));
			fprintf('WB column sums:  %s\n',sprintf('%.3f ',sum(sW.WB)));

			fprintf('sum(WA)+CRecur: %s\n',sprintf('%.3f ',sum(sW.WA)+u.CRecur));
			fprintf('sum(WB)+CRecur: %s\n',sprintf('%.3f ',sum(sW.WB)+u.CRecur));
		end
	end

	function W = generateW(obj)
		u	= obj.uopt;

		%generate a random W
			W	= rand(u.nSigCause);
		%make it sparse
			W(W>u.WFullness)	= 0;
		%normalize each column to the specified strength (i.e. sum)
			WSum		= repmat(sum(W,1),[u.nSigCause 1]);
			W			= W*u.WStrength./WSum;
			W(isnan(W))	= 0;
	end

	function label = getOptLabel(obj,optName)
		label	= switch2(optName,...
					'acc'			, 'Accuracy (%)'				, ...
					'alex_log10_p'	, 'log_{10}(p)'					, ...
					getOptNameSpelledOut(obj,optName)...
					);
	end

	function label = getOptNameSpelledOut(~,optName)
		label	= switch2(optName,...
					'acc'			, 'Accuracy'					, ...
					'alex_ci'		, 'Alex t-test CI'				, ...
					'alex_log10_p'	, 'Logarithm of p-value'		, ...
					'alex_p'		, 'Classification p-value'		, ...
					'nRepBlock'		, 'Number of blocks per run'	, ...
					'nRun'			, 'Number of runs'				, ...
					'nSubject'		, 'Number of subjects'			, ...
					'nTBlock'		, 'Number of TRs per block'		, ...
					'SNR'			, 'Signal-to-noise ratio'		, ...
					'WFullness'		, 'W fullness'					, ...
					'WStrength'		, 'W strength'					, ...
					optName...
					);
	end

	function capsule = makePlotCapsule(obj,plotSpec,varargin)
	%TODO: comments
		obj					= consumeRandomizationSeed(obj);
		plotSpec			= regularizePlotSpec(obj,plotSpec);
		obj.uopt.nIteration	= plotSpec.nIteration; % For benefit of noteMiscOpts

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
		names		= [obj.notableOptionNames; obj.unlikelyOptionNames];
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
		binding{end+1}	= sprintf('vdata-vplot=%.2f-%07.2f', ...
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
			elseif ~isvector(plotSpec.varName) || ~isvector(plotSpec.varValues)
				error('Plot-spec varName and varValues cells must be nonempty vectors.');
			elseif numel(plotSpec.varName) ~= numel(plotSpec.varValues)
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
			'fixedVarValuePairs'	, {}				, ...
			'constLabelValuePairs'	, {}				  ...
			);
		%earliestCompatibleFormat	= obj.version.capsuleFormat;
		earliestCompatibleFormat	= 20150423;
		if ~isfield(capsule,'version') || ...
				~isfield(capsule.version,'capsuleFormat') || ...
				capsule.version.capsuleFormat < earliestCompatibleFormat
			error('Incompatible capsule format.');
		end
		if capsule.version.capsuleFormat < 20150514
			% temp kludge for noteMiscOpts (TODO: remove in future)
			capsule.uopt.nIteration	= capsule.plotSpec.nIteration;
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
		constLabels				= opt.constLabelValuePairs(1:2:end);
		constValues				= opt.constLabelValuePairs(2:2:end);
		nConst					= numel(constLabels);
		if nConst ~= numel(constValues) || ~all(cellfun(@ischar,constLabels))
			error('Ill-formed constLabelValuePairs.');
		end

		[data,cLabel,label2index,getfield]	= ...
				convertPlotCapsuleResultToArray(obj,capsule);
		for kFV=1:numel(fixedVars)
			data	= constrainData(data,fixedVars{kFV},fixedVarValues{kFV});
		end
		getyval		= @(d)getfield(yVarName,d);
		geterror	= @(d)stderr(getyval(d),1);
		if strcmp(yVarName,'acc')
			getyval		= @(d)100*getfield(yVarName,d); % Percentage
			geterror	= @(d)100*getfield('stderr',d); % Percentage
		elseif strcmp(yVarName,'alex_ci')
			geterror	= @(d)getfield('alex_ci_err',d);
		end
		[xvals,yvals,errorvals]	= deal(cell(1,nPlotLine+nConst));
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
			yvals{kPL}		= squeeze(mean(getyval(plData),1));
			errorvals{kPL}	= squeeze(mean(geterror(plData),1));
		end

		constLineIdx				= nPlotLine + (1:nConst);
		allDataX					= getfield(xVarName,data);
		[xvals{constLineIdx}]		= deal([min(allDataX(:)),max(allDataX(:))]);
		yvals(constLineIdx)			= cellfun(@(v) [v v],constValues,'uni',false);
		[errorvals{constLineIdx}]	= deal([0 0]);

		parennote	= noteFixedVars(obj,fixedVars,fixedVarValues);
		if ~isempty(parennote)
			parennote	= sprintf(' (%s)',parennote);
		end
		xlabelStr	= getOptLabel(obj,xVarName);
		ylabelStr	= getOptLabel(obj,yVarName);
		yVarInTitle	= getOptNameSpelledOut(obj,yVarName);
		titleStr	= sprintf('%s vs %s%s',yVarInTitle,xVarName,parennote);
		cLegend		= [opt.lineLabels(:); constLabels(:)];
		h			= alexplot(xvals,yvals,...
						'error'		, errorvals			, ...
						'title'		, titleStr			, ...
						'xlabel'	, xlabelStr			, ...
						'ylabel'	, ylabelStr			, ...
						'legend'	, cLegend			, ...
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

		function subdata = constrainData(data,varName,varValue)
		% constrainData: See also comments at convertPlotCapsuleResultToArray.
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

	function X = setSignalSNR(obj,X,doDebug)
	% setSignalSNR
	%
	% Description:	multiply the signal amplitudes to achieve the specified SNR
	%	between causal ("signal") and non-causal ("noise") signals
	%
	% Syntax:	X = setSignalSNR(obj,X,doDebug)
	%
	% In:
	%	obj		- the Pipeline object
	%	X		- the nTRun x nRun x nSignal multidimensional signal
	%	doDebug	- true to run debug code
	%
	% Out:
	%	X	- the multidimensional signal with causal and non-causal components
	%		  multiplied by appropriate coefficients to achieve the specified
	%		  SNR
	%
	% Notes:
	%	we use the definition of SNR as the ratio of signal powers (P_c/P_nc),
	%	i.e. ratio of squares of RMS amplitudes. here, since we have
	%	multidimensional signals, RMS amplitude is the sqrt of the mean of the
	%	squares of the multidimensional signal magnitudes (i.e. L2-norms). so:
	%    SNR = P_c / P_nc
	% where:
	%    P(X)    = A(X)^2                     [X is an N-dimensional signal]
	%    A(X)    = sqrt(mean( Norm(X_t)^2 ))  [X_t is one sample of signal X]
	%    Norm(s) = sqrt(sum( s_k^2 ))         [s_k is one element of sample s]
	%            = std(s) * sqrt(N)           [for 0-mean signals]
	%
	%	we first z-score each univariate signal independently to make sure they
	%	start off on equal footing. then we multiply the causal signals by a_c
	%	and the non-causal signals by a_nc, so that:
	%    Norm(s) = a*sqrt(N)                  [std(s) is 1 since we z-scored]
	% => A(X)    = sqrt(mean( (a*sqrt(N))^2 ))
	%            = a*sqrt(N)
	% => P(X)    = a^2*N
	% => SNR     = ( a_c^2*N_c ) / ( a_nc^2*N_nc )
	% => a_nc    = a_c * sqrt( N_c / ( SNR * N_nc ) )
		u				= obj.uopt;
		nSigNonCause	= u.nSig - u.nSigCause;

		%z-score each univariate signal
			X	= zscore(X,1,1);
		%calculate the amplitude multipliers as described above
			a_c		= 1;
			a_nc	= a_c * sqrt( u.nSigCause ./ (u.SNR .* nSigNonCause) );
		%multiply by causal and non-causal amplitudes
			X(:,:,1:u.nSigCause)		= a_c .*X(:,:,1:u.nSigCause);
			X(:,:,u.nSigCause+1:end)	= a_nc.*X(:,:,u.nSigCause+1:end);

		if doDebug
			%verify the SNR
				fNorm	= @(x) sqrt(sum(x.^2,3));
				fRMS	= @(x) sqrt(mean(fNorm(x).^2,1));
				fSNR	= @(x,n) (fRMS(x) ./ fRMS(n)).^2;

				snr	= fSNR(X(:,:,1:u.nSigCause),X(:,:,u.nSigCause+1:end));

				assert(all(isnan(snr) | (abs(snr-u.SNR) < 1e-8)),'SNR not as specified');
			%verify equivalence to variance-based definition of SNR
				fWtVar	= @(x) cellfun(@(r) size(r,3)*var(r(:),1),num2cell(x,[1 3]));
				vsnr	= fWtVar(X(:,:,1:u.nSigCause)) ./ fWtVar(X(:,:,u.nSigCause+1:end));

				assert(all(isnan(vsnr) | (abs(vsnr-u.SNR) < 1e-8)),'Unexpected SNR behavior');
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

		strTitle	= sprintf('%s (Run 1, Signal 1)',kindOfSig);
		h			= alexplot(tPlot,{xPlot yPlot},...
						'title'		, strTitle		, ...
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
		if any(cellfun(@(p) isnumeric(p) && any(isnan(p(:))),struct2cell(u)))
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
			%summary.alex.meanAccAllSubj	= u.WStrength;
			%summary.alex.stderrAccAllSu	= 0.1*u.CRecur;
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
		if u.progress
			progresstypes	= {'figure','commandline'};
			progress(...
						'action'	, 'init'						, ...
						'total'		, u.nSubject					, ...
						'label'		, 'simulating each subject'		, ...
						'type'		, progresstypes{1+u.nofigures}	  ...
					);
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
			summary.subjectResults		= results;
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
	function plot_data = constructTestPlotData(varargin)
	% constructTestPlotData
	%
	% Quick test:
	%  pd=Pipeline.constructTestPlotData('fudge',{'stubsim'})
	%  cH=Pipeline.constructTestPlotsFromData(pd)
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsForBatchProcessing;
		pipeline	= pipeline.changeOptionDefault('nSubject',10);
		pipeline	= pipeline.changeOptionDefault('analysis','alex');
		pipeline	= pipeline.changeSeedDefaultAndConsume(0);

		spec				= repmat(struct,4,1);

		spec(1).varName		= {'WStrength','CRecur','WStrengthFrac'};
		spec(1).varValues	= {NaN,[0 0.35 0.7],(0:0.05:0.3)/0.3};
		spec(1).pseudoVar	= 'WStrengthFrac';
		spec(1).transform	= @(~,CRecur,WStrengthFrac) deal(...
								WStrengthFrac*(1-CRecur),CRecur,WStrengthFrac);

		spec(2).varName		= {'WFullness','CRecur'};
		spec(2).varValues	= {0.1:0.2:0.9,[0 0.35 0.7]};

		spec(3).varName		= {'nTBlock','CRecur'};
		spec(3).varValues	= {1:5,[0 0.35 0.7]};

		spec(4).varName		= {'SNR','CRecur'};
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
		%save([filename_prefix '_recur_plot_data.mat'],'plot_data');
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

	function pipeline = createDebugPipeline(varargin)
	% createDebugPipeline - static method for creating debug-pipeline
	%
	% Syntax:	pipeline = Pipeline.createDebugPipeline(<options>)
	%
	% In:
	%	<options>:
	%		See Pipeline constructor above for description of <options>,
	%		but note that this method overrides the default debugging options
	%
		pipeline	= Pipeline(varargin{:});
		pipeline	= pipeline.changeDefaultsToDebug;
	end

	function summary = debugSimulation(varargin)
	% debugSimulation - static method for running debug-pipeline
	%
	% Syntax:	summary = Pipeline.debugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		summary		= pipeline.simulateAllSubjects;
	end

	function summary = runSimulation(varargin)
	% runSimulation - static method for running pipeline
	%
	% Syntax:	summary = Pipeline.runSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See Pipeline constructor above for description of <options>
	%
		pipeline	= Pipeline(varargin{:});
		summary		= pipeline.simulateAllSubjects;
	end

	function summary = speedupDebugSimulation(varargin)
	% speedupDebugSimulation - static method for running sped-up
	%                          debug-pipeline
	%
	% Syntax:	summary = Pipeline.speedupDebugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		pipeline	= pipeline.changeOptionDefault('nSubject',...
						ceil(pipeline.uopt.nSubject/3));
		pipeline	= pipeline.changeOptionDefault('nofigures',true);
		summary		= pipeline.simulateAllSubjects;
	end

	function summary = textOnlyDebugSimulation(varargin)
	% textOnlyDebugSimulation - static method for running figure-free
	%                           debug-pipeline
	%
	% Syntax:	summary = Pipeline.textOnlyDebugSimulation(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
		pipeline	= Pipeline.createDebugPipeline(varargin{:});
		pipeline	= pipeline.changeOptionDefault('nofigures',true);
		summary		= pipeline.simulateAllSubjects;
	end
end

end
