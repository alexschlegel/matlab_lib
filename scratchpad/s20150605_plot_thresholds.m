% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% This script is an updated variant of s20150601_plot_threshold_data.m
%
% Among other differences, the variants of this script use different
% data formats.  Data files written by one variant can be plotted only
% by the same variant.  Files written by the earlier variant have
% names that include the stem s20150601_threshold_data.

% TODO: Comments
%

function h = s20150605_plot_thresholds(varargin)
	stem		= 's20150605_thresholds';
	opt			= ParseArgs(varargin, ...
					'fakedata'			, []			, ...
					'forcegen'			, false			, ...
					'nogen'				, []			, ...
					'noplot'			, []			, ...
					'plottype'			, []			, ...
					'savedata'			, []			, ...
					'saveplot'			, false			, ...
					'showwork'			, false			, ...
					'varname'			, []			, ...
					'xge'				, []			, ...
					'xle'				, []			, ...
					'yge'				, []			, ...
					'yle'				, []			, ...
					'xstart'			, 0.06			, ...
					'xstep'				, 0.02			, ...
					'xend'				, 0.34			  ...
					);
	extraargs	= opt2cell(opt.opt_extra);

	hasFigwin		= feature('ShowFigureWindows');
	opt.fakedata	= unless(opt.fakedata,hasFigwin);
	opt.nogen		= unless(opt.nogen,hasFigwin) && ~opt.forcegen;
	opt.noplot		= unless(opt.noplot,~hasFigwin);
	opt.savedata	= unless(opt.savedata,~opt.fakedata);

	if opt.showwork
		opt.plottype	= unless(opt.plottype,{'dualfit'});
		opt.varname		= unless(opt.varname,'WStrength');
	elseif isempty(opt.plottype)
		opt.plottype	= conditional(isempty(opt.varname),{'dualfit'},...
							{'dualfit','p_snr','p_test','test_snr'});
	elseif ~iscell(opt.plottype)
		opt.plottype	= {opt.plottype};
	end

	timestamp	= FormatTime(nowms,'yyyymmdd_HHMMSS');
	h			= [];
	cap_ts		= {};

	sketch('nRun'		, 2:20);
	sketch('nSubject'	, 1:20);
	sketch('nTBlock'	, 1:20);
	sketch('nRepBlock'	, 2:15);
	sketch('WStrength'	, 0.2:0.001:0.8);

	if numel(h) > 0
		if ~opt.saveplot
			fprintf('Skipping save of plot(s) to fig file.\n');
		else
			cap_ts		= sort(cap_ts);
			dirpath		= 'scratchpad/figfiles';
			prefix		= sprintf('%s_%s',cap_ts{end},stem);
			kind		= unless(opt.varname,strjoin(opt.plottype,'+'));
			figfilepath	= sprintf('%s/%s-%s-%s.fig',dirpath,prefix,kind,FormatTime(nowms,'mmdd'));
			savefig(h(end:-1:1),figfilepath);
			fprintf('Plot(s) saved to %s\n',figfilepath);
		end
	end

	function sketch(testvarName,testvarValues)
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

		xge			= unless(opt.xge,-Inf);
		xle			= unless(opt.xle,+Inf);
		yge			= unless(opt.yge,-Inf);
		yle			= unless(opt.yle,+Inf);
		okpoints	= xge <=[points.x] & [points.x] <= xle & yge <= [points.y] & [points.y] <= yle;
		points		= points(okpoints);
		plottype	= opt.plottype;
		nAV	= numel(plottype);
		for kAV=1:nAV
			switch plottype{kAV}
				case 'dualfit'
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
			h(end+1)		= plotfn(points,pThreshold,testvarName,opt.showwork);
			cap_ts{end+1}	= ts;
		end

		function capsule = create_threshCapsule
			start_ms	= nowms;

			[threshPts,pipeline,threshOpt]	...
						= ThresholdSketch(...
							'fakedata'	, opt.fakedata		, ...
							'noplot'	, true				, ...
							'yname'		, testvarName		, ...
							'yvals'		, testvarValues		, ...
							'xstart'	, opt.xstart		, ...
							'xstep'		, opt.xstep			, ...
							'xend'		, opt.xend			, ...
							'seed'		, 0					, ...
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

function h = linefit_test_vs_SNR(sPoint,pThreshold,varname,showwork)
	xvals	= [sPoint.x];
	yvals	= [sPoint.y];
	pvals	= max(1e-6,min([sPoint.p],1e6));
	snr		= unique(xvals);
	nsnr	= numel(snr);

	[ploty,iiploty,ploterr,iiploterr]	= deal(zeros(1,nsnr));
	errfac								= 1; % For ploterr error bars at 50%; TODO: revise

	log10pThreshold	= log10(pThreshold);

	for ks=1:nsnr
		b			= xvals == snr(ks);
		numProbes	= sum(b);
		if numProbes < 2
			[ploty(ks),iiploty(ks)]		= deal(NaN);
			[ploterr(ks),iiploterr(ks)]	= deal(0);
			continue;
		end
		y			= yvals(b);
		logp		= log10(pvals(b));
		yRange		= range(y);
		logpRange	= range(logp);
		sorted_logp	= sort(logp);
		fourth_logp	= sorted_logp(min(4,end));
		if yRange == 0 || logpRange == 0
			fit			= [0,mean(y)];
			ifit		= [0,mean(logp)];
			iifit		= fit;

			[fity,dy,iifity]	= deal(NaN);

			%{
			%OLD stuff:
			fit1		= max(0,min(yRange/logpRange,1e10));
			fit			= [fit1,min(y)-fit1*min(logp)];
			[fity,dy]	= deal(NaN);
			ifit1		= max(0,min(logpRange/yRange,1e10));
			ifit		= [ifit1,min(logp)-ifit1*(min(y)+0.2)];
			iifit		= fit;
			iifity		= fity;
			%}
		else
			[fit,S]		= polyfit(logp,y,1);
			[fity,dy]	= polyval(fit,log10pThreshold,S);
			%{
			m y + b = p
			m y = p - b
			y = (p - b)/m
			y = (1/m)p - b/m
			%}
			[ifit,iS]	= polyfit(y,logp,1);
			iifit		= [1/ifit(1),-ifit(2)/ifit(1)];
			iifity		= polyval(iifit,log10pThreshold);
		end
		if false  % TODO: temporary diagnostic block?
			yf			= floor(fity);
			neighbor	= (y == yf | y == yf+1);
			if sum(neighbor) >= 5
				ofity		= fity;
				y			= y(neighbor);
				logp		= logp(neighbor);
				[fit,S]		= polyfit(logp,y,1);
				[fity,dy]	= polyval(fit,log10pThreshold,S);
				fprintf('neighbor fit %s -> %s\n',num2str(ofity),num2str(fity));
			end
		end
		if notfalse(showwork) && ks < 8
			% the diagnostic scatter-plot below places the "y" value on the x-axis
			% and log10(p) on the y-axis, in effect swapping the axes of the polyfit.
			curr_snr	= num2str(snr(ks));
			fprintf('Num probes for SNR=%s is %d; ',curr_snr,numProbes);
			fprintf('slope of fitted line is %s;\n',num2str(1/fit(1)));
			fprintf('fourth-smallest log is %s\n',num2str(fourth_logp));
			figure;
			switch conditional(nottrue(showwork),showwork,'scat')
				case 'hist'
					hist(y);
				case 'scat'
					scatter(y,logp);
					xlabel(varname);
					ylabel('log_{10}(p)');
					hold;
					logpSamp	= linspace(min(logp),max(logp),2);
					ySamp		= linspace(min(y),max(y),2);
					plot(polyval(fit,logpSamp),logpSamp,'red');
					plot(ySamp,polyval(ifit,ySamp),'blue');
					plot([min(y),max(y)],[log10pThreshold,log10pThreshold],'cyan');
					logpthreshStr	= sprintf('log(%s)',num2str(pThreshold));
					legend({'probe','y=f(log(p))','log(p)=g(y)',logpthreshStr});
				otherwise
					error('Unknown showwork type ''%s''',showwork);
			end
			title(sprintf('Distrib of %s probes at SNR=%s',varname,curr_snr));
			if ks == 4
				alexplot(y,logp,'type','scatter','color',[0,0,1]);
			end
		end
		if numProbes < 20 || fit(1) >= 0 || fourth_logp > log10pThreshold
			[ploty(ks),iiploty(ks)]		= deal(NaN);
			[ploterr(ks),iiploterr(ks)]	= deal(0);
		else
			ploty(ks)		= fity;
			iiploty(ks)		= iifity;
			ploterr(ks)		= errfac*dy;
			iiploterr(ks)	= 0; %TODO: what should error be in this case?
		end
	end
	titleStr	= sprintf('%s vs SNR to achieve p=%s',varname,num2str(pThreshold));
	cLegend		= {'Fit: f(log(p))=y','Fit: g(y)=log(p)'};

	hA	= alexplot(snr,{ploty,iiploty}, ...
			'error'		, {ploterr,iiploterr}	, ...
			'title'		, titleStr				, ...
			'xlabel'	, 'SNR'					, ...
			'ylabel'	, varname				, ...
			'legend'	, cLegend				, ...
			'errortype'	, 'bar'					  ...
			);
	h	= hA.hF;
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
% TODO: This function is redundant with plot_points in ThresholdSketch.
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
