% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

function [h,sPoint,area,color] = ThresholdSketch(varargin)
	threshOpt	= ParseArgs(varargin, ...
					'threshverbosity'	, 1					, ...
					'fakedata'			, true				, ...
					'xname'				, 'SNR'				, ...
					'yname'				, 'nSubject'		, ...
					'xvals'				, 0.01:0.001:0.5	, ...
					'yvals'				, 1:20				, ...
					'pThreshold'		, 0.05				, ...
					'nProbe'			, 200				, ...
					'nOuter'			, 6					, ...
					'init_npt'			, 7					, ...
					'kmargin'			, 2					  ...
					);
	extraargs	= opt2cell(threshOpt.opt_extra);
	obj			= Pipeline(extraargs{:});
	obj			= obj.consumeRandomizationSeed;

	% Assume p declines with increasing x or increasing y
	% Assume probe cost depends more on x than on y

	xvar.name	= threshOpt.xname;
	yvar.name	= threshOpt.yname;
	xvar.vals	= threshOpt.xvals;
	yvar.vals	= threshOpt.yvals;
	sPoint		= [];

	for kOuter=1:threshOpt.nOuter
		sPoint	= [sPoint thresholdExplore(obj,xvar,yvar,threshOpt)];
	end

	[h,area,color]	= plot_points(sPoint,threshOpt.pThreshold);
end

function sPoint = thresholdExplore(obj,xvar,yvar,tOpt)

	sPoint	= [];
	xvar	= initvar(xvar);
	yvar	= initvar(yvar);

	while numel(sPoint) < tOpt.nProbe
		xvar.npt	= min(xvar.npt,2*yvar.npt);
		yvar.npt	= min(yvar.npt,2*xvar.npt);
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
		nval			= numel(var.vals);
		krange			= [1 nval];
		switch var.npt
			case 0
				k		= [];
			case 1
				k		= floor(mean(krange));
			case 2
				k		= krange;
			otherwise
				k		= sort([krange (1+randperm(nval-2,var.npt-2))]);
		end
		var.vals	= var.vals(k);

		if tOpt.threshverbosity > 2
			fprintf('%s count=%d indices:%s\n',var.name,nval,sprintf(' %d',k));
			fprintf('    vals:%s\n',sprintf(' %g',var.vals));
		end
	end

	function var = findrange(var,varpick,varProbed,pProbed)
		mingood		= min(varProbed(pProbed <= tOpt.pThreshold));
		kminpick	= max(1,find(varpick.vals==mingood)-tOpt.kmargin);
		kminpick	= unless(kminpick,1);
		kmin		= find(var.vals==varpick.vals(kminpick));

		npick		= numel(varpick.vals);
		maxbad		= max(varProbed(pProbed > tOpt.pThreshold));
		kmaxpick	= min(find(varpick.vals==maxbad)+tOpt.kmargin,npick);
		kmaxpick	= unless(kmaxpick,npick);
		kmax		= find(var.vals==varpick.vals(kmaxpick));

		var.npt		= min(ceil(1.4*var.npt),kmax-kmin+1);
		var.vals	= var.vals(kmin:kmax);

		if tOpt.threshverbosity > 2
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
			ky	= ky+1;
		else
			kx	= kx-1;
		end
		%fprintf('Advanced to (%d,%d)\n',kx,ky);
	end

	sPoint	= sPoint(1:nPoint);
end

function [h,area,color] = plot_points(sPoint,pThreshold)
	area		= 30+abs(30*log([sPoint.p]./pThreshold));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h = figure;
	scatter([sPoint.x],[sPoint.y],area,color);
end

function summary = fakeSimulateAllSubjects(obj)
	x				= obj.uopt.SNR;
	y				= obj.uopt.nSubject;
	summary.alex.p	= 0.05*x*y*(1.2^randn);
end
