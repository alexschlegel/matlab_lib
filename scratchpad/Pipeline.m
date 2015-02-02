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


% Simplest invocation (as of 2015-01-22):  Pipeline.debugTrainClassify;
% use "Pipeline.runTrainClassify" to randomize behavior and suppress
% diagnostic output.
%

properties
	uopt
end
properties (SetAccess = private)
	explicitOptionNames
end

methods
	% Pipeline - Constructor for Pipeline class
	%
	% Syntax:	pipeline = Pipeline(<options>)
	%
	% In:
	%	<options>:
	%					-- Debugging options:
	%
	%		DEBUG		(false) Display debugging information
	%		seed:		(randseed2) the seed to use for randomizing
	%		szIm:		(200) pixel height of debug images
	%
	%					-- Subjects
	%
	%		nSubject	(20) number of subjects
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
	%		WFullness:	(0.1) fullness of W matrices
	%		WSum:		(0.1) sum of W columns (sum(W)/sqrt(nSigCause)+CRecurY/X must be <=1)
	%
	%					-- Mixing:
	%
	%		doMixing:	(true) should we even mix into voxels?
	%		noiseMix:	(0.1) magnitude of noise introduced in the voxel mixing
	%
	function obj = Pipeline(varargin)
		%user-defined parameters (with defaults)
		opt	= ParseArgs(varargin,...
			'DEBUG'		, false		, ...
			'seed'		, randseed2	, ...
			'szIm'		, 200		, ...
			'nSubject'	, 20		, ...
			'nSig'		, 10		, ...
			'nSigCause'	, 10		, ...
			'nVoxel'	, 100		, ...
			'nTBlock'	, 1			, ...
			'nTRest'	, 4			, ...
			'nRepBlock'	, 20		, ...
			'nRun'		, 10		, ...
			'CRecurX'	, 0.1		, ...
			'CRecurY'	, 0.7		, ...
			'CRecurZ'	, 0.5		, ...
			'WFullness'	, 0.1		, ...
			'WSum'		, 0.1		, ...
			'doMixing'	, true		, ...
			'noiseMix'	, 0.1	  ...
			);
		obj.uopt				= opt;
		obj.explicitOptionNames	= varargin(1:2:end);
	end

	function obj = changeDefaultsToDebug(obj)
		obj = obj.changeOptionDefault('DEBUG',true);
		obj = obj.changeOptionDefault('seed',0);
	end

	function obj = changeOptionDefault(obj,optionName,newDefault)
		if ~ismember(optionName,obj.explicitOptionNames)
			obj.uopt.(optionName)	= newDefault;
		end
	end

	function accSubj = subjectTrainClassify(obj,doDebug)
		u		= obj.uopt;

%TODO: Fix indentation throughout


%the two causality matrices (and other control causality matrices)
	nW				= 4;
	[cWCause,cW]	= deal(cell(nW,1));

	for kW=1:nW
		%generate a random W
			W					= rand(u.nSigCause);
		%make it sparse
			W(1-W>u.WFullness)	= 0;
		%normalize each column to the specified mean
			W			= W*u.WSum./repmat(sum(W,1),[u.nSigCause 1]);
			W(isnan(W))	= 0;

		cWCause{kW}	= W;

		%insert into the full matrix
		cW{kW}							= zeros(u.nSig);
		cW{kW}(1:u.nSigCause,1:u.nSigCause)	= cWCause{kW};
	end

	[WACause,WBCause,WBlankCause,WZCause]	= deal(cWCause{:});
	[WA,WB,WBlank,WZ]						= deal(cW{:});

	if doDebug
		imDims	= [u.szIm NaN];
		graySeparator	= 0.8*ones(u.szIm,round(1.5*u.szIm/u.nSigCause));

		im	= normalize([WACause WBCause]);
		im	= [imresize(im(:,1:u.nSigCause),imDims,'nearest') graySeparator imresize(im(:,u.nSigCause+1:end),imDims,'nearest')];
		figure; imshow(im);
		title('W_A and W_B');

		im	= normalize([WBlankCause WZCause]);
		im	= [imresize(im(:,1:u.nSigCause),imDims,'nearest') graySeparator imresize(im(:,u.nSigCause+1:end),imDims,'nearest')];
		figure; imshow(im);
		title('W_{blank} and W_Z');

		fprintf('WA column sums:  %s\n',sprintf('%.3f ',sum(WACause)));
		fprintf('WB column sums:  %s\n',sprintf('%.3f ',sum(WBCause)));
		fprintf('sum(WA)+CRecurY: %s\n',sprintf('%.3f ',sum(WACause)+u.CRecurY));
		fprintf('sum(WB)+CRecurY: %s\n',sprintf('%.3f ',sum(WBCause)+u.CRecurY));
	end

%derived parameters
	%block design
		designSeed = randi(intmax('uint32'));
		rngState = rng;
		block	= blockdesign(1:2,u.nRepBlock,u.nRun,'seed',designSeed);
		rng(rngState);
		target	= arrayfun(@(run) block2target(block(run,:),u.nTBlock,u.nTRest,{'A','B'}),reshape(1:u.nRun,[],1),'uni',false);

	%number of time points per run
		nTRun	= numel(target{1});
	%total number of time points
		nT		= nTRun*u.nRun;

	if doDebug
		fprintf('TRs per run: %d\n',nTRun);

		figure;
		imagesc(block);
		colormap('gray');
		title('block design (blk=A, wht=B)');
		xlabel('block');
		ylabel('run');
	end

%generate the functional signals
	[X,Y]	= deal(zeros(nTRun,u.nRun,u.nSig));
	Z		= zeros(nTRun,u.nRun,u.nSig,u.nSig);

	for kR=1:u.nRun
		W	= WBlank;
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

			%pre-source
				Z(kT,kR,:,:)	= u.CRecurZ.*zPrev + (1-u.CRecurZ).*randn(u.nSig,u.nSig);
			%source
				X(kT,kR,:)		= u.CRecurX.*xPrev + sum(WZ'.*zPrev,2) + (1-u.WSum/sqrt(u.nSigCause)-u.CRecurX).*randn(u.nSig,1);
			%destination
				Y(kT,kR,:)		= u.CRecurY.*yPrev + W'*xPrev + (1-u.WSum/sqrt(u.nSigCause)-u.CRecurY).*randn(u.nSig,1);

			%causality matrix for the next sample
				switch target{kR}{kT}
					case 'A'
						W	= WA;
					case 'B'
						W	= WB;
					otherwise
						W	= WBlank;
				end
		end
	end

	if doDebug
		XCause	= X(:,:,1:u.nSigCause);
		YCause	= Y(:,:,1:u.nSigCause);

		%cMeasure	= {'mean','range','std','std(d/dx)'};
		cFMeasure	= {@mean,@range,@std,@(x) std(diff(x))};

		cXMeasure	= cellfun(@(f) f(reshape(permute(XCause,[1 3 2]),nTRun*u.nSigCause,u.nRun)),cFMeasure,'uni',false);
		cYMeasure	= cellfun(@(f) f(reshape(permute(YCause,[1 3 2]),nTRun*u.nSigCause,u.nRun)),cFMeasure,'uni',false);

		cXMMeasure	= cellfun(@mean,cXMeasure,'uni',false);
		cYMMeasure	= cellfun(@mean,cYMeasure,'uni',false);

		%[h,p,ci,kstats]	= cellfun(@ttest2,cXMeasure,cYMeasure,'uni',false);
		[~,p,~,kstats]	= cellfun(@ttest2,cXMeasure,cYMeasure,'uni',false);
		tstat			= cellfun(@(s) s.tstat,kstats,'uni',false);

		fprintf('XCause mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',cXMMeasure{:});
		fprintf('YCause mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',cYMMeasure{:});
		fprintf('p      mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',p{:});
		fprintf('tstat  mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f\n',tstat{:});
	end

	if doDebug
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

%mix between voxels
	if u.doMixing
		XMix	= reshape(reshape(X,nT,u.nSig)*randn(u.nSig,u.nVoxel),nTRun,u.nRun,u.nVoxel) + u.noiseMix*randn(nTRun,u.nRun,u.nVoxel);
		YMix	= reshape(reshape(Y,nT,u.nSig)*randn(u.nSig,u.nVoxel),nTRun,u.nRun,u.nVoxel) + u.noiseMix*randn(nTRun,u.nRun,u.nVoxel);
	end

%unmix and keep the top nSigCause components
	if u.doMixing
		%[CPCAX,XUnMix]	= pca(reshape(XMix,nT,u.nVoxel));
		[~,XUnMix]	= pca(reshape(XMix,nT,u.nVoxel));
		XUnMix			= reshape(XUnMix,nTRun,u.nRun,u.nVoxel);

		%[CPCAY,YUnMix]	= pca(reshape(YMix,nT,u.nVoxel));
		[~,YUnMix]	= pca(reshape(YMix,nT,u.nVoxel));
		YUnMix			= reshape(YUnMix,nTRun,u.nRun,u.nVoxel);
	else
		[XUnMix,YUnMix]	= deal(X,Y);
	end

	XUnMix	= XUnMix(:,:,1:u.nSigCause);
	YUnMix	= YUnMix(:,:,1:u.nSigCause);

%calculate W*
	%calculate the Granger Causality from X components to Y components for each
	%run and condition
		[WAs,WBs]	= deal(repmat({zeros(u.nSigCause)},[u.nRun 1]));

		for kR=1:u.nRun
			kALag	= find(strcmp(target{kR},'A'));
			kBLag	= find(strcmp(target{kR},'B'));

			kA	= kALag + 1;
			kB	= kBLag + 1;

			for kX=1:u.nSigCause
				XA		= XUnMix(kA,kR,kX);
				XB		= XUnMix(kB,kR,kX);
				XALag	= XUnMix(kALag,kR,kX);
				XBLag	= XUnMix(kBLag,kR,kX);

				for kY=1:u.nSigCause
					YA		= YUnMix(kA,kR,kY);
					YB		= YUnMix(kB,kR,kY);
					YALag	= YUnMix(kALag,kR,kY);
					YBLag	= YUnMix(kBLag,kR,kY);

					WAs{kR}(kX,kY)	= GrangerCausality(XA,YA,...
										'src_past'	, XALag	, ...
										'dst_past'	, YALag	  ...
										);

					WBs{kR}(kX,kY)	= GrangerCausality(XB,YB,...
										'src_past'	, XBLag	, ...
										'dst_past'	, YBLag	  ...
										);
				end
			end
		end

	if doDebug
		mWAs	= mean(cat(3,WAs{:}),3);
		mWBs	= mean(cat(3,WBs{:}),3);

		im	= normalize([mWAs mWBs]);
		im	= [imresize(im(:,1:u.nSigCause),imDims,'nearest') graySeparator imresize(im(:,u.nSigCause+1:end),imDims,'nearest')];
		figure; imshow(im);
		title('W^*_A and W^*_B');

		fprintf('mean W*A column sums:  %s\n',sprintf('%.3f ',sum(mWAs)));
		fprintf('mean W*B column sums:  %s\n',sprintf('%.3f ',sum(mWBs)));
	end

%classify between W*A and W*B
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
		accSubj	= Xbin/Nbin;

	if doDebug
		fprintf('accuracy: %.2f%%\n',100*accSubj);
		fprintf('p(binom): %.3f\n',p_binom);
	end
	end

	function [meanAcc,stats,p_grouplevel] = trainClassify(obj)
		u		= obj.uopt;
		DEBUG	= u.DEBUG;

%initialize pseudo-random-number generator
	rng(u.seed,'twister');

%run each subject
	acc	= NaN(u.nSubject,1);

	progress(u.nSubject,'label','simulating each subject');
	for kS=1:u.nSubject
		doDebug	= DEBUG && kS==1;
		acc(kS)	= subjectTrainClassify(obj,doDebug);

	progress;
	end

	%evaluate the classifier accuracies
		%[h,p_grouplevel,ci,stats]	= ttest(acc,0.5,'tail','right');
		[~,p_grouplevel,~,stats]	= ttest(acc,0.5,'tail','right');

		meanAcc	= mean(acc);
		if DEBUG
			fprintf('mean accuracy: %.2f%%\n',100*meanAcc);
			fprintf('group-level: t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p_grouplevel);
		end
	end
end
methods (Static)
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
		pipeline = Pipeline(varargin{:});
		pipeline = pipeline.changeDefaultsToDebug;
	end

	% debugTrainClassify - static method for running debug-pipeline
	%
	% Syntax:	[meanAcc,stats,p_grouplevel] = ...
	%				Pipeline.debugTrainClassify(<options>)
	%
	% In:
	%	<options>:
	%		See createDebugPipeline above for description of <options>
	%
	function [meanAcc,stats,p_grouplevel] = debugTrainClassify(varargin)
		pipeline = Pipeline.createDebugPipeline(varargin{:});
		[meanAcc,stats,p_grouplevel] = pipeline.trainClassify;
	end

	% runTrainClassify - static method for running pipeline
	%
	% Syntax:	[meanAcc,stats,p_grouplevel] = ...
	%				Pipeline.runTrainClassify(<options>)
	%
	% In:
	%	<options>:
	%		See Pipeline constructor above for description of <options>
	%
	function [meanAcc,stats,p_grouplevel] = runTrainClassify(varargin)
		pipeline = Pipeline(varargin{:});
		[meanAcc,stats,p_grouplevel] = pipeline.trainClassify;
	end
end
end
