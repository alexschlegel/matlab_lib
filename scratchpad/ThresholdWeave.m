function [sPoint,pipeline,threshOpt,h,area,color] = ThresholdWeave(varargin)
% ThresholdWeave
%
% Description:	For a range of SNRs and a designated parameter, find
%		least parameter values that bring p-value below a designated
%		threshold
%
% Syntax:	[sPoint,pipeline,threshOpt,h,area,color] = ThresholdWeave(<options>)
%
% In:
%	<options>:
%		fakedata:	(true) generate fake data (for quick tests)
%		noplot:		(false) suppress plotting
%		yname:		('nSubject') y-axis variable name
%		yvals:		(1:20) y-axis variable values
%		xname:		('SNR') x-axis variable name
%		xstart:		(0.05) lower-bound on x-variable value
%		xstep:		(0.002) x-variable step amount
%		xend:		(0.35) upper-bound on x-variable value
%		nSweep:		(1) number of SNR back-and-forth traversals
%						per independent survey
%		nOuter:		(6) number of independent surveys
%		pThreshold:	(0.05) threshold p-value to be attained
%
% Out:
% 	sPoint		- a struct array of probes (x, y, p, summary)
%	pipeline	- the Pipeline instance created to perform probes
%	threshOpt	- struct of options, including defaults for those
%				  not explicitly specified in arguments
%	h			- handle for generated plot (if any)
%	area		- area data for points in generated plot (if any);
%				  the area of each point represents the log-scale
%				  distance of its p-value from the threshold (see
%				  Notes below)
%	color		- color data for points in generated plot (if any);
%				  see Notes below
%
% Notes:
%	ThresholdWeave searches for (x,y) pairs that yield p-values at or
%	near the designated p-threshold.  It is assumed that p is (on
%	average) monotonically decreasing in x for fixed y, and also
%	monotonically decreasing in y for fixed x.  Thus, if (x,y) pairs
%	are plotted on a standard 2D graph, we postulate that at points
%	(x,y) toward the upper-right-hand portion of the graph, where x
%	and y are both high, the expected p-values should be *less* than
%	the p-threshold, while at points (x,y) toward the lower-left-hand
%	portion of the graph, where x and y are both low, the expected
%	p-values should be *greater* than the p-threshold.  The boundary
%	separating the large-p and small-p regions runs from somewhere
%	toward the upper-left-hand corner of the graph to somewhere toward
%	the lower-right-hand corner.  ThresholdWeave begins its search at
%	the latter corner; that is, the initial x-value is high, and the
%	initial y-value is low.  The code gradually scans ("sweeps")
%	leftward and upward, decreasing x and increasing y, all the while
%	attempting to cleave close to the boundary between the large-p and
%	small-p regions.  When the scan reaches either the left-hand or
%	upper edge of the graph, the code reverses course and scans
%	rightward and downward until it reaches either the right-hand or
%	lower edge of the graph.  The entire back-and-forth sweep is
%	serially repeated nSweep times.  Additionally, the code provides
%	for parallel execution of nOuter series of sweeps, yielding a
%	total of nOuter*nSweep back-and-forth sweeps.
%
%	To steer close to the boundary between the small-p and large-p
%	regions of the graph, the scanning code follows a simple rule:  If
%	the most recent probe point (x,y) yielded a p-value larger than
%	the threshold, then the next probe point is obtained by nudging
%	either x or y upward; whereas if the p-value was smaller than or
%	equal to the threshold, then the next probe point is obtained by
%	nudging either x or y *downward*.  The code thus attempts to weave
%	back and forth across the p-threshold boundary.  Because the
%	probes are highly stochastic, there is no guarantee that
%	successive probes will in fact cross the boundary, but the further
%	the probe points stray from it, the greater the likelihood that
%	the probed p-values will accurately reflect the current region,
%	and so cause the scan to weave back toward the boundary.
%
%	When the scan direction is from lower-right to upper-left, the
%	rule just stated becomes more specific:  If the most recent probe
%	point yielded a p-value larger than the threshold, then y (not x)
%	is nudged upward; otherwise, x (not y) is nudged *downward*.  When
%	the scan direction is from upper-left to lower-right, the rule is
%	specialized in the opposite way:  If the most recent probe point
%	yielded a p-value larger than the threshold, then x (not y) is
%	nudged upward; otherwise, y (not x) is nudged *downward*.
%
%	ThresholdWeave (unlike its predecessor ThresholdSketch) makes a
%	further provision regarding the scan direction.  Scans in a given
%	direction include "micro-stitches" in which the scan direction is
%	temporarily reversed.  For every two steps forward, so to speak, a
%	backward step is inserted.  The intent of these micro-reversals is
%	to prevent the scan from getting locked in ruts parallel to
%	sections of the threshold boundary that are nearly horizontal or
%	nearly vertical.  However, although the micro-reversals are
%	conjectured to be beneficial, their effectiveness has not been
%	established.
%
%	An interesting property of the probe sets generated by the
%	bidirectional scans is the balance between sub-threshold and
%	super-threshold probes.  ThresholdWeave produces scatter plots
%	showing each probe in either blue or red, depending on whether the
%	probe's p-value meets the designated threshold.  (Blue means yes,
%	the p-value is small enough; red means no.)  The numbers of red
%	and blue probes are roughly equal.  Moreover, except at the edges
%	of the graph, for each red probe there must be a corresponding
%	blue probe relatively nearby, and vice versa.  The reason for this
%	correspondence is as follows.  Consider two adjacent x-values xj
%	and xk (with xj < xk).  For some y0, during the scan from the
%	lower-right to the upper-left, the probe point progresses from
%	(xk,y0) to (xj,y0).  This progression can occur only if the
%	p-value at (xk,y0) meets the threshold, so (xk,y0) is colored
%	blue.  Likewise, for some y1, during the scan from the upper-left
%	to the lower-right, the probe point progresses from (xj,y1) to
%	(xk,y1).  This time the progression can occur only if the p-value
%	at (xj,y1) exceeds the threshold, so (xj,y1) is colored red.
%	Inasmuch as xj is close to xk, and both (xk,y0) and (xj,y1) are
%	near the threshold boundary, they must be relatively near to one
%	another.  A similar argument applies to progressions between
%	adjacent y-values; the color balance can be seen with respect to
%	either axis.
%
%	The foregoing paragraph implicitly assumes that there is just
%	*one* progression from xk to xj during a leftward scan, and then
%	just one rightward progression from xj to xk during the reverse
%	scan.  But in the presence of micro-stitches, there could be
%	multiple progressions between these x-values in either direction.
%	Even so, the balance between the red and blue points is preserved.
%	Suppose that the leftward scan starts in the lower-right corner of
%	the graph at (x_initial,y_initial).  For the reverse rightward
%	scan to wind up at that same point, there must necessarily be
%	equal numbers of progressions between xj and xk in either
%	direction.  The leftward and rightward progression counts between
%	xj and xk can differ only if the rightward scan ends at a
%	different point (x_final,y_final) from the initial point
%	(x_initial,y_initial), and if, moreover, xj and xk lie inside the
%	interval spanned by x_initial and x_final.  Again, this argument
%	is symmetric in x and y.  The assertion of the foregoing paragraph
%	that there is a correspondence between the red and blue probes
%	except at the edges of the graph can thus be refined:  The
%	correspondence holds everywhere except in the lower-right portion
%	of the graph between the initial and final points of the sweep.
%
%	When the matter is viewed in the abstract, there is no reason why
%	the bidirectional scans should start and end in the lower-right
%	corner of the graph.  They could equally well start in the
%	upper-left, sweep rightward and downward to the lower-right, and
%	then sweep back to the upper-left again.  However, two
%	considerations weigh in favor of starting in the lower-right when
%	the x-axis represents SNR, as it does by default, and when the
%	y-axis represents parameters such as nSubject, nRun, nTBlock, and
%	so on.  First, with these variable assignments, the cost of a
%	probe increases as y increases, so it makes sense to begin with
%	low-cost probes and to increase y only as necessary to keep the
%	p-values hovering near the threshold.  Second, for low values of
%	SNR, the y-values at the p-threshold boundary tend to exceed the y
%	range of interest.  By letting the scans start at the lower-right
%	and climb upward and leftward until y goes out of bounds, we
%	automatically discover the minimum viable SNR value (to a close
%	approximation).  We avoid generating probe points whose x-value is
%	beneath that minimum, which in turn makes for cleaner diagnostic
%	plots than would obtain otherwise.
%
%	The end goal of the computations performed by ThresholdWeave is to
%	determine, for each x, the minimum y value such that the expected
%	value of p at (x,y) satisfies the designated p-threshold.
%	ThresholdWeave does not attempt to make that determination.  At
%	present it is left to the script s20150718_plot_thresholds to draw
%	on the raw data generated by ThresholdWeave to plot the threshold
%	y-values as a function of x.  That script produces up to five plot
%	lines showing y as a function of x, using five different
%	strategies to interpret the raw data from ThresholdWeave.  The
%	plots include error bars showing (at present) 50% confidence
%	intervals for the computed y-values.  In recent runs, the
%	different strategies substantially agree on the y-values, but
%	disagree on the confidence intervals.  Does that disagreement mean
%	that the strategies showing smaller confidence intervals are more
%	powerful than the others?  Perhaps, but it could also mean that
%	they are implicitly making unwarranted assumptions that make the
%	results *appear* to be more robust than they actually are.  An
%	outstanding question is whether, given a set of (x,y,p) triples,
%	there is an *intrinsic* confidence interval associated with the
%	y-value at each x.
%
%	See also ThresholdSketch.m, ThresholdProbe.m, s20150718_plot_thresholds.m
%
% Example:
%	ThresholdWeave;
%	ThresholdWeave('yname','nRun','seed',3);
%	ThresholdWeave('yname','WStrength','yvals',linspace(0.2,0.8,21),'seed',3);
%	sPoint=ThresholdWeave('noplot',true);
%
% Updated: 2015-07-22
% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
% This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

%---------------------------------------------------------------------
% TODO: More comments
%---------------------------------------------------------------------

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
	reparg		= @(a) repmat({a},1,nTask);
	taskarg		= {reparg(obj),cSeed,reparg(xvar),reparg(yvar),reparg(threshOpt)};
	cPoint		= MultiTask(@thresholdSurvey, taskarg	, ...
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

function sPoint = thresholdSurvey(obj,seed,xvar,yvar,tOpt)
	assert(isnumeric(seed),'Bug: bad seed');
	%fprintf('seed is %d\n',seed);
	obj		= obj.setopt('seed',seed);
	obj		= obj.consumeRandomizationSeed;

	sPoint	= [];

	for k=1:tOpt.nSweep
		sPointNew	= thresholdSweep(obj,xvar,yvar,tOpt);
		sPoint		= [sPoint sPointNew]; %#ok
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
