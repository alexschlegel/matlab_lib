function [sPoint,pipeline,threshOpt,h,area,color] = ThresholdProbe(varargin)
% ThresholdProbe
%
% Description:	Variant of ThresholdSketch (see Notes below)
%
% Syntax:	[sPoint,pipeline,threshOpt,h,area,color] = ThresholdProbe(<options>)
%
% In:
%	<options>:
%		fakedata:	(true) generate fake data (for quick tests)
%		noplot:		(false) suppress plotting
%		yname:		('nSubject') y-axis variable name
%		yvals:		(1:20) y-axis variable values
%		xname:		('SNR') x-axis variable name
%		xlow:		(0.05) lower-bound on x-variable value
%		xinit_step:	(0.05) initial x-variable downward step amount
%		xhigh:		(0.35) highest (and initial) x-variable value
%		xcount:		(30) maximum number of x-variable values to explore
%		nprobex:	(100) number of probes per x-variable value
%		stdprobe:	(2) std dev of y-variable index jitter
%		pThreshold:	(0.05) threshold p-value to be attained
%
% Out:
% 	sPoint		- a struct array of probes (x, y, p, summary)
%	pipeline	- the Pipeline instance created to perform probes
%	threshOpt	- struct of options, including defaults for those
%				  not explicitly specified in arguments
%	h			- handle for generated plot (if any)
%	area		- area data for points in generated plot (if any)
%	color		- color data for points in generated plot (if any)
%
% Notes:
%	This script (ThresholdProbe.m) appears to be a failed experiment.
%	Unlike ThresholdSketch (and the soon-to-be-added ThresholdWeave),
%	ThresholdProbe probes extensively at each individual x-value
%	without consideration of neighboring x-values (except that the
%	y-value for the initial probe at each x is inherited from the
%	previous x).  There may be ways to get this approach to work well,
%	but as it stands, the script's behavior does not seem especially
%	reliable.  It often finds plausible y-values at each x, but the
%	results are not highly consistent.
%
%	One thing that ThresholdProbe does, and that ThresholdSketch does
%	*not* do, is to use the steepness of the probed y-vs-x threshold
%	curve to dynamically adjust the intervals between probed x-values.
%	That is, the x-values are examined more finely where the curve is
%	steepest.  In principle, this capability should help give a more
%	detailed picture of the left-hand portion of the curve.
%
% Example:
%	ThresholdProbe;
%	ThresholdProbe('yname','nRun','seed',3);
%	ThresholdProbe('yname','WStrength','yvals',linspace(0.2,0.8,21),'seed',3);
%	sPoint=ThresholdProbe('noplot',true);
%
% Updated: 2015-07-18
% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
% This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

	threshOpt	= ParseArgs(varargin, ...
					'fakedata'			, true				, ...
					'noplot'			, false				, ...
					'yname'				, 'nSubject'		, ...
					'yvals'				, 1:20				, ...
					'xname'				, 'SNR'				, ...
					'xlow'				, 0.05				, ...
					'xinit_step'		, 0.05				, ...
					'xhigh'				, 0.35				, ...
					'xcount'			, 30				, ...
					'nprobex'			, 100				, ...
					'stdprobe'			, 2					, ...
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

	sPoint		= thresholdHunt(obj,threshOpt);

	if ~threshOpt.noplot && feature('ShowFigureWindows')
		[h,area,color]	= plot_points(sPoint,threshOpt.pThreshold,threshOpt.xname,threshOpt.yname);
	else
		[h,area,color]	= deal([]);
	end
end

function sPoint = thresholdHunt(obj,tOpt)
	allx	= [];
	alldata	= {};
	xhigh	= tOpt.xhigh;
	xstep	= tOpt.xinit_step;
	init_ky	= 1;
	yvals	= tOpt.yvals;

	while true
		newx	= (xhigh:-xstep:tOpt.xlow).';
		newx	= 1e-10*round(newx*1e10);
		newx	= sort(setdiff(newx,allx));
		newx	= newx(max(1,end+1-tOpt.xcount+numel(allx)):end);
		if isempty(newx)
			break;
		end
		newdata		= thresholdScan(obj,newx,yvals,init_ky,tOpt);
		alldata		= cat(1,alldata,newdata);
		[allx,ix]	= sort(cellfun(@(d)d.xval,alldata));
		alldata		= alldata(ix);

		y0			= cellfun(@(d)d.y0,alldata);
		ky			= cellfun(@(d)d.ky,alldata);
		d_ky		= [diff(ky);0];
		kx_redo		= 1 + find(~(y0 <= yvals(end)) | ky > numel(yvals) | d_ky <= -2,1,'last');
		if isempty(kx_redo)
			break;
		end
		xstep		= xstep/2;
		xhigh		= allx(kx_redo);
		init_ky		= alldata{kx_redo}.ky;
	end
	%diagnostic variables:
	%nallx	= numel(allx)
	%y0T		= y0.'
	%kyT		= ky.'

	ccPoint	= cellfun(@(d)d.cPoint,alldata,'uni',false);
	cPoint	= cat(1,ccPoint{:});
	sPoint	= cellfun(@(p)p,cPoint);
end

function xdata = thresholdScan(obj,xvals,yvals,init_ky,tOpt)
	nx		= numel(xvals);
	xdata	= cell(nx,1);
	ky		= init_ky;
	prev_ky	= NaN;

	for kx=nx:-1:1
		%fprintf('thresholdScan kx=%d\n',kx);
		data.xval		= xvals(kx);
		[cPoint,y0,ky]	= thresholdEstimate(obj,data.xval,yvals,ky,tOpt);
		data.cPoint		= cPoint;
		data.y0			= y0;
		data.ky			= ky;
		xdata{kx}		= data;
		if isnan(y0) || y0 > yvals(end) || ky > prev_ky+4
			break;
		end
		prev_ky			= ky;
	end
	xdata	= xdata(~cellfun(@isempty,xdata));
end

function [cPoint,y0,ky] = thresholdEstimate(obj,xval,yvals,init_ky,tOpt)
	nPoint		= tOpt.nprobex;
	cPoint		= cell(nPoint,1);
	ny			= numel(yvals);
	ky			= max(1,min(round(init_ky),ny));
	ky_low		= ky;
	ky_high		= ky;

	for kPoint=1:nPoint
		ky		= round(ky+tOpt.stdprobe*randn);
		ky		= max([1,ky_low-1,min([ky,ky_high+1,ny])]);
		ky_low	= min(ky_low,ky);
		ky_high	= max(ky_high,ky);
		pt.x	= xval;
		pt.y	= yvals(ky);
		obj		= obj.setopt(tOpt.xname,pt.x);
		obj		= obj.setopt(tOpt.yname,pt.y);
		if tOpt.fakedata
			summary		= fakeSimulateAllSubjects(obj);
		else
			summary		= simulateAllSubjects(obj);
		end
		pt.p			= summary.alex.p;
		pt.summary		= summary;
		cPoint{kPoint}	= pt;

		log10pThreshold	= log10(tOpt.pThreshold);
		y0				= yEstimate(cPoint(1:kPoint),log10pThreshold);
		kbelow			= find(yvals<=y0,1,'last');
		kabove			= find(yvals>=y0,1);
		if isempty(kbelow) && ~isempty(kabove)
			%fprintf('kP %d empty below: y0=%s kabove=%d\n',kPoint,num2str(y0),kabove);
			ky			= kabove;
		elseif ~isempty(kbelow) && isempty(kabove) && ny >= 2
			%fprintf('kP %d empty above: y0=%s kbelow=%d\n',kPoint,num2str(y0),kbelow);
			ky			= kbelow;
		elseif ~isempty(kbelow) && ~isempty(kabove)
			ybelow		= yvals(kbelow);
			yabove		= yvals(kabove);
			if yabove > ybelow
				frac	= (y0-ybelow)/(yabove-ybelow);
			else
				frac	= 0.5;
			end
			ky			= kbelow + frac*(kabove-kbelow);
		end
	end

	function [f,g] = dual_linefit(x,y,x0)
	% dual_linefit
	%
	% This function was copied from s20150618_updated_plot_thresholds.m
	% The copy here is slightly modified.
	% (Another variant appears in s20150618_plot_thresholds.m)
	% TODO: Refactor and share

		%fprintf('range(x)=%s range(y)=%s\n',num2str(range(x)),num2str(range(y)));
		errfac				= 1;
		xy	= [x(:);y(:)];
		if numel(x) < 3 || range(x) == 0 || range(y) == 0 || any(isnan(xy)) || any(isinf(xy))
			f.px2y			= [0,mean(y)];
			f.py2x			= [0,mean(x)];
			[f.y0,f.dy0]	= deal(NaN);
			g				= f;
		else
			[f.px2y,S]		= polyfit(x,y,1);
			[f.y0,f.dy0]	= polyval(f.px2y,x0,S);
			%f.y0			= optclip(f.y0);
			f.dy0			= errfac*f.dy0;
			f.py2x			= swap_linear_polynomial_axes(f.px2y);

			[g.py2x,S]		= polyfit(y,x,1);
			g.px2y			= swap_linear_polynomial_axes(g.py2x);
			g.y0			= polyval(g.px2y,x0);
			[x0_hat,dx0]	= polyval(g.py2x,g.y0,S);

			assert(abs(x0-x0_hat)<1e-8,'Erroneous linear polynomial inversion');

			g.dy0			= abs(errfac*dx0*g.px2y(1));
			%g.y0			= optclip(g.y0);
		end
	end

	function pswap = swap_linear_polynomial_axes(p)
	% pswap
	%
	% This function was copied from s20150618_updated_plot_thresholds.m
	% The copy here is slightly modified.
	% (Another variant appears in s20150618_plot_thresholds.m)
	% TODO: Refactor and share
		iSlope	= 1/p(1);
		pswap	= [iSlope,-p(2)*iSlope];
	end

	function y0 = yEstimate(cPoint,log10pThreshold)
		y		= cellfun(@(pt) pt.y,cPoint);
		p		= cellfun(@(pt) pt.p,cPoint);
		logp	= log10(max(1e-6,min(p,1e6)));
		[f,g]	= dual_linefit(logp,y,log10pThreshold);
		y0		= g.y0;
	end
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
