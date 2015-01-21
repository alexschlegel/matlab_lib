% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

%cuts/pastes/modifications of Bennet's pipeline. trying to understand the
%pipeline as a whole better, and a big long string of code works better for me
%for that purpose.

%here we will generate two W causality matrices, generate fMRI data for two
%ROIS (X and Y) that represent a block design in which the two conditions (A
%and B) differ only in the pattern of directed connectivity from X to Y.  Can we
%classify between the two conditions based on the recovered pattern of
%connectivity from X to Y?
DEBUG	= true;

%user-defined parameters
	%size of the various spaces
		%total number of functional signals
			nSig	= 10;
		%number of functional signals of X that cause Y
			nSigCause	= 10;
		%number of voxels into which the functional components are mixed
			nVoxel	= 100;
	
	%time
		%number of time points per block
			nTBlock	= 20;
		%number of time points per rest periods
			nTRest	= 5;
		%number of repetitions of each block per run
			nRepBlock	= 3;
		%number of runs
			nRun	= 10;
	
	%signal characteristics
		%recurrence coefficient (should be <= 1)
			CRecurX	= 0.1;
			CRecurY	= 0.7;
			CRecurZ	= 0;
		%fullness of W matrices
			WFullness	= 0.1;
		%sum of W columns (sum(W)/sqrt(nSigCause)+CRecurY/X must be <=1)
			WSum	= 0.1;
	
	%mixing
		%should we even mix into voxels?
			doMixing	= true;
		%magnitude of noise introduced in the voxel mixing
			noiseMix	= 0.1; 
	
%for debugging, make behavior reproducible, otherwise randomize
	seeds			= [0 randseed2];
	rng(seeds([DEBUG ~DEBUG]),'twister');

%the two causality matrices (and other control causality matrices)
	nW				= 4;
	[cWCause,cW]	= deal(cell(nW,1));
	
	for kW=1:nW
		%generate a random W
			W					= rand(nSigCause);
		%make it sparse
			W(1-W>WFullness)	= 0;
		%normalize each column to the specified mean
			W			= W*WSum./repmat(sum(W,1),[nSigCause 1]);
			W(isnan(W))	= 0;
		
		cWCause{kW}	= W;
		
		%insert into the full matrix
		cW{kW}							= zeros(nSig);
		cW{kW}(1:nSigCause,1:nSigCause)	= cWCause{kW};
	end
	
	[WACause,WBCause,WBlankCause,WZCause]	= deal(cWCause{:});
	[WA,WB,WBlank,WZ]						= deal(cW{:});
	
	if DEBUG
		szIm	= 200;
		
		im	= normalize([WACause WBCause]);
		im	= [imresize(im(:,1:nSigCause),[szIm NaN],'nearest') 0.8*ones(szIm,round(200/nSigCause)) imresize(im(:,nSigCause+1:end),[szIm NaN],'nearest')];
		figure; imshow(im);
		title('W_A and W_B');
		
		im	= normalize([WBlankCause WZCause]);
		im	= [imresize(im(:,1:nSigCause),[szIm NaN],'nearest') 0.8*ones(szIm,round(200/nSigCause)) imresize(im(:,nSigCause+1:end),[szIm NaN],'nearest')];
		figure; imshow(im);
		title('W_{blank} and W_Z');
		
		disp(sprintf('WA column sums:  %s',sprintf('%.3f ',sum(WACause))));
		disp(sprintf('WB column sums:  %s',sprintf('%.3f ',sum(WBCause))));
		disp(sprintf('sum(WA)+CRecurY: %s',sprintf('%.3f ',sum(WACause)+CRecurY)));
		disp(sprintf('sum(WB)+CRecurY: %s',sprintf('%.3f ',sum(WBCause)+CRecurY)));
	end

%derived parameters
	%block design
		rngState = rng;
		block	= blockdesign(1:2,nRepBlock,nRun,'seed',rngState.Seed+1);
		rng(rngState);
		target	= arrayfun(@(run) block2target(block(run,:),nTBlock,nTRest,{'A','B'}),reshape(1:nRun,[],1),'uni',false);
	
	%number of time points per run
		nTRun	= numel(target{1});
	%total number of time points
		nT		= nTRun*nRun;
	
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
	[X,Y]	= deal(zeros(nTRun,nRun,nSig));
	Z		= zeros(nTRun,nRun,nSig,nSig);
	
	for kR=1:nRun
		for kT=1:nTRun
			%previous values
				if kT==1
					xPrev	= randn(nSig,1);
					yPrev	= randn(nSig,1);
					zPrev	= randn(nSig,nSig);
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
				Z(kT,kR,:,:)	= CRecurZ.*zPrev + (1-CRecurZ).*randn(nSig,nSig);
			%source
				X(kT,kR,:)		= CRecurX.*xPrev + sum(WZ'.*zPrev,2) + (1-WSum/sqrt(nSigCause)-CRecurX).*randn(nSig,1);
			%destination
				Y(kT,kR,:)		= CRecurY.*yPrev + W'*xPrev + (1-WSum/sqrt(nSigCause)-CRecurY).*randn(nSig,1);
		end
	end
	
	if DEBUG
		XCause	= X(:,:,1:nSigCause);
		YCause	= Y(:,:,1:nSigCause);
		
		cMeasure	= {'mean','range','std','std(d/dx)'};
		cFMeasure	= {@mean,@range,@std,@(x) std(diff(x))};
		
		cXMeasure	= cellfun(@(f) f(reshape(permute(XCause,[1 3 2]),nTRun*nSigCause,nRun)),cFMeasure,'uni',false);
		cYMeasure	= cellfun(@(f) f(reshape(permute(YCause,[1 3 2]),nTRun*nSigCause,nRun)),cFMeasure,'uni',false);
		
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
			
			kStart		= nTRest + 1 + (kB-1)*(nTBlock+nTRest);
			kEnd		= kStart + nTBlock;
			
			tStart	= tPlot(kStart);
			tEnd	= tPlot(kEnd);
			
			hP	= patch([tStart;tStart;tEnd;tEnd],[yMin;yMax;yMax;yMin],colCur);
			set(hP,'EdgeColor',colCur);
			MoveToBack(h.hA,hP);
		end
	end

%mix between voxels
	if doMixing
		XMix	= reshape(reshape(X,nT,nSig)*randn(nSig,nVoxel),nTRun,nRun,nVoxel) + noiseMix*randn(nTRun,nRun,nVoxel);
		YMix	= reshape(reshape(Y,nT,nSig)*randn(nSig,nVoxel),nTRun,nRun,nVoxel) + noiseMix*randn(nTRun,nRun,nVoxel);
	end

%unmix and keep the top nSigCause components
	if doMixing
		[CPCAX,XUnMix]	= pca(reshape(XMix,nT,nVoxel));
		XUnMix			= reshape(XUnMix,nTRun,nRun,nVoxel);
		
		[CPCAY,YUnMix]	= pca(reshape(YMix,nT,nVoxel));
		YUnMix			= reshape(YUnMix,nTRun,nRun,nVoxel);
	else
		[XUnMix,YUnMix]	= deal(X,Y);
	end
	
	XUnMix	= XUnMix(:,:,1:nSigCause);
	YUnMix	= YUnMix(:,:,1:nSigCause);

%calculate W*
	%get the A and B portions of the signals for each run
		XA	= arrayfun(@(run) squeeze(XUnMix(strcmp(target{run},'A'),run,:)),reshape(1:nRun,[],1),'uni',false);
		XB	= arrayfun(@(run) squeeze(XUnMix(strcmp(target{run},'B'),run,:)),reshape(1:nRun,[],1),'uni',false);
		
		YA	= arrayfun(@(run) squeeze(YUnMix(strcmp(target{run},'A'),run,:)),reshape(1:nRun,[],1),'uni',false);
		YB	= arrayfun(@(run) squeeze(YUnMix(strcmp(target{run},'B'),run,:)),reshape(1:nRun,[],1),'uni',false);
	
	%calculate the Granger Causality from X components to Y components for each run
		[WAs,WBs]	= deal(repmat({zeros(nSigCause)},[nRun 1]));
		
		for kR=1:nRun
			for kX=1:nSigCause
				for kY=1:nSigCause
					WAs{kR}(kX,kY)	= GrangerCausality(XA{kR}(:,kX),YA{kR}(:,kY));
					WBs{kR}(kX,kY)	= GrangerCausality(XB{kR}(:,kX),YB{kR}(:,kY));
				end
			end
		end
	
	if DEBUG
		mWAs	= mean(cat(3,WAs{:}),3);
		mWBs	= mean(cat(3,WBs{:}),3);
		
		im	= normalize([mWAs mWBs]);
		im	= [imresize(im(:,1:nSigCause),[szIm NaN],'nearest') 0.8*ones(szIm,round(200/nSigCause)) imresize(im(:,nSigCause+1:end),[szIm NaN],'nearest')];
		figure; imshow(im);
		title('W^*_A and W^*_B');
		
		disp(sprintf('mean W*A column sums:  %s',sprintf('%.3f ',sum(mWAs))));
		disp(sprintf('mean W*B column sums:  %s',sprintf('%.3f ',sum(mWBs))));
	end

%classify between W*A and W*B
	P	= cvpartition(nRun,'LeaveOut');
	
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
		
		lblTrain	= reshape(repmat({'A' 'B'},[nRun-1 1]),[],1);
		lblTest		= {'A';'B'};
		
		sSVM	= svmtrain(WTrain,lblTrain);
		pred	= svmclassify(sSVM,WTest);
		res(kP)	= sum(strcmp(pred,lblTest));
	end
	
	%one-tailed binomial test
		Nbin	= 2*nRun;
		Pbin	= 0.5;
		Xbin	= sum(res);
		p		= 1 - binocdf(Xbin-1,Nbin,Pbin);
	%accuracy
		acc	= Xbin/Nbin;
		
	if DEBUG
		disp(sprintf('accuracy: %.2f%%',100*acc));
		disp(sprintf('p(binom): %.3f',p));
	end
	
