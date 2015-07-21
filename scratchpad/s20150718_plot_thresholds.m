function h = s20150718_plot_thresholds(varargin)
% s20150718_plot_thresholds
%
% Description:	generate data for and/or plot nRun, nSubject, nTBlock,
%				nRepBlock, and WStrength threshold values needed to
%				attain p <= 0.05 at a range of SNR values
%
% Syntax:	h = s20150718_plot_thresholds(<options>)
%
% In:
%	<options>:
%		clip:		(true) if 'oldclip', clip linear extrapolations to variable range;
%						if true, remove linear-extrapolation outliers (see 'cliptail').
%						Variable in question is one of 'nRun', 'nSubject', 'nTBlock',
%						'nRepBlock', or 'WStrength', as specified by 'varname' below
%		cliperr:	(true) logical or numeric:  remove points whose error
%						exceeds specified fraction of max variable value;
%						for cliperr==true, fraction is taken as 1 (for now)
%		clipsize:	(5) fewest fit points for inclusion of linear extrapolation (if clip==true)
%		cliptail:	(0.2) fraction of fit points considered tail at each end (if clip==true)
%		fakedata:	(<auto>) generate fake data (for quick tests)
%		forcegen:	(false) generate new data even if cached data exists
%		nogen:		(<auto>) suppress data generation even if no data cached
%		noplot:		(<auto>) suppress plotting
%		plotlines:	(1:5) plot lines to include in multifit plot (if applicable)
%		plottype:	('multifit') type of plot, or cell of plot types:
%							'multifit', 'p_snr', 'p_test', 'test_snr';
%							default changes to all types if varname specified
%		savedata:	(<auto>) cache generated data; by default true if not fakedata
%		saveplot:	(false) save plot(s) to fig file
%		showwork:	(false) one of false, 'hist', 'pct', or 'scat' (true): display
%							specified kind of diagnostic plot for each SNR value
%		varname:	(<auto>) one of 'nRun', 'nSubject', 'nTBlock', 'nRepBlock', or
%							'WStrength'; if none specified, all variables are used,
%							except when showwork is specified
%		xstart:		(0.05) SNR lower bound
%		xstep:		(0.002) SNR step
%		xend:		(0.35) SNR upper bound
%		seed:		(0) randomization seed (false for none)
%		<other>:	Additional options forwarded to ThresholdWeave and/or Pipeline.
%
% Out:
% 	h	- figure handle(s)
%
% Notes:
%	When running in an environment with ShowFigureWindows, fakedata and nogen default
%	to true, and noplot defaults to false; without ShowFigureWindows (thus, in batch
%	runs), fakedata and nogen default to false, and noplot defaults to true.
%
%	This script is an updated variant of s20150618_updated_plot_thresholds.m.
%	Among other differences, the variants of this script use different
%	data formats.  Data files written by one variant can be plotted only
%	by the same variant.  Additionally, the present script uses ThresholdWeave,
%	whereas the earlier one used ThresholdSketch.
%
%	Option-handling in this script is similar to that of s20150615_plot_nSample_wwo_HRF.m,
%	but the latter includes a few niceties that the present script currently omits.
%	Ideally the applicable code would be factored out and shared across scripts.
%
% Example:
%	h = s20150718_plot_thresholds('nogen',false);
%
% Updated: 2015-07-20
% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
% This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

%---------------------------------------------------------------------
% TODO: More comments
%---------------------------------------------------------------------

	stem		= 's20150718_thresholds';
	opt			= ParseArgs(varargin, ...
					'clip'				, true			, ...
					'cliperr'			, true			, ...
					'clipsize'			, 5				, ...
					'cliptail'			, 0.2			, ...
					'fakedata'			, []			, ...
					'forcegen'			, false			, ...
					'nogen'				, []			, ...
					'noplot'			, []			, ...
					'plotlines'			, 1:5			, ...
					'plottype'			, []			, ...
					'savedata'			, []			, ...
					'saveplot'			, false			, ...
					'showwork'			, false			, ...
					'varname'			, []			, ...
					'xstart'			, 0.05			, ...
					'xstep'				, 0.002			, ...
					'xend'				, 0.35			, ...
					'seed'				, 0				  ...
					);
	extraargs	= opt2cell(opt.opt_extra);

	hasFigwin		= feature('ShowFigureWindows');
	opt.fakedata	= unless(opt.fakedata,hasFigwin);
	opt.nogen		= unless(opt.nogen,hasFigwin) && ~opt.forcegen;
	opt.noplot		= unless(opt.noplot,~hasFigwin);
	opt.savedata	= unless(opt.savedata,~opt.fakedata);

	if opt.showwork
		opt.plottype	= unless(opt.plottype,{'multifit'});
		opt.varname		= unless(opt.varname,'WStrength');
	elseif isempty(opt.plottype)
		opt.plottype	= conditional(isempty(opt.varname),{'multifit'},...
							{'multifit','p_snr','p_test','test_snr'});
	elseif ~iscell(opt.plottype)
		opt.plottype	= {opt.plottype};
	end

	timestamp	= FormatTime(nowms,'yyyymmdd_HHMMSS');
	h			= [];
	cap_ts		= {};

	dummyWeave;

	weave('nRun'		, 2:20);
	weave('nSubject'	, 1:20);
	weave('nTBlock'		, 1:20);
	weave('nRepBlock'	, 2:15);
	weave('WStrength'	, linspace(0.2,0.8,21));

	if numel(h) > 0
		if ~opt.saveplot
			fprintf('Skipping save of plot(s) to fig file.\n');
		else
			cap_ts		= sort(cap_ts);
			dirpath		= 'scratchpad/figfiles';
			prefix		= sprintf('%s_%s',cap_ts{end},stem);
			kind		= unless(opt.varname,strjoin(opt.plottype,'+'));
			if opt.clip
				if strcmp(opt.clip,'oldclip')
					kind	= [kind '-clipped'];
				else
					%TODO: should probably also incorporate clipsize
					kind	= sprintf('%s-ta%s',kind,num2str(opt.cliptail));
				end
				if notfalse(opt.cliperr)
					strCliperr	= conditional(isnumeric(opt.cliperr),num2str(opt.cliperr),'T');
					kind		= sprintf('%s-er%s',kind,strCliperr);
				end
				strPlotlines	= char(48+opt.plotlines);
				if ~strcmp(strPlotlines,'12345')
					kind		= sprintf('%s-li%s',kind,strPlotlines);
				end
			end
			figfilepath	= sprintf('%s/%s-%s-%s.fig',dirpath,prefix,kind,FormatTime(nowms,'mmdd'));
			savefig(h(end:-1:1),figfilepath);
			fprintf('Plot(s) saved to %s\n',figfilepath);
		end
	end

	function dummyWeave
		% issue dummy invocation of ThresholdWeave to provoke error message on bad extraargs
		ThresholdWeave(...
			'fakedata'	, true		, ...
			'noplot'	, true		, ...
			'yvals'		, 2:3		, ...
			'xstep'		, 0.1		, ...
			'nOuter'	, 1			, ...
			extraargs{:} ...
			);
	end

	function weave(testvarName,testvarValues)
		if ~isempty(opt.varname) && ~strcmp(testvarName,opt.varname)
			return;
		end
		snrrange		= opt.xstart:opt.xstep:opt.xend;
		plex			= opt.xend+testvarValues(end)*1i;
		data_label		= sprintf('%s_%s_%d_%s_%d_%s',stem,testvarName,numel(testvarValues), ...
							'SNR',numel(snrrange),num2str(abs(plex)));
		fcreate_dataset	= conditional(opt.nogen,[],@create_threshCapsule);
		not_before		= conditional(opt.forcegen,timestamp,'00000000_');
		[capsule,ts]	= get_dataset(data_label,fcreate_dataset, ...
							'data_varname'	, 'capsule'		, ...
							'not_before'	, not_before	, ...
							'savedata'		, opt.savedata	, ...
							'timestamp'		, timestamp		  ...
							);
		if opt.noplot || isempty(capsule)
			return;
		elseif ~isfield(capsule.version,'thresholdCapsule')
			error('Not a threshold capsule.');
		elseif ~strcmp(capsule.version.thresholdCapsule,stem)
			error('Incompatible capsule version %s',capsule.version.thresholdCapsule);
		end
		points		= capsule.points;
		pThreshold	= capsule.threshopt.pThreshold;

		plottype	= opt.plottype;
		nAV	= numel(plottype);
		for kAV=1:nAV
			switch plottype{kAV}
				case 'multifit'
					plotfn	= @linefit_test_vs_SNR;
				case 'p_snr'
					plotfn	= @scatter_p_vs_SNR;
				case 'p_test'
					plotfn	= @scatter_p_vs_test;
				case 'test_snr'
					plotfn	= @scatter_test_vs_SNR;
				otherwise
					error('Unknown plottype ''%s''',plottype{kAV});
			end
			h(end+1)		= plotfn(points,pThreshold,testvarName,opt); %#ok
			cap_ts{end+1}	= ts; %#ok
		end

		function capsule = create_threshCapsule
			start_ms	= nowms;

			[threshPts,pipeline,threshOpt]	...
						= ThresholdWeave(...
							'fakedata'	, opt.fakedata		, ...
							'noplot'	, true				, ...
							'yname'		, testvarName		, ...
							'yvals'		, testvarValues		, ...
							'xstart'	, opt.xstart		, ...
							'xstep'		, opt.xstep			, ...
							'xend'		, opt.xend			, ...
							'seed'		, opt.seed			, ...
							extraargs{:} ...
							);
			end_ms		= nowms;
			version		= struct(...
							'pipeline'			, pipeline.version.pipeline	, ...
							'thresholdCapsule'	, stem						  ...
							);

			capsule.begun		= FormatTime(start_ms);
			capsule.id			= FormatTime(start_ms,'yyyymmdd_HHMMSS');
			capsule.label		= data_label;
			capsule.version		= version;
			capsule.uopt		= pipeline.uopt;
			capsule.threshopt	= threshOpt;
			capsule.points		= threshPts;
			capsule.elapsed_ms	= end_ms - start_ms;
			capsule.done		= FormatTime(end_ms);
		end
	end
end

function [dataset,ts] = get_dataset(data_label,fcreate_dataset,varargin)
% TODO: This disk-data memoization function (i.e., caching and
% retrieval function) is reasonably generic and should be usable for
% datasets other than capsules.  Should perhaps make it into a
% standalone function, or perhaps into a disk-data memoization class.
	opt		= ParseArgs(varargin, ...
				'data_varname'	, 'dataset'			, ...
				'not_before'	, '20150101_'		, ...
				'savedata'		, true				, ...
				'timestamp'		, []				  ...
				);
	dirpath			= '../data_store';
	filenames		= split(ls(dirpath),'\n');
	suffix			= sprintf('_%s.mat',data_label);
	filename_regexp	= sprintf('^[_\\d]{4,}%s$',suffix);
	matches			= filenames(~cellfun(@isempty,regexp(filenames,filename_regexp)));
	sorted_names	= sort(cat(1,matches,{opt.not_before}));
	recent_names	= sorted_names((1+find(strcmp(opt.not_before,sorted_names))):end);
	if numel(recent_names) == 0
		if isempty(fcreate_dataset)
			fprintf('Preexisting %s not available for %s\n',opt.data_varname,data_label);
			dataset	= [];
			ts		= [];
		else
			fprintf('Creating new %s for %s\n',opt.data_varname,data_label);
			dataset	= fcreate_dataset();
			ts		= unless(opt.timestamp,FormatTime(nowms,'yyyymmdd_HHMMSS'));
			if opt.savedata
				path	= sprintf('%s/%s%s',dirpath,ts,suffix);
				eval(sprintf('%s = dataset;',opt.data_varname));
				save(path,opt.data_varname);
				fprintf('Saved %s to %s\n',opt.data_varname,path);
			end
		end
	else
		fprintf('Using preexisting %s for %s\n',opt.data_varname,data_label);
		newest_name	= recent_names{end};
		path		= sprintf('%s/%s',dirpath,newest_name);
		fprintf('Loading %s\n',path);
		content		= load(path);
		dataset		= content.(opt.data_varname);
		ts_regexp	= sprintf('^(.*)%s$',suffix);
		ts			= regexprep(newest_name,ts_regexp,'$1');
	end
end

function h = linefit_test_vs_SNR(sPoint,pThreshold,varname,opt)
	showwork	= conditional(nottrue(opt.showwork),opt.showwork,'scat');
	xvals		= [sPoint.x];
	yvals		= [sPoint.y];
	pvals		= max(1e-6,min([sPoint.p],1e6));
	summaryvals	= [sPoint.summary];
	snr			= unique(xvals);
	nsnr		= numel(snr);

	nline			= 5; % At present, five plot lines
	cploty			= cell(1,nline);
	cploterr		= cell(1,nline);
	[cploty{:}]		= deal(NaN(1,nsnr));
	[cploterr{:}]	= deal(zeros(1,nsnr));
	errfac			= 1; % For cploterr error bars at 50%; TODO: revise

	log10pThreshold	= log10(pThreshold);

	for ks=1:nsnr
		b				= xvals == snr(ks);
		currNProbe		= sum(b);
		if currNProbe < 2
			continue;
		end
		y			= yvals(b);
		logp		= log10(pvals(b));
		summary		= summaryvals(b);
		sorted_logp	= sort(logp);
		fourth_logp	= sorted_logp(min(4,end));

		uy_at_snr	= unique(y);
		nuy_at_snr	= numel(uy_at_snr);
		logp_mean_t	= zeros(size(logp));
		percentile	= zeros(size(logp));
		for ky=1:nuy_at_snr
			b			= (y == uy_at_snr(ky));
			usummary	= summary(b);
			tstat		= arrayfun(@(s)s.alex.stats.tstat,usummary);
			df			= arrayfun(@(s)s.alex.stats.df,usummary);
			finite_t	= tstat(-Inf<tstat & tstat<Inf);
			mean_df		= mean(df);
			if numel(finite_t)>0 && mean_df>0 && var(df)==0
				mean_t			= mean(finite_t);
				% TODO: introduce a function log10_bounded for following idiom:
				logp_mean_t(b)	= log10(max(1e-6,min(t2p(mean_t,mean_df),1e6)));
			end
			percentile(b)	= 100*sum(arrayfun(@(v) v<=log10pThreshold,logp(b)))/sum(b);
		end

		[f_logp,g_logp]	= dual_linefit(logp,y,log10pThreshold);
		[f_mean,g_mean]	= dual_linefit(logp_mean_t,y,log10pThreshold);
		[f_pct,~]		= dual_linefit(percentile,y,50);

		criterionfit	= g_logp.px2y;
		if notfalse(showwork) && ks < 8
			% the diagnostic scatter-plot below places the "y" value on the x-axis
			% and log10(p) on the y-axis, in effect swapping the axes of the polyfit.
			curr_snr	= num2str(snr(ks));
			fprintf('Num probes for SNR=%s is %d; ',curr_snr,currNProbe);
			fprintf('slope of fitted line is %s;\n',num2str(1/criterionfit(1)));
			fprintf('fourth-smallest log is %s\n',num2str(fourth_logp));

			logpthreshStr	= sprintf('log(%s)',num2str(pThreshold));
			xlabelStr		= sprintf('%s (also referred to here as y)',varname);
			figure;
			switch showwork
				case 'hist'
					if nuy_at_snr >= 2
						% TODO: would be more correct for step to be gcd of diff(uy_at_snr),
						% but cannot directly use MATLAB's gcd function for this purpose.
						bincenters			= min(y):min(diff(uy_at_snr)):max(y);
					else
						bincenters			= uy_at_snr;
					end
					hist(y,bincenters);
					xlabel(xlabelStr);
					ylabel('num probes');
				case 'pct'
					scatter(y,percentile);
					xlabel(xlabelStr);
					ylabel(sprintf('%% p <= %s',num2str(pThreshold)));
				case 'scat'
					scatter(y,logp,'blue');
					xlabel(xlabelStr);
					ylabel('log_{10}(p)');
					hold;
					scatter(y,logp_mean_t,'red','fill');
					ySamp		= linspace(min(y),max(y),2);
					f_meanSamp	= getLogpSamp(f_mean,2);
					f_logpSamp	= getLogpSamp(f_logp,2);
					plot(ySamp,polyval(g_mean.py2x,ySamp),'red');
					plot(ySamp,polyval(g_logp.py2x,ySamp),'blue');
					plot(polyval(f_mean.px2y,f_meanSamp),f_meanSamp,'green');
					plot(polyval(f_logp.px2y,f_logpSamp),f_logpSamp,'yellow');
					plot([min(y),max(y)],[log10pThreshold,log10pThreshold],'black');
					legend({'log p','log p(mean t)','log p(mean t)=g(y)','log p=G(y)','y=f(log p(mean t))','y=F(log p)',logpthreshStr});
				otherwise
					error('Unknown showwork type ''%s''',showwork);
			end
			title(sprintf('Distrib of %s probes at SNR=%s',varname,curr_snr));
			hold off;
			if strcmp(showwork,'scat') && ks == 4 && false % (omit for now)
				alexplot(y,logp,'type','scatter','color',[0,0,1]);
			end
		end
		if nottrue(opt.clip)
			accept	= ~(currNProbe < 20 || criterionfit(1) >= 0 || fourth_logp > log10pThreshold); % TODO: change criterion?
		else
			accept	= true; % will have already pruned outliers if opt.clip==true
		end
		if accept
			cploty{1}(ks)	= g_mean.y0;
			cploty{2}(ks)	= g_logp.y0;
			cploty{3}(ks)	= f_mean.y0;
			cploty{4}(ks)	= f_logp.y0;
			cploty{5}(ks)	= f_pct.y0;
			cploterr{1}(ks)	= g_mean.dy0;
			cploterr{2}(ks)	= g_logp.dy0;
			cploterr{3}(ks)	= f_mean.dy0;
			cploterr{4}(ks)	= f_logp.dy0;
			cploterr{5}(ks)	= f_pct.dy0;
		end
	end
	titleStr	= sprintf('%s vs SNR to achieve p=%s',varname,num2str(pThreshold));
	pctLegend	= sprintf('Fit: P(p <= %s)=50%%',num2str(pThreshold));
	cLegend		= {'Fit: g(y)=log p(mean t)','Fit: G(y)=log p','Fit: f(log p(mean t))=y','Fit: F(log p)=y',pctLegend};

	noline					= true(1,nline);
	noline(opt.plotlines)	= false;
	[cLegend{noline}]		= deal('suppressed');
	mploty					= cell2mat(cploty.');
	mploty(noline,:)		= NaN;
	cploty					= mat2cell(mploty,ones(1,nline),size(mploty,2)).';
	zorderl					= 1:nline; % (constant for now)

	hA	= alexplot(snr,cploty(zorderl), ...
			'error'		, cploterr(zorderl)		, ...
			'title'		, titleStr				, ...
			'xlabel'	, 'SNR'					, ...
			'ylabel'	, varname				, ...
			'legend'	, cLegend(zorderl)		, ...
			'errortype'	, 'bar'					  ...
			);
	h	= hA.hF;

	function [f,g] = dual_linefit(x,y,x0)
		%fprintf('range(x)=%s range(y)=%s\n',num2str(range(x)),num2str(range(y)));
		xy	= [x(:);y(:)];
		if numel(x) < 3 || range(x) == 0 || range(y) == 0 || any(isnan(xy)) || any(isinf(xy))
			f.px2y			= [0,mean(y)];
			f.py2x			= [0,mean(x)];
			[f.y0,f.dy0]	= deal(NaN);
			g				= f;
		else
			[f.px2y,S]		= polyfit(x,y,1);
			[f.y0,f.dy0]	= polyval(f.px2y,x0,S);
			f.dy0			= errfac*f.dy0;
			f.y0			= optclip(f.y0,x0,f.dy0);
			f.py2x			= swap_linear_polynomial_axes(f.px2y);

			[g.py2x,S]		= polyfit(y,x,1);
			g.px2y			= swap_linear_polynomial_axes(g.py2x);
			g.y0			= polyval(g.px2y,x0);
			[x0_hat,dx0]	= polyval(g.py2x,g.y0,S);

			assert(abs(x0-x0_hat)<1e-8,'Erroneous linear polynomial inversion');

			g.dy0			= abs(errfac*dx0*g.px2y(1));
			g.y0			= optclip(g.y0,x0,g.dy0);
			if strcmp(opt.clip,'oldclip')
				g.dy0		= min(g.dy0,max(yvals));
			end
		end

		function y0 = optclip(y0,x0,dy0)
			if strcmp(opt.clip,'oldclip')
				y0		= max(min(yvals),min(y0,max(yvals)));
			elseif opt.clip
				% TODO: improve clipping criterion below?
				minN		= opt.clipsize;
				tailfrac	= opt.cliptail;
				if isOutlier(y0,y,minN,tailfrac) || isOutlier(x0,x,minN,tailfrac)
					y0	= NaN;
				end
			end
			if notfalse(opt.cliperr)
				limit	= conditional(isnumeric(opt.cliperr),opt.cliperr,1)*max(yvals);
				if ~(0 <= dy0 && dy0 <= limit)
					y0	= NaN;
				end
			end
		end
	end

	function samp = getLogpSamp(linefit,nSamp)
		ypreimage	= sort(polyval(linefit.py2x,[min(y),max(y)]));
		samp		= linspace(max(ypreimage(1),min(logp)),min(ypreimage(end),max(logp)),nSamp);
	end

	function b = isOutlier(v,vals,minN,tailfrac)
		vinc	= sort(vals(:));
		N		= numel(vinc);
		tailN	= floor(N*(tailfrac+1e-10));
		b		= N < minN || v < vinc(1+tailN) || v > vinc(N-tailN);
	end

	function pswap = swap_linear_polynomial_axes(p)
		iSlope	= 1/p(1);
		pswap	= [iSlope,-p(2)*iSlope];
	end
end

function h = scatter_p_vs_SNR(sPoint,pThreshold,varname,~)
	h	= scatter_p_vs_x('SNR',[sPoint.x],[sPoint.p],varname,[sPoint.y],pThreshold);
end

function h = scatter_p_vs_test(sPoint,pThreshold,varname,~)
	h	= scatter_p_vs_x(varname,[sPoint.y],[sPoint.p],'SNR',[sPoint.x],pThreshold);
end

function h = scatter_p_vs_x(xname,xvals,pvals,colorname,colorvals,pThreshold)
	log10_p		= log10(max(1e-6,min(pvals,1e6)));
	xdistinct	= unique(xvals);
	xmost		= xdistinct(1:end-1);
	if ~isempty(xmost)
		xgap		= diff(xdistinct);
		nbetween	= ceil(200/numel(xmost));
		dots		= reshape(repmat(xmost,nbetween,1)+(1:nbetween).'*xgap/(nbetween+1),1,[]);
	else
		dots		= [];
	end
	unit		= ones(size(dots));
	scatx		= [xvals dots];
	scaty		= [log10_p log10(pThreshold)*unit];
	color		= [colorvals max(colorvals)*unit];
	h			= figure;
	scatter(scatx,scaty,10,color);
	title(sprintf('log10(p) vs %s, with low %s as blue, high %s as red/brown',xname,colorname,colorname));
end

function h = scatter_test_vs_SNR(sPoint,pThreshold,varname,~)
% TODO: This function is redundant with plot_points in ThresholdWeave.
% Should clean up this redundancy.
	ratio		= max(1e-6,min([sPoint.p]./pThreshold,1e6));
	area		= 10+abs(60*log(ratio));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h			= figure;
	scatter([sPoint.x],[sPoint.y],area,color);
	title(sprintf('%s vs SNR, with low p as blue, high p as red',varname));
end
