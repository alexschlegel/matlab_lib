% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

function [sPoint,pipeline,threshOpt,h,area,color] = ThresholdSketch(varargin)
	threshOpt	= ParseArgs(varargin, ...
					'fakedata'			, true				, ...
					'noplot'			, false				, ...
					'threshVerbosity'	, 1					, ...
					'yname'				, 'nSubject'		, ...
					'yvals'				, 1:20				, ...
					'xname'				, 'SNR'				, ...
					'xstart'			, 0.01				, ...
					'xstep'				, 0.001				, ...
					'xend'				, 0.7				, ...
					'pThreshold'		, 0.05				, ...
					'nProbe'			, 200				, ...
					'nOuter'			, 6					, ...
					'init_npt'			, 7					, ...
					'npt_growth'		, sqrt(2)			, ...
					'kmargin'			, 2					, ...
					'max_aspect'		, 2					  ...
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
		[h,area,color]	= plot_points(sPoint,threshOpt.pThreshold);
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
	xvar	= initvar(xvar);
	yvar	= initvar(yvar);

	while numel(sPoint) < tOpt.nProbe
		xvar.npt	= min(xvar.npt,tOpt.max_aspect*yvar.npt);
		yvar.npt	= min(yvar.npt,tOpt.max_aspect*xvar.npt);
		xpick		= pickvals(xvar);
		ypick		= pickvals(yvar);
		sPointNew	= thresholdSweep(obj,xpick,ypick,tOpt);
		xvar		= findrange(xvar,xpick,[sPointNew.x],[sPointNew.p]);
		yvar		= findrange(yvar,ypick,[sPointNew.y],[sPointNew.p]);
		sPoint		= [sPoint sPointNew];
	end

	function var = initvar(var)
		var.npt		= tOpt.init_npt;
	end

	function var = pickvals(var)
		nval	= numel(var.vals);
		k		= var.npt;

		assert(nval>=k && k>=2,'Bug: bad argument');

		netgap	= nval - 1;
		ngap	= k - 1;
		meangap	= floor(netgap/ngap);
		gap		= randi(meangap,1,ngap);
		extra	= netgap - sum(gap);
		quot	= floor(extra/ngap);
		gap		= gap + quot;
		ix		= randperm(ngap,extra - ngap*quot);
		gap(ix) = gap(ix) + 1;
		kval	= cumsum([1 gap]);

		assert(numel(kval)==k,'Bug: wrong size');
		assert(kval(1)==1 && kval(end)==nval,'Bug: bad endpoint');

		var.vals	= var.vals(kval);
		if tOpt.threshVerbosity > 2
			fprintf('%s count=%d indices:%s\n',var.name,nval,sprintf(' %d',kval));
			fprintf('    vals:%s\n',sprintf(' %g',var.vals));
		end
	end

	function var = findrange(var,varpick,varProbed,pProbed)
		goodidx		= pProbed <= tOpt.pThreshold; % N.B.: excludes NaN probes!

		mingood		= min(varProbed(goodidx));
		mingood		= unless(mingood,varpick.vals(1));
		kminpick	= max(1,find(varpick.vals==mingood)-tOpt.kmargin);
		kmin		= find(var.vals==varpick.vals(kminpick));

		maxbad		= max(varProbed(~goodidx)); % (includes NaN probes)
		maxbad		= unless(maxbad,varpick.vals(end));
		kmaxpick	= min(find(varpick.vals==maxbad)+tOpt.kmargin,numel(varpick.vals));
		kmax		= find(var.vals==varpick.vals(kmaxpick));

		var.npt		= min(ceil(tOpt.npt_growth*var.npt),kmax-kmin+1);
		var.vals	= var.vals(kmin:kmax);

		if tOpt.threshVerbosity > 2
			fprintf('  %s mingood=%g kmin=%d maxbad=%g kmax=%d\n',var.name,mingood,kmin,maxbad,kmax);
			fprintf('      new npt=%d new min=%g new max=%g\n',var.npt,var.vals(1),var.vals(end));
		end
	end
end

function sPoint = thresholdSweep(obj,xvar,yvar,tOpt)
	nx	= numel(xvar.vals);
	ny	= numel(yvar.vals);
	kx	= nx;
	ky	= 1;

	zpt		= struct('x',0,'y',0,'p',0);
	sPoint	= repmat(zpt,1,nx+ny);
	nPoint	= 0;

	while kx >= 1 && ky <= ny
		pt.x				= xvar.vals(kx);
		pt.y				= yvar.vals(ky);

		obj					= obj.setopt(xvar.name,pt.x);
		obj					= obj.setopt(yvar.name,pt.y);
		%obj.uopt.(xvar.name)	= pt.x;
		%obj.uopt.(yvar.name)	= pt.y;
		if tOpt.fakedata
			summary			= fakeSimulateAllSubjects(obj);
		else
			summary			= simulateAllSubjects(obj);
		end

		pt.p				= summary.alex.p;
		nPoint				= nPoint+1;
		sPoint(nPoint)		= pt;

		if pt.p <= tOpt.pThreshold
			kx	= kx-1;
		else
			ky	= ky+1;
		end
		%fprintf('Advanced to (%d,%d)\n',kx,ky);
	end

	sPoint	= sPoint(1:nPoint);
end

function [h,area,color] = plot_points(sPoint,pThreshold)
	ratio		= max(1e-6,min([sPoint.p]./pThreshold,1e6));
	area		= 30+abs(60*log(ratio));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h			= figure;
	scatter([sPoint.x],[sPoint.y],area,color);
end

function summary = fakeSimulateAllSubjects(obj)
	obj		= obj.consumeRandomizationSeed;
	% p-values synthesized here are not intended to be realistic, but
	% merely to create curve shapes that are useful for testing
	x		= obj.uopt.SNR;
	y1		= obj.uopt.nRepBlock;	% default=5
	y2		= obj.uopt.nRun;		% default=15
	y3		= obj.uopt.nSubject;	% default=15
	y4		= obj.uopt.nTBlock;		% default=10
	if y3 < 2
		p	= NaN;
	else
		p	= 0.05*(1+0.2*15/y3)^randn/((x/0.2+0.3*y2/15)*(y1/5)*(y4/10-0.07));
	end
	summary.alex.p	= p;
end
