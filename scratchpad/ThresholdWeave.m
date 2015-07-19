% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

function [sPoint,pipeline,threshOpt,h,area,color] = ThresholdWeave(varargin)
	threshOpt	= ParseArgs(varargin, ...
					'fakedata'			, true				, ...
					'noplot'			, false				, ...
					'yname'				, 'nSubject'		, ...
					'yvals'				, 1:20				, ...
					'xname'				, 'SNR'				, ...
					'xstart'			, 0.05				, ...
					'xstep'				, 0.002				, ...
					'xend'				, 0.35				, ...
					'nSweep'			, 1					, ...
					'nOuter'			, 6					, ...
					'pThreshold'		, 0.05				  ...
					);
	extraargs	= opt2cell(threshOpt.opt_extra);
	obj			= Pipeline(extraargs{:});
	obj			= obj.changeDefaultsForBatchProcessing;
	obj			= obj.changeOptionDefault('analysis','alex');
	obj			= obj.consumeRandomizationSeed;
	pipeline	= obj;

	% Assume p declines with increasing x or increasing y
	% Assume probe cost depends more on y than on x

	xvar.name	= threshOpt.xname;
	xvar.vals	= threshOpt.xstart:threshOpt.xstep:threshOpt.xend;
	yvar.name	= threshOpt.yname;
	yvar.vals	= threshOpt.yvals;

	nTask		= threshOpt.nOuter;
	cSeed		= num2cell(randperm(intmax('uint32'),nTask));
	rngState	= rng;
	cPoint		= cell(1,nTask);
	reparg		= @(a) repmat({a},1,nTask);
	taskarg		= {reparg(obj),cSeed,reparg(xvar),reparg(yvar),reparg(threshOpt)};
	cPoint		= MultiTask(@thresholdExplore, taskarg	, ...
					'njobmax'				, obj.uopt.njobmax			, ...
					'cores'					, obj.uopt.max_cores		, ...
					'debug'					, obj.uopt.MT_debug			, ...
					'debug_communicator'	, obj.uopt.MT_debug_comm	, ...
					'silent'				, (obj.uopt.max_cores<2)	  ...
					);
	rng(rngState);
	sPoint		= cat(2,cPoint{:});

	if ~threshOpt.noplot && feature('ShowFigureWindows')
		[h,area,color]	= plot_points(sPoint,threshOpt.pThreshold,xvar.name,yvar.name);
	else
		[h,area,color]	= deal([]);
	end
end

function sPoint = thresholdExplore(obj,seed,xvar,yvar,tOpt)
	assert(isnumeric(seed),'Bug: bad seed');
	%fprintf('seed is %d\n',seed);
	obj		= obj.setopt('seed',seed);
	obj		= obj.consumeRandomizationSeed;

	sPoint	= [];

	for k=1:tOpt.nSweep
		sPointNew	= thresholdSweep(obj,xvar,yvar,tOpt);
		sPoint		= [sPoint sPointNew];
	end
end

function sPoint = thresholdSweep(obj,xvar,yvar,tOpt)
	nx	= numel(xvar.vals);
	ny	= numel(yvar.vals);

	microStitch	= [false true false];
	nMicro		= numel(microStitch);
	zpt			= struct('x',0,'y',0,'p',0,'summary',struct);
	sPoint		= repmat(zpt,1,2*nMicro*(nx+ny));
	nPoint		= 0;

	kx	= nx;
	ky	= 1;
	for retrace=0:1 % i.e., retrace=false, then retrace=true
		microIndex		= 1;
		while conditional(~retrace, ...
				kx >= 1  && ky <= ny	, ... % right-left, bottom-top
				kx <= nx && ky >= 1		  ... % left-right, top-bottom
				)
			kx	= max(1,min(kx,nx));
			ky	= max(1,min(ky,ny));
			%fprintf('[%d] ',kx+ny-ky);

			pt.x				= xvar.vals(kx);
			pt.y				= yvar.vals(ky);

			obj					= obj.setopt(xvar.name,pt.x);
			obj					= obj.setopt(yvar.name,pt.y);
			if tOpt.fakedata
				summary			= fakeSimulateAllSubjects(obj);
			else
				summary			= simulateAllSubjects(obj);
			end

			pt.p				= summary.alex.p;
			pt.summary			= summary;
			nPoint				= nPoint+1;
			sPoint(nPoint)		= pt;

			meetsThreshold		= pt.p <= tOpt.pThreshold;
			step				= conditional(meetsThreshold,-1,+1);
			microRetrace		= xor(retrace,microStitch(microIndex));
			if meetsThreshold ~= microRetrace
				kx	= kx + step;
			else
				ky	= ky + step;
			end
			microIndex			= 1+mod(microIndex,nMicro);
		end
	end

	sPoint	= sPoint(1:nPoint);
end

function [h,area,color] = plot_points(sPoint,pThreshold,xname,yname)
	ratio		= max(1e-6,min([sPoint.p]./pThreshold,1e6));
	area		= 30+abs(60*log(ratio));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h			= figure;
	scatter([sPoint.x],[sPoint.y],area,color);
	xlabel(xname);
	ylabel(yname);
end

function summary = fakeSimulateAllSubjects(obj)
	obj		= obj.consumeRandomizationSeed;
	% values synthesized here are not intended to be realistic, but
	% merely to create curve shapes that are useful for testing
	snr		= obj.uopt.SNR;
	nsubj	= obj.uopt.nSubject;	% default=15
	y1		= obj.uopt.nTBlock;		% default=10
	y2		= obj.uopt.nRepBlock;	% default=5
	y3		= obj.uopt.nRun;		% default=15
	y4		= obj.uopt.WStrength;	% default=0.5
	scale	= 0.25*atan((y1-0.5)*y2*sqrt(y3)/120);
	snoise	= 0.05/y4;
	bias	= (1 + snoise*randn(nsubj,1))*scale;
	acc		= 0.5 + (snr*bias + snoise*randn(size(bias)))/(snr+1);

	%summary.bias	= bias;
	%summary.acc		= acc;

	[h,p_grouplevel,ci,stats]	= ttest(acc,0.5,'tail','right');
	summary.alex.meanAccAllSubj	= mean(acc);
	summary.alex.stderrAccAllSu	= stderr(acc);
	summary.alex.h				= h;
	summary.alex.p				= p_grouplevel;
	summary.alex.ci				= ci;
	summary.alex.stats			= stats;
end
