% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.
%
% This class is a reworking of Alex's script 20150116_alex_tests.m
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

properties
	uopt
end
properties (SetAccess = private)
end

methods
	% Pipeline - Constructor for Pipeline class
	%
	% Syntax:	p = Pipeline(<options>)
	%
	% In:
	%	<options>:
	%					-- Size of the various spaces:
	%
	%		nSig:		(10) total number of functional signals
	%		nSigCause:	(10) number of functional signals of X that cause Y
	%		nVoxel:		(100) number of voxels into which the functional components are mixed
	%
	%					-- Time:
	%
	%		nTBlock:	(20) number of time points per block
	%		nTRest:		(5) number of time points per rest periods
	%		nRepBlock:	(3) number of repetitions of each block per run
	%		nRun:		(10) number of runs
	%
	%					-- Signal characteristics:
	%
	%		CRecurX:	(0.1) recurrence coefficient (should be <= 1)
	%		CRecurY:	(0.7) recurrence coefficient (should be <= 1)
	%		CRecurZ:	(0)   recurrence coefficient (should be <= 1)
	%		WFullness:	(0.1) fullness of W matrices
	%		WSum:		(0.1) sum of W columns (sum(W)/sqrt(nSigCause)+CRecurY/X must be <=1)
	%
	%					-- Mixing:
	%
	%		doMixing:	(true) should we even mix into voxels?
	%		noiseMix:	(0.1) magnitude of noise introduced in the voxel mixing
	%
	function p = Pipeline(varargin)
		%user-defined parameters (with defaults)
		opt	= ParseArgs(varargin,...
			'nSig'		, 10	, ...
			'nSigCause'	, 10	, ...
			'nVoxel'	, 100	, ...
			'nTBlock'	, 20	, ...
			'nTRest'	, 5		, ...
			'nRepBlock'	, 3		, ...
			'nRun'		, 10	, ...
			'CRecurX'	, 0.1	, ...
			'CRecurY'	, 0.7	, ...
			'CRecurZ'	, 0		, ...
			'WFullness'	, 0.1	, ...
			'WSum'		, 0.1	, ...
			'doMixing'	, true	, ...
			'noiseMix'	, 0.1	  ...
			);
		p.uopt = opt;
	end

	function runSim(p)
		u = p.uopt;

%TODO: Fix indentation throughout

DEBUG	= true;

%for debugging, make behavior reproducible, otherwise randomize
	seeds			= [0 randseed2];
	rng(seeds([DEBUG ~DEBUG]),'twister');

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
	
	if DEBUG
		szIm	= 200;
		
		im	= normalize([WACause WBCause]);
		im	= [imresize(im(:,1:u.nSigCause),[szIm NaN],'nearest') 0.8*ones(szIm,round(200/u.nSigCause)) imresize(im(:,u.nSigCause+1:end),[szIm NaN],'nearest')];
		figure; imshow(im);
		title('W_A and W_B');
		
		im	= normalize([WBlankCause WZCause]);
		im	= [imresize(im(:,1:u.nSigCause),[szIm NaN],'nearest') 0.8*ones(szIm,round(200/u.nSigCause)) imresize(im(:,u.nSigCause+1:end),[szIm NaN],'nearest')];
		figure; imshow(im);
		title('W_{blank} and W_Z');
		
		disp(sprintf('WA column sums:  %s',sprintf('%.3f ',sum(WACause))));
		disp(sprintf('WB column sums:  %s',sprintf('%.3f ',sum(WBCause))));
		disp(sprintf('sum(WA)+CRecurY: %s',sprintf('%.3f ',sum(WACause)+u.CRecurY)));
		disp(sprintf('sum(WB)+CRecurY: %s',sprintf('%.3f ',sum(WBCause)+u.CRecurY)));
	end

%derived parameters
	%block design
		rngState = rng;
		block	= blockdesign(1:2,u.nRepBlock,u.nRun,'seed',rngState.Seed+1);
		rng(rngState);
		target	= arrayfun(@(run) block2target(block(run,:),u.nTBlock,u.nTRest,{'A','B'}),reshape(1:u.nRun,[],1),'uni',false);
	
	%number of time points per run
		nTRun	= numel(target{1});
	%total number of time points
		nT		= nTRun*u.nRun;
	
	if DEBUG
		disp(sprintf('TRs per run: %d',nTRun)); 

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
			%current causality matrix
				switch target{kR}{kT}
					case 'A'
						W	= WA;
					case 'B'
						W	= WB;
					otherwise
						W	= WBlank;
				end
			
			%pre-source
				Z(kT,kR,:,:)	= u.CRecurZ.*zPrev + (1-u.CRecurZ).*randn(u.nSig,u.nSig);
			%source
				X(kT,kR,:)		= u.CRecurX.*xPrev + sum(WZ'.*zPrev,2) + (1-u.WSum/sqrt(u.nSigCause)-u.CRecurX).*randn(u.nSig,1);
			%destination
				Y(kT,kR,:)		= u.CRecurY.*yPrev + W'*xPrev + (1-u.WSum/sqrt(u.nSigCause)-u.CRecurY).*randn(u.nSig,1);
		end
	end
	
	if DEBUG
		XCause	= X(:,:,1:u.nSigCause);
		YCause	= Y(:,:,1:u.nSigCause);
		
		cMeasure	= {'mean','range','std','std(d/dx)'};
		cFMeasure	= {@mean,@range,@std,@(x) std(diff(x))};
		
		cXMeasure	= cellfun(@(f) f(reshape(permute(XCause,[1 3 2]),nTRun*u.nSigCause,u.nRun)),cFMeasure,'uni',false);
		cYMeasure	= cellfun(@(f) f(reshape(permute(YCause,[1 3 2]),nTRun*u.nSigCause,u.nRun)),cFMeasure,'uni',false);
		
		cXMMeasure	= cellfun(@mean,cXMeasure,'uni',false);
		cYMMeasure	= cellfun(@mean,cYMeasure,'uni',false);
		
		[h,p,ci,stats]	= cellfun(@ttest2,cXMeasure,cYMeasure,'uni',false);
		tstat			= cellfun(@(s) s.tstat,stats,'uni',false);
		
		disp(sprintf('XCause mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f',cXMMeasure{:}));
		disp(sprintf('YCause mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f',cYMMeasure{:}));
		disp(sprintf('p      mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f',p{:}));
		disp(sprintf('tstat  mean/range/std/std(d/dx): %.3f %.3f %.3f %.3f',tstat{:}));
	end
	
	if DEBUG
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
		[CPCAX,XUnMix]	= pca(reshape(XMix,nT,u.nVoxel));
		XUnMix			= reshape(XUnMix,nTRun,u.nRun,u.nVoxel);
		
		[CPCAY,YUnMix]	= pca(reshape(YMix,nT,u.nVoxel));
		YUnMix			= reshape(YUnMix,nTRun,u.nRun,u.nVoxel);
	else
		[XUnMix,YUnMix]	= deal(X,Y);
	end
	
	XUnMix	= XUnMix(:,:,1:u.nSigCause);
	YUnMix	= YUnMix(:,:,1:u.nSigCause);

%calculate W*
	%get the A and B portions of the signals for each run
		XA	= arrayfun(@(run) squeeze(XUnMix(strcmp(target{run},'A'),run,:)),reshape(1:u.nRun,[],1),'uni',false);
		XB	= arrayfun(@(run) squeeze(XUnMix(strcmp(target{run},'B'),run,:)),reshape(1:u.nRun,[],1),'uni',false);
		
		YA	= arrayfun(@(run) squeeze(YUnMix(strcmp(target{run},'A'),run,:)),reshape(1:u.nRun,[],1),'uni',false);
		YB	= arrayfun(@(run) squeeze(YUnMix(strcmp(target{run},'B'),run,:)),reshape(1:u.nRun,[],1),'uni',false);
	
	%calculate the Granger Causality from X components to Y components for each run
		[WAs,WBs]	= deal(repmat({zeros(u.nSigCause)},[u.nRun 1]));
		
		for kR=1:u.nRun
			for kX=1:u.nSigCause
				for kY=1:u.nSigCause
					WAs{kR}(kX,kY)	= GrangerCausality(XA{kR}(:,kX),YA{kR}(:,kY));
					WBs{kR}(kX,kY)	= GrangerCausality(XB{kR}(:,kX),YB{kR}(:,kY));
				end
			end
		end
	
	if DEBUG
		mWAs	= mean(cat(3,WAs{:}),3);
		mWBs	= mean(cat(3,WBs{:}),3);
		
		im	= normalize([mWAs mWBs]);
		im	= [imresize(im(:,1:u.nSigCause),[szIm NaN],'nearest') 0.8*ones(szIm,round(200/u.nSigCause)) imresize(im(:,u.nSigCause+1:end),[szIm NaN],'nearest')];
		figure; imshow(im);
		title('W^*_A and W^*_B');
		
		disp(sprintf('mean W*A column sums:  %s',sprintf('%.3f ',sum(mWAs))));
		disp(sprintf('mean W*B column sums:  %s',sprintf('%.3f ',sum(mWBs))));
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
		p		= 1 - binocdf(Xbin-1,Nbin,Pbin);
	%accuracy
		acc	= Xbin/Nbin;
		
	if DEBUG
		disp(sprintf('accuracy: %.2f%%',100*acc));
		disp(sprintf('p(binom): %.3f',p));
	end
	
	end
end
methods (Static)
	function go(varargin)
		p = Pipeline(varargin{:});
		p.runSim;
	end
end
end
